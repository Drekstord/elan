import 'package:intl/intl.dart';

import '../../app/format.dart';
import '../../app/labels.dart';
import '../../l10n/app_localizations.dart';
import '../courses/domain/course.dart';
import 'domain/engagement_report.dart';

/// « 1er septembre 2025 », « 20 septembre 2026 ».
String formatFullDate(DateTime d) =>
    d.day == 1 ? '1er ${DateFormat('MMMM y', 'fr').format(d)}' : DateFormat('d MMMM y', 'fr').format(d);

/// Équivalence d'une course ou d'un total : « 4 arbres plantés ».
String declaredLabel(AppLocalizations t, ImpactMetric metric, double quantity) =>
    '${formatQuantity(quantity)} ${metric.label(t).toLowerCase()}';

/// Énumération à la française : « A », « A et B », « A, B et C ».
String joinFr(List<String> items, AppLocalizations t) => switch (items.length) {
  0 => '',
  1 => items.first,
  _ => '${items.take(items.length - 1).join(', ')} ${t.reportAnd} ${items.last}',
};

/// Version rédigée du bilan, à la première personne, en paragraphes.
String reportProse(EngagementReport r, AppLocalizations t) {
  final from = formatFullDate(r.from), to = formatFullDate(r.to);
  if (r.isEmpty) return '${t.reportHeading(from, to)}\n\n${t.reportEmpty}';
  final s = r.stats;
  final impact = r.impact;
  final paragraphs = <String>[];

  // Participation, part solidaire, et défis qui expliquent les gros kilométrages.
  final challenges = r.courses.where((c) => c.type == CourseType.theConqueror).toList();
  paragraphs.add(
    [
      t.reportProseIntro(s.count, from, to, formatKm(s.distanceM, decimals: 1)),
      if (impact.charityCount == 0)
        t.reportProseNoCharity
      else if (impact.charityCount == s.count)
        t.reportProseAllCharity(s.count, formatKm(impact.charityDistanceM, decimals: 1))
      else
        t.reportProseCharity(impact.charityCount, formatKm(impact.charityDistanceM, decimals: 1)),
      if (challenges.isNotEmpty)
        t.reportProseChallenges(
          challenges.length,
          formatKm(challenges.fold(0, (sum, c) => sum + c.distanceM), decimals: 1),
        ),
    ].join(' '),
  );

  // Argent engagé, causes, impact annoncé, associations.
  if (impact.charityCount > 0) {
    final causes = impact.donationByCause.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final declared = impact.declared.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    paragraphs.add(
      [
        if (impact.donationCents > 0)
          causes.isEmpty
              ? t.reportProseDonations(formatEuros(impact.donationCents))
              : t.reportProseDonationsCauses(
                  formatEuros(impact.donationCents),
                  joinFr([for (final e in causes) '${e.key.label(t)} (${formatEuros(e.value)})'], t),
                ),
        if (declared.isNotEmpty)
          t.reportProseDeclared(joinFr([for (final e in declared) declaredLabel(t, e.key, e.value)], t)),
        if (impact.associations.isNotEmpty)
          t.reportProseAssociations(impact.associations.length, joinFr(impact.associations, t)),
      ].join(' '),
    );

    final charity = r.courses.where((c) => c.isCharity).toList();
    paragraphs.add(
      t.reportProseRaces(
        joinFr([
          for (final c in charity)
            '${c.title} (${[formatFullDate(c.raceDate), formatKm(c.distanceM, decimals: 1), if (c.associationName != null) c.associationName!, if (c.donationCents > 0) formatEuros(c.donationCents), if ((c.impactQuantity ?? 0) > 0 && c.impactMetric != ImpactMetric.euroDirect) declaredLabel(t, c.impactMetric, c.impactQuantity!)].join(', ')})',
        ], t),
      ),
    );
  }

  // Bilan sportif.
  final sport = [
    if (s.durationS > 0) t.reportProseTime(formatLongDuration(s.durationS)),
    if (s.elevationGainM > 0) t.reportProseElevation(formatMeters(s.elevationGainM)),
    if (s.averagePaceSecondsPerKm != null) t.reportProsePace(formatPace(s.averagePaceSecondsPerKm)),
  ];
  if (sport.isNotEmpty) paragraphs.add(t.reportProseSport(joinFr(sport, t)));

  return [t.reportHeading(from, to), ...paragraphs].join('\n\n');
}

