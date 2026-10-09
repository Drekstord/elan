import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Écriture de classeurs Excel (.xlsx) aux couleurs ÉLAN, sans module tiers :
/// un .xlsx est un ZIP de quelques fichiers XML.
///
/// Mise en forme commune : titre, sous-titre, en-tête vert forêt figé, lignes alternées
/// crème, vraies dates et vrais nombres, ligne de totaux (formules), filtres, impression paysage.

/// Présentation d'une cellule.
enum XFormat { text, center, date, km, euro, integer }

/// Une cellule : texte, nombre, date, ou somme de la colonne (ligne de totaux).
class XCell {
  final Object? value;
  final XFormat format;

  /// Somme de la colonne (formule SUM) ; [value] est la valeur déjà calculée.
  final bool sum;

  const XCell._(this.value, this.format, {this.sum = false});

  const XCell.text(String value, {bool center = false}) : this._(value, center ? XFormat.center : XFormat.text);
  const XCell.number(num value, XFormat format) : this._(value, format);
  const XCell.date(DateTime value) : this._(value, XFormat.date);
  const XCell.empty([XFormat format = XFormat.text]) : this._(null, format);
  const XCell.sum(num cached, XFormat format) : this._(cached, format, sum: true);
}

/// Classeur d'une feuille : [title] (ligne 1), [subtitle] (ligne 2), [headers] (ligne 4),
/// [rows] dessous, puis [totals] éventuels. [widths] : largeur de chaque colonne (caractères).
Uint8List buildXlsx({
  required String sheetName,
  required String title,
  required String subtitle,
  required List<String> headers,
  required List<List<XCell>> rows,
  List<XCell>? totals,
  required List<double> widths,
}) {
  final lastCol = _col(headers.length - 1);
  const headerRow = 4;
  const firstData = headerRow + 1;
  final lastData = headerRow + rows.length;
  final xml = StringBuffer();

  String text(String ref, String value, int style) =>
      '<c r="$ref" t="inlineStr" s="$style"><is><t xml:space="preserve">${_esc(value)}</t></is></c>';

  String cell(String ref, XCell c, {required bool alt, required bool total, required String column}) {
    final base = switch (c.format) {
      XFormat.text => total ? _sTotalText : _sText,
      XFormat.center => total ? _sTotalCenter : _sCenter,
      XFormat.date => total ? _sTotalCenter : _sDate,
      XFormat.km => total ? _sTotalKm : _sKm,
      XFormat.euro => total ? _sTotalEuro : _sEuro,
      XFormat.integer => total ? _sTotalInt : _sInt,
    };
    final style = total ? base : base + (alt ? 1 : 0);
    final v = c.value;
    if (c.sum) {
      return '<c r="$ref" s="$style"><f>SUM($column$firstData:$column$lastData)</f><v>${v ?? 0}</v></c>';
    }
    return switch (v) {
      null => '<c r="$ref" s="$style"/>',
      final String s => text(ref, s, style),
      final DateTime d => '<c r="$ref" s="$style"><v>${_serial(d)}</v></c>',
      final num n => '<c r="$ref" s="$style"><v>$n</v></c>',
      _ => text(ref, '$v', style),
    };
  }

  xml
    ..write('<row r="1" ht="24" customHeight="1">${text('A1', title, _sTitle)}</row>')
    ..write('<row r="2">${text('A2', subtitle, _sSubtitle)}</row>')
    ..write('<row r="$headerRow" ht="30" customHeight="1">');
  for (final (i, h) in headers.indexed) {
    xml.write(text('${_col(i)}$headerRow', h, _sHeader));
  }
  xml.write('</row>');

  for (final (i, row) in rows.indexed) {
    final n = firstData + i;
    xml.write('<row r="$n">');
    for (final (j, c) in row.indexed) {
      xml.write(cell('${_col(j)}$n', c, alt: i.isOdd, total: false, column: _col(j)));
    }
    xml.write('</row>');
  }

  if (totals != null && rows.isNotEmpty) {
    final n = lastData + 1;
    xml.write('<row r="$n" ht="20" customHeight="1">');
    for (final (j, c) in totals.indexed) {
      xml.write(cell('${_col(j)}$n', c, alt: false, total: true, column: _col(j)));
    }
    xml.write('</row>');
  }

  final filter = rows.isEmpty ? null : 'A$headerRow:$lastCol$lastData';
  final sheet =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<worksheet xmlns="$_ns" xmlns:r="$_nsRel">'
      '<sheetPr><pageSetUpPr fitToPage="1"/></sheetPr>'
      '<sheetViews><sheetView workbookViewId="0" showGridLines="0">'
      '<pane ySplit="$headerRow" topLeftCell="A$firstData" activePane="bottomLeft" state="frozen"/>'
      '</sheetView></sheetViews>'
      '<sheetFormatPr defaultRowHeight="18" customHeight="1"/>'
      '<cols>${[for (final (i, w) in widths.indexed) '<col min="${i + 1}" max="${i + 1}" width="$w" customWidth="1"/>'].join()}</cols>'
      '<sheetData>$xml</sheetData>'
      '${filter == null ? '' : '<autoFilter ref="$filter"/>'}'
      '<mergeCells count="2"><mergeCell ref="A1:${lastCol}1"/><mergeCell ref="A2:${lastCol}2"/></mergeCells>'
      '<pageMargins left="0.4" right="0.4" top="0.5" bottom="0.5" header="0.3" footer="0.3"/>'
      '<pageSetup orientation="landscape" fitToWidth="1" fitToHeight="0"/>'
      '</worksheet>';

  final archive = Archive()
    ..addFile(ArchiveFile.string('[Content_Types].xml', _contentTypes))
    ..addFile(ArchiveFile.string('_rels/.rels', _rootRels))
    ..addFile(
      ArchiveFile.string(
        'xl/workbook.xml',
        _workbook(sheetName, filter == null ? null : '\$A\$$headerRow:\$$lastCol\$$lastData'),
      ),
    )
    ..addFile(ArchiveFile.string('xl/_rels/workbook.xml.rels', _workbookRels))
    ..addFile(ArchiveFile.string('xl/styles.xml', _styles))
    ..addFile(ArchiveFile.bytes('xl/worksheets/sheet1.xml', utf8.encode(sheet)));
  return ZipEncoder().encodeBytes(archive);
}

