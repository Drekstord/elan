import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/report/domain/engagement_report.dart';

import 'dart:convert';

import 'package:app_course/app/widgets/rich_clipboard.dart';
import 'package:app_course/features/report/report_html.dart';
import 'package:app_course/features/report/report_text.dart';
import 'package:app_course/features/report/report_workbook.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));
  final t = AppLocalizationsFr();

  final courses = [
    Course(
      id: 'restos',
      title: 'La Course du Cœur',
      raceDate: calendarDate(2025, 9, 20),
      distanceM: 10000,
      durationS: 3150,
      isCharity: true,
      associationName: 'Les Restos du Cœur',
      associationCause: CauseType.precarite,
      registrationDonationCents: 1500,
    ),
    Course(
      id: 'tc',
      title: 'The Conqueror · Grand Défi',
      type: CourseType.theConqueror,
      raceDate: calendarDate(2026, 3, 1),
      distanceM: 72500,
      isCharity: true,
      associationName: 'The Conqueror (Eden Reforestation)',
      associationCause: CauseType.environnement,
      registrationDonationCents: 5000,
      impactMetric: ImpactMetric.trees,
      impactQuantity: 4,
    ),
    Course(id: 'semi', title: 'Semi de Paris', raceDate: calendarDate(2026, 8, 31), distanceM: 21100, durationS: 6300),
    Course(id: 'avant', title: 'Avant', raceDate: calendarDate(2025, 8, 31), distanceM: 5000, durationS: 1500),
    Course(id: 'futur', title: 'Futur', raceDate: calendarDate(2026, 6, 1), distanceM: 42195, isPlanned: true),
  ];

  test('raccourcis : année scolaire, année civile, 12 derniers mois', () {
    expect(presetRange(ReportPreset.schoolYear, calendarDate(2026, 10, 8)), (
      calendarDate(2026, 9, 1),
      calendarDate(2027, 8, 31),
    ));
    expect(presetRange(ReportPreset.schoolYear, calendarDate(2026, 3, 15)), (
      calendarDate(2025, 9, 1),
      calendarDate(2026, 8, 31),
    ));
    expect(presetRange(ReportPreset.calendarYear, calendarDate(2026, 3, 15)), (
      calendarDate(2026, 1, 1),
      calendarDate(2026, 12, 31),
    ));
    expect(presetRange(ReportPreset.last12Months, calendarDate(2026, 3, 15)), (
      calendarDate(2025, 3, 16),
      calendarDate(2026, 3, 15),
    ));
  });

  test('période : bornes incluses, courses à venir exclues, option solidaires', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    expect(r.courses.map((c) => c.id), ['restos', 'tc', 'semi']);
    final solidaires = EngagementReport.of(
      courses,
      from: calendarDate(2025, 9, 1),
      to: calendarDate(2026, 8, 31),
      charityOnly: true,
    );
    expect(solidaires.courses.map((c) => c.id), ['restos', 'tc']);
  });

  test('texte du rapport', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final text = reportText(r, t).replaceAll(' ', ' ').replaceAll(' ', ' ');
    expect(text, startsWith('Bilan ÉLAN du 1er septembre 2025 au 31 août 2026'));
    expect(text, contains('• 2 courses solidaires, soit 82,5 km courus pour des causes.'));
    expect(text, contains('• 65 € engagés (dons, parrainages et collectes).'));
    expect(text, contains('• Impact annoncé par les organisateurs : 4 arbres plantés.'));
    expect(text, contains('Environnement & climat (50 €, 72,5 km)'));
    expect(
      text,
      contains(
        'The Conqueror · Grand Défi (défi)  ·  72,5 km  ·  The Conqueror (Eden Reforestation)  ·  50 €  ·  4 arbres plantés',
      ),
    );
    expect(text, contains('La Course du Cœur  ·  10 km en 52:30  ·  Les Restos du Cœur  ·  15 €'));
    expect(text, contains('• 3 courses terminées, 103,6 km au total.'));
    expect(text, isNot(contains('Dénivelé')));
    expect(text, isNot(contains('Futur')));

    final empty = EngagementReport.of(courses, from: calendarDate(2020, 1, 1), to: calendarDate(2020, 12, 31));
    expect(reportText(empty, t), endsWith(t.reportEmpty));
  });

  test('tableau : une ligne par course, colonnes séparées par des tabulations', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final rows = reportTable(r, t).split('\n');
    expect(rows, hasLength(4));
    final header = rows.first.split('\t');
    final tc = rows[2].split('\t');
    expect(tc, hasLength(header.length));
    expect(tc[0], '01/03/2026');
    expect(tc[3], '72,5');
    expect(tc[9], '50');
    expect(tc[10], '4 arbres plantés');
  });

  test('texte rédigé : phrases complètes, défis expliqués, énumération à la française', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final text = reportProse(r, t).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ');
    expect(
      text,
      contains(
        "Du 1er septembre 2025 au 31 août 2026, j'ai participé à 3 courses, pour un total de 103,6 km parcourus.",
      ),
    );
    expect(text, contains("2 d'entre elles étaient solidaires, soit 82,5 km courus au profit de causes."));
    expect(text, contains('un défi au long cours (The Conqueror), qui représente 72,5 km à lui seul.'));
    expect(text, contains('notamment pour Environnement & climat (50 €) et Précarité & faim (15 €).'));
    expect(text, contains('impact concret : 4 arbres plantés.'));
    expect(text, contains('Les associations soutenues sont Les Restos du Cœur et The Conqueror (Eden Reforestation).'));
    expect(text, contains('Sur le plan sportif, cela représente 2 h 37 min de course et une allure moyenne de'));
    expect(joinFr(['A', 'B', 'C'], t), 'A, B et C');
  });

  test('classeur Excel : archive valide, XML bien formé, vraies dates, totaux en formules', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final zip = ZipDecoder().decodeBytes(reportWorkbook(r, t));
    final names = zip.files.map((f) => f.name).toSet();
    expect(
      names,
      containsAll([
        '[Content_Types].xml',
        '_rels/.rels',
        'xl/workbook.xml',
        'xl/styles.xml',
        'xl/worksheets/sheet1.xml',
      ]),
    );
    for (final f in zip.files) {
      XmlDocument.parse(String.fromCharCodes(f.content)); // lève une exception si mal formé
    }
    final sheet = XmlDocument.parse(
      String.fromCharCodes(zip.files.firstWhere((f) => f.name == 'xl/worksheets/sheet1.xml').content),
    );
    // 1er mars 2026 = jour 46082 pour Excel.
    final dates = sheet.findAllElements('c').where((c) => c.getAttribute('r')!.startsWith('A')).map((c) => c.innerText);
    expect(dates, contains('46082'));
    final formulas = sheet.findAllElements('f').map((f) => f.innerText).toList();
    expect(formulas, ['SUM(D5:D7)', 'SUM(G5:G7)', 'SUM(J5:J7)']);
    expect(sheet.findAllElements('pane').single.getAttribute('state'), 'frozen');
  });

  test('presse-papier Windows : les décalages CF_HTML pointent exactement sur le fragment', () {
    const fragment = '<table><tr><td>Été · 26:58</td></tr></table>';
    final bytes = utf8.encode(cfHtml(fragment));
    final header = utf8.decode(bytes.take(200).toList(), allowMalformed: true);
    int offset(String key) => int.parse(
      RegExp(
        '$key:('
        r'\d{10})',
      ).firstMatch(header)!.group(1)!,
    );
    expect(utf8.decode(bytes.sublist(offset('StartFragment'), offset('EndFragment'))), fragment);
    expect(utf8.decode(bytes.sublist(offset('StartHTML'), offset('EndHTML'))), startsWith('<html>'));
    expect(offset('EndHTML'), bytes.length);
  });

  test('tableau HTML : en-tête, une ligne par course, totaux, temps protégés pour Excel', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final html = reportTableHtml(r, t);
    expect(RegExp('<th ').allMatches(html), hasLength(11));
    expect(RegExp('<tr>').allMatches(html), hasLength(1 + 3 + 1));
    expect(html, contains('background:#15301F'));
    expect(html, contains("52:30</td>"));
    expect(html, contains("mso-number-format:'\\@'\">52:30<"));
    expect(html, contains('Les Restos du Cœur'));
  });

  test('texte HTML : titre et intertitres en gras, puces en liste', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final html = reportTextHtml(reportText(r, t));
    expect(html, contains('<b>Bilan ÉLAN du 1er septembre 2025 au 31 août 2026</b>'));
    expect(html, contains('<b>ENGAGEMENT SOLIDAIRE</b>'));
    expect(RegExp('<ul').allMatches(html), hasLength(3));
    expect(html, isNot(contains('• ')));
    final prose = reportTextHtml(reportProse(r, t));
    expect(RegExp('<p ').allMatches(prose).length, greaterThan(3));
  });

  test('tableau Word : 6 colonnes compactes dont la largeur totale fait 100 %', () {
    final r = EngagementReport.of(courses, from: calendarDate(2025, 9, 1), to: calendarDate(2026, 8, 31));
    final html = reportTableHtmlWord(r, t);
    expect(RegExp('<th ').allMatches(html), hasLength(6));
    final widths = RegExp(r'<th width="(\d+)%').allMatches(html).map((m) => int.parse(m.group(1)!));
    expect(widths.reduce((a, b) => a + b), 100);
    expect(RegExp('<tr>').allMatches(html), hasLength(1 + 3 + 1));
    expect(html, contains('La Course du Cœur<br>'));
    expect(html, contains('Défi The Conqueror'));
  });
}