/// Texte du bilan en points clés, à coller tel quel dans un rapport (puces, sans mise en forme riche).
String reportText(EngagementReport r, AppLocalizations t) {
  final lines = <String>[t.reportHeading(formatFullDate(r.from), formatFullDate(r.to)), ''];
  if (r.isEmpty) return [...lines, t.reportEmpty].join('\n');

  final impact = r.impact;
  lines.add(t.reportSectionSolidarity);
  if (impact.charityCount == 0) {
    lines.add('• ${t.reportNoCharity}');
  } else {
    lines.add('• ${t.reportCharityLine(impact.charityCount, formatKm(impact.charityDistanceM, decimals: 1))}');
    if (impact.donationCents > 0) lines.add('• ${t.reportDonationLine(formatEuros(impact.donationCents))}');
    final declared = impact.declared.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (declared.isNotEmpty) {
      lines.add('• ${t.reportDeclaredLine(declared.map((e) => declaredLabel(t, e.key, e.value)).join(', '))}');
    }
    final causes = impact.distanceByCause.keys.toList()
      ..sort((a, b) => (impact.donationByCause[b] ?? 0).compareTo(impact.donationByCause[a] ?? 0));
    if (causes.isNotEmpty) {
      final items = [
        for (final c in causes)
          '${c.label(t)} (${[if ((impact.donationByCause[c] ?? 0) > 0) formatEuros(impact.donationByCause[c]!), formatKm(impact.distanceByCause[c]!, decimals: 1)].join(', ')})',
      ];
      lines.add('• ${t.reportCausesLine(items.join(', '))}');
    }
    if (impact.associations.isNotEmpty) lines.add('• ${t.reportAssociationsLine(impact.associations.join(', '))}');
  }

  lines
    ..add('')
    ..add(t.reportSectionCourses);
  for (final c in r.courses) {
    final quantity = c.impactQuantity;
    lines.add(
      '• ${[formatDay(c.raceDate), c.type == CourseType.theConqueror ? '${c.title} (${t.reportChallengeTag})' : c.title, c.hasTime ? t.reportDistanceTime(formatKm(c.distanceM, decimals: 2), formatDuration(c.durationS)) : formatKm(c.distanceM, decimals: 2), if (c.isCharity && c.associationName != null) c.associationName!, if (c.isCharity && c.donationCents > 0) formatEuros(c.donationCents), if (c.isCharity && quantity != null && quantity > 0 && c.impactMetric != ImpactMetric.euroDirect) declaredLabel(t, c.impactMetric, quantity)].join('  ·  ')}',
    );
  }

  final s = r.stats;
  lines
    ..add('')
    ..add(t.reportSectionSport)
    ..add('• ${t.reportSportLine(s.count, formatKm(s.distanceM, decimals: 1))}');
  if (s.durationS > 0) lines.add('• ${t.reportTimeLine(formatLongDuration(s.durationS))}');
  if (s.elevationGainM > 0) lines.add('• ${t.reportElevationLine(formatMeters(s.elevationGainM))}');
  if (s.averagePaceSecondsPerKm != null) lines.add('• ${t.reportPaceLine(formatPace(s.averagePaceSecondsPerKm))}');
  return lines.join('\n');
}

/// Les courses en tableau séparé par tabulations : se colle en tableau dans Word ou Excel.
String reportTable(EngagementReport r, AppLocalizations t) {
  String num(double v, {int decimals = 2}) => NumberFormat(decimals == 0 ? '0' : '0.${'#' * decimals}', 'fr').format(v);
  String clean(String v) => v.replaceAll(RegExp(r'[\t\r\n]+'), ' ');
  return [
    t.reportTableHeader,
    for (final c in r.courses)
      [
        DateFormat('dd/MM/yyyy').format(c.raceDate),
        c.title,
        c.type.label(t),
        num(c.distanceM / 1000),
        c.hasTime ? formatDuration(c.durationS) : '',
        c.hasTime ? formatPace(c.paceSecondsPerKm).replaceAll(' /km', '') : '',
        c.elevationGainM == null ? '' : '${c.elevationGainM}',
        c.isCharity ? (c.associationName ?? '') : '',
        c.isCharity ? (c.associationCause?.label(t) ?? '') : '',
        c.isCharity && c.donationCents > 0 ? num(c.donationCents / 100) : '',
        c.isCharity && (c.impactQuantity ?? 0) > 0 && c.impactMetric != ImpactMetric.euroDirect
            ? declaredLabel(t, c.impactMetric, c.impactQuantity!)
            : '',
      ].map(clean).join('\t'),
  ].join('\n');
}