/// Colonne Excel : 0 → A, 25 → Z, 26 → AA.
String _col(int i) => i < 26 ? String.fromCharCode(65 + i) : _col(i ~/ 26 - 1) + String.fromCharCode(65 + i % 26);

/// Date Excel : nombre de jours depuis le 30/12/1899.
int _serial(DateTime d) => DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(1899, 12, 30)).inDays;

String _esc(String v) => v
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

const _ns = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
const _nsRel = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';

// Index des styles (cellXfs ci-dessous). Les styles « ligne » vont par paires : normal, puis fond crème.
const _sTitle = 1, _sSubtitle = 2, _sHeader = 3;
const _sText = 4, _sDate = 6, _sKm = 8, _sEuro = 10, _sInt = 12, _sCenter = 14;
const _sTotalText = 16, _sTotalKm = 17, _sTotalEuro = 18, _sTotalInt = 19, _sTotalCenter = 20;

const _contentTypes =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
    '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
    '</Types>';

const _rootRels =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
    '</Relationships>';

String _workbook(String sheetName, String? filterRange) =>
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<workbook xmlns="$_ns" xmlns:r="$_nsRel">'
    '<sheets><sheet name="${_esc(sheetName)}" sheetId="1" r:id="rId1"/></sheets>'
    '${filterRange == null ? '' : '<definedNames><definedName name="_xlnm._FilterDatabase" localSheetId="0" hidden="1">${_esc("'$sheetName'")}!$filterRange</definedName></definedNames>'}'
    '</workbook>';

const _workbookRels =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
    '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
    '</Relationships>';

