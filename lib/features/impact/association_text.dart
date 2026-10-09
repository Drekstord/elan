import '../../app/format.dart';
import '../../app/labels.dart';
import '../../l10n/app_localizations.dart';
import '../courses/domain/course.dart';
import '../report/report_text.dart';
import 'domain/association_summary.dart';

/// Récapitulatif d'une association, à coller (justificatif, remerciement, rapport).
String associationText(AssociationSummary a, AppLocalizations t) {
  final distance = formatKm(a.distanceM, decimals: 1);
  final lines = <String>[
    t.assoRecapTitle(a.name),
    '',
    '• ${a.first == a.last ? t.assoRecapLineOne(formatFullDate(a.first), distance) : t.assoRecapLine(a.courses.length, formatFullDate(a.first), formatFullDate(a.last), distance)}',
    if (a.donationCents > 0) '• ${t.reportDonationLine(formatEuros(a.donationCents))}',
    if (a.causes.isNotEmpty) '• ${t.assoCauses(a.causes.length, joinFr([for (final c in a.causes) c.label(t)], t))}',
  ];
  final declared = a.declared.entries.toList()..sort((x, y) => y.value.compareTo(x.value));
  if (declared.isNotEmpty) {
    lines.add('• ${t.reportDeclaredLine(joinFr([for (final e in declared) declaredLabel(t, e.key, e.value)], t))}');
  }
  lines
    ..add('')
    ..add(t.reportSectionCourses);
  for (final c in a.courses) {
    final q = c.impactQuantity;
    lines.add(
      '• ${[formatDay(c.raceDate), c.title, c.hasTime ? t.reportDistanceTime(formatKm(c.distanceM, decimals: 2), formatDuration(c.durationS)) : formatKm(c.distanceM, decimals: 2), if (c.donationCents > 0) formatEuros(c.donationCents), if (q != null && q > 0 && c.impactMetric != ImpactMetric.euroDirect) declaredLabel(t, c.impactMetric, q)].join('  ·  ')}',
    );
  }
  return lines.join('\n');
}
