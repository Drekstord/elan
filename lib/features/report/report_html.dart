import '../../app/format.dart';
import '../../app/labels.dart';
import '../../app/widgets/rich_clipboard.dart';
import '../../l10n/app_localizations.dart';
import '../courses/domain/course.dart';
import 'domain/engagement_report.dart';
import 'report_text.dart';

// Versions HTML du bilan pour le presse-papier : Word, Excel et Google Docs gardent
// la mise en forme. Styles en ligne uniquement (seuls compris par Word au collage).

const _font = "font-family:Calibri,'Segoe UI',Arial,sans-serif;font-size:10.5pt;color:#14231A";
const _cell = 'padding:4px 8px;border-bottom:1px solid #CEC6B3;vertical-align:middle';

/// Force Excel à garder la valeur telle quelle (sinon « 26:58 » devient 26 h 58).
const _asText = "mso-number-format:'\\@'";

/// Tableau des courses aux couleurs ÉLAN : en-tête vert forêt, lignes alternées, totaux.
String reportTableHtml(EngagementReport r, AppLocalizations t) {
  final headers = t.reportTableHeader.split('\t');
  // Colonnes numériques alignées à droite : distance, D+, fonds engagés.
  const right = {3, 6, 9};
  const center = {0, 4, 5};
  String align(int i) => right.contains(i) ? 'right' : (center.contains(i) ? 'center' : 'left');
  // Dates, temps, nombres : jamais coupés sur deux lignes (seuls les noms longs passent à la ligne).
  String wrap(int i) => right.contains(i) || center.contains(i) ? ';white-space:nowrap' : '';

  String td(int i, String value, {required String background, bool bold = false, bool text = false}) =>
      '<td style="$_cell;background:$background;text-align:${align(i)}${wrap(i)}'
      '${bold ? ';font-weight:bold' : ''}${text ? ';$_asText' : ''}">${htmlEscape(value)}</td>';

  final rows = StringBuffer();
  for (final (index, c) in r.courses.indexed) {
    final bg = index.isOdd ? '#F2EEE4' : '#FFFFFF';
    final quantity = c.impactQuantity;
    final declared = c.isCharity && quantity != null && quantity > 0 && c.impactMetric != ImpactMetric.euroDirect;
    final cells = [
      formatDay(c.raceDate),
      c.title,
      c.type.label(t),
      formatKm(c.distanceM, decimals: 2).replaceAll(' km', ''),
      c.hasTime ? formatDuration(c.durationS) : '',
      c.hasTime ? formatPace(c.paceSecondsPerKm).replaceAll(' /km', '') : '',
      c.elevationGainM == null ? '' : '${c.elevationGainM}',
      c.isCharity ? (c.associationName ?? '') : '',
      c.isCharity ? (c.associationCause?.label(t) ?? '') : '',
      c.isCharity && c.donationCents > 0 ? formatEuros(c.donationCents) : '',
      declared ? declaredLabel(t, c.impactMetric, quantity) : '',
    ];
    rows.write('<tr>');
    for (final (i, v) in cells.indexed) {
      rows.write(td(i, v, background: bg, text: i == 0 || i == 4 || i == 5));
    }
    rows.write('</tr>');
  }

  // Totaux.
  if (r.courses.isNotEmpty) {
    final s = r.stats;
    final totals = [
      t.reportTotal,
      t.periodCount(r.courses.length),
      '',
      formatKm(s.distanceM, decimals: 2).replaceAll(' km', ''),
      s.durationS > 0 ? formatLongDuration(s.durationS) : '',
      '',
      s.elevationGainM > 0 ? '${s.elevationGainM}' : '',
      '',
      '',
      r.impact.donationCents > 0 ? formatEuros(r.impact.donationCents) : '',
      '',
    ];
    rows.write('<tr>');
    for (final (i, v) in totals.indexed) {
      rows.write(
        '<td style="$_cell;background:#DCE8CF;font-weight:bold;border-top:2px solid #15301F;'
        'border-bottom:2px solid #15301F;text-align:${align(i)}${wrap(i)}'
        // Totaux numériques laissés en nombres ; libellés et durée en texte.
        '${i == 0 || i == 1 || i == 4 ? ';$_asText' : ''}">${htmlEscape(v)}</td>',
      );
    }
    rows.write('</tr>');
  }

  final head = headers
      .map(
        (h) =>
            '<th style="padding:6px 8px;background:#15301F;color:#FFFFFF;font-weight:bold;'
            'text-align:center;vertical-align:middle">${htmlEscape(h)}</th>',
      )
      .join();
  return '<table style="border-collapse:collapse;$_font"><thead><tr>$head</tr></thead><tbody>$rows</tbody></table>';
}