/// Polices : 0 normale · 1 titre vert forêt · 2 sous-titre gris · 3 en-tête blanc gras · 4 gras.
/// Fonds : 2 vert forêt (en-tête) · 3 crème (lignes alternées) · 4 vert pâle (totaux).
/// Formats : 164 date · 165 km · 166 euros.
const _styles =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<styleSheet xmlns="$_ns">'
    '<numFmts count="3">'
    '<numFmt numFmtId="164" formatCode="dd/mm/yyyy"/>'
    '<numFmt numFmtId="165" formatCode="#,##0.00"/>'
    '<numFmt numFmtId="166" formatCode="#,##0.00\\ &quot;€&quot;"/>'
    '</numFmts>'
    '<fonts count="5">'
    '<font><sz val="11"/><color rgb="FF14231A"/><name val="Calibri"/><family val="2"/></font>'
    '<font><b/><sz val="16"/><color rgb="FF15301F"/><name val="Calibri"/><family val="2"/></font>'
    '<font><i/><sz val="10"/><color rgb="FF555F51"/><name val="Calibri"/><family val="2"/></font>'
    '<font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/><family val="2"/></font>'
    '<font><b/><sz val="11"/><color rgb="FF14231A"/><name val="Calibri"/><family val="2"/></font>'
    '</fonts>'
    '<fills count="5">'
    '<fill><patternFill patternType="none"/></fill>'
    '<fill><patternFill patternType="gray125"/></fill>'
    '<fill><patternFill patternType="solid"><fgColor rgb="FF15301F"/><bgColor indexed="64"/></patternFill></fill>'
    '<fill><patternFill patternType="solid"><fgColor rgb="FFF2EEE4"/><bgColor indexed="64"/></patternFill></fill>'
    '<fill><patternFill patternType="solid"><fgColor rgb="FFDCE8CF"/><bgColor indexed="64"/></patternFill></fill>'
    '</fills>'
    '<borders count="3">'
    '<border><left/><right/><top/><bottom/><diagonal/></border>'
    '<border><left/><right/><top/><bottom style="thin"><color rgb="FFCEC6B3"/></bottom><diagonal/></border>'
    '<border><left/><right/><top style="medium"><color rgb="FF15301F"/></top><bottom style="medium"><color rgb="FF15301F"/></bottom><diagonal/></border>'
    '</borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="21">'
    // 0 défaut
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    // 1 titre · 2 sous-titre · 3 en-tête
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="0" fontId="3" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1">'
    '<alignment horizontal="center" vertical="center" wrapText="1"/></xf>'
    // 4-5 texte
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="0" fontId="0" fillId="3" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    // 6-7 date
    '<xf numFmtId="164" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>'
    '<xf numFmtId="164" fontId="0" fillId="3" borderId="1" xfId="0" applyNumberFormat="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>'
    // 8-9 km
    '<xf numFmtId="165" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="165" fontId="0" fillId="3" borderId="1" xfId="0" applyNumberFormat="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    // 10-11 euros
    '<xf numFmtId="166" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="166" fontId="0" fillId="3" borderId="1" xfId="0" applyNumberFormat="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    // 12-13 entier
    '<xf numFmtId="3" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="3" fontId="0" fillId="3" borderId="1" xfId="0" applyNumberFormat="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    // 14-15 centré
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>'
    '<xf numFmtId="0" fontId="0" fillId="3" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>'
    // 16-20 totaux : texte, km, euros, entier, centré
    '<xf numFmtId="0" fontId="4" fillId="4" borderId="2" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="165" fontId="4" fillId="4" borderId="2" xfId="0" applyNumberFormat="1" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="166" fontId="4" fillId="4" borderId="2" xfId="0" applyNumberFormat="1" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="3" fontId="4" fillId="4" borderId="2" xfId="0" applyNumberFormat="1" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="center"/></xf>'
    '<xf numFmtId="0" fontId="4" fillId="4" borderId="2" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>'
    '</cellXfs>'
    '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
    '</styleSheet>';