/// Texte du bilan (rédigé ou en points clés) en HTML : titre et intertitres en gras,
/// puces en vraie liste, paragraphes conservés.
String reportTextHtml(String text) {
  final out = StringBuffer('<div style="$_font">');
  final blocks = text.split('\n\n');
  for (final (bi, block) in blocks.indexed) {
    final lines = block.split('\n');
    final bullets = <String>[];
    void flush() {
      if (bullets.isEmpty) return;
      out.write('<ul style="margin:0 0 8px 0">${bullets.map((b) => '<li>${htmlEscape(b)}</li>').join()}</ul>');
      bullets.clear();
    }

    for (final (li, line) in lines.indexed) {
      if (line.startsWith('• ')) {
        bullets.add(line.substring(2));
        continue;
      }
      flush();
      // Premier bloc = titre ; ligne en capitales = intertitre (points clés).
      final heading = (bi == 0 && li == 0) || (line.isNotEmpty && line == line.toUpperCase() && line.length < 40);
      out.write(
        heading
            ? '<p style="margin:12px 0 4px 0"><b>${htmlEscape(line)}</b></p>'
            : '<p style="margin:0 0 8px 0">${htmlEscape(line)}</p>',
      );
    }
    flush();
  }
  out.write('</div>');
  return out.toString();
}

/// Tableau compact pour Word : 6 colonnes qui tiennent sur une page A4 portrait.
/// Regroupe titre + type, distance + temps + allure (+ D+), association + cause.
String reportTableHtmlWord(EngagementReport r, AppLocalizations t) {
  final headers = t.reportWordHeader.split('\t');
  // Largeurs en % de la page : la somme fait 100.
  const widths = [12, 22, 19, 25, 10, 12];
  const small = 'font-size:8.5pt;color:#555F51';

  String cell(int i, String inner, {required String background, bool right = false, bool bold = false}) =>
      '<td width="${widths[i]}%" style="width:${widths[i]}%;$_cell;background:$background;'
      'text-align:${right ? 'right' : 'left'}${bold ? ';font-weight:bold' : ''}">$inner</td>';
  String line(String main, String? sub) => sub == null || sub.isEmpty
      ? htmlEscape(main)
      : '${htmlEscape(main)}<br><span style="$small">${htmlEscape(sub)}</span>';

  final rows = StringBuffer();
  for (final (index, c) in r.courses.indexed) {
    final bg = index.isOdd ? '#F2EEE4' : '#FFFFFF';
    final quantity = c.impactQuantity;
    final declared = c.isCharity && quantity != null && quantity > 0 && c.impactMetric != ImpactMetric.euroDirect;
    final perf = [
      if (c.hasTime) formatDuration(c.durationS),
      if (c.hasTime) formatPace(c.paceSecondsPerKm),
      if ((c.elevationGainM ?? 0) > 0) 'D+ ${formatMeters(c.elevationGainM!)}',
    ].join(' · ');
    rows
      ..write('<tr>')
      ..write(cell(0, '<span style="white-space:nowrap">${htmlEscape(formatDay(c.raceDate))}</span>', background: bg))
      ..write(cell(1, line(c.title, c.type.label(t)), background: bg))
      ..write(cell(2, line(formatKm(c.distanceM, decimals: 2), perf), background: bg))
      ..write(cell(3, c.isCharity ? line(c.associationName ?? '', c.associationCause?.label(t)) : '', background: bg))
      ..write(
        cell(
          4,
          c.isCharity && c.donationCents > 0
              ? '<span style="white-space:nowrap">${htmlEscape(formatEuros(c.donationCents))}</span>'
              : '',
          background: bg,
          right: true,
        ),
      )
      ..write(cell(5, declared ? htmlEscape(declaredLabel(t, c.impactMetric, quantity)) : '', background: bg))
      ..write('</tr>');
  }

  if (r.courses.isNotEmpty) {
    final s = r.stats;
    const total = '#DCE8CF';
    String tc(int i, String v, {bool right = false}) =>
        '<td width="${widths[i]}%" style="width:${widths[i]}%;$_cell;background:$total;font-weight:bold;'
        'border-top:2px solid #15301F;border-bottom:2px solid #15301F;text-align:${right ? 'right' : 'left'}">$v</td>';
    rows
      ..write('<tr>')
      ..write(tc(0, htmlEscape(t.reportTotal)))
      ..write(tc(1, htmlEscape(t.periodCount(r.courses.length))))
      ..write(tc(2, line(formatKm(s.distanceM, decimals: 1), s.durationS > 0 ? formatLongDuration(s.durationS) : null)))
      ..write(tc(3, ''))
      ..write(
        tc(
          4,
          r.impact.donationCents > 0
              ? '<span style="white-space:nowrap">${htmlEscape(formatEuros(r.impact.donationCents))}</span>'
              : '',
          right: true,
        ),
      )
      ..write(tc(5, ''))
      ..write('</tr>');
  }

  final head = [
    for (final (i, h) in headers.indexed)
      '<th width="${widths[i]}%" style="width:${widths[i]}%;padding:6px 8px;background:#15301F;color:#FFFFFF;'
          'font-weight:bold;text-align:${i == 4 ? 'right' : 'left'};vertical-align:middle">${htmlEscape(h)}</th>',
  ].join();
  return '<table width="100%" style="width:100%;border-collapse:collapse;table-layout:fixed;$_font;font-size:9.5pt">'
      '<thead><tr>$head</tr></thead><tbody>$rows</tbody></table>';
}
