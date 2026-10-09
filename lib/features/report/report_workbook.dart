import 'dart:typed_data';

import '../../app/format.dart';
import '../../app/labels.dart';
import '../../core/export/xlsx.dart';
import '../../l10n/app_localizations.dart';
import '../courses/domain/course.dart';
import 'domain/engagement_report.dart';
import 'report_text.dart';

/// Classeur Excel (.xlsx) du bilan, aux couleurs ÉLAN (voir [buildXlsx]).
Uint8List reportWorkbook(EngagementReport r, AppLocalizations t) {
  final s = r.stats;
  return buildXlsx(
    sheetName: t.reportSheetName,
    title: t.reportHeading(formatFullDate(r.from), formatFullDate(r.to)),
    subtitle: [t.reportSheetSubtitle(r.courses.length), if (r.charityOnly) t.reportCharityOnly].join(' · '),
    headers: t.reportTableHeader.split('\t'),
    // Assez larges pour que la flèche de filtre ne masque pas le titre.
    widths: const [13, 34, 21, 16, 11, 13, 10, 34, 24, 18, 30],
    rows: [
      for (final c in r.courses)
        [
          XCell.date(c.raceDate),
          XCell.text(c.title),
          XCell.text(c.type.label(t)),
          XCell.number(c.distanceM / 1000, XFormat.km),
          c.hasTime ? XCell.text(formatDuration(c.durationS), center: true) : const XCell.empty(XFormat.center),
          c.hasTime
              ? XCell.text(formatPace(c.paceSecondsPerKm).replaceAll(' /km', ''), center: true)
              : const XCell.empty(XFormat.center),
          c.elevationGainM == null
              ? const XCell.empty(XFormat.integer)
              : XCell.number(c.elevationGainM!, XFormat.integer),
          XCell.text(c.isCharity ? (c.associationName ?? '') : ''),
          XCell.text(c.isCharity ? (c.associationCause?.label(t) ?? '') : ''),
          c.isCharity && c.donationCents > 0
              ? XCell.number(c.donationCents / 100, XFormat.euro)
              : const XCell.empty(XFormat.euro),
          XCell.text(declaredOf(c, t)),
        ],
    ],
    // Totaux par formules : restent justes si on modifie une valeur dans Excel.
    totals: [
      XCell.text(t.reportTotal),
      XCell.text(t.periodCount(r.courses.length)),
      const XCell.empty(),
      XCell.sum(s.distanceM / 1000, XFormat.km),
      XCell.text(s.durationS > 0 ? formatLongDuration(s.durationS) : '', center: true),
      const XCell.empty(XFormat.center),
      XCell.sum(s.elevationGainM, XFormat.integer),
      const XCell.empty(),
      const XCell.empty(),
      XCell.sum(r.impact.donationCents / 100, XFormat.euro),
      const XCell.empty(),
    ],
  );
}

/// Équivalence annoncée d'une course solidaire (« 4 arbres plantés »), sinon vide.
String declaredOf(Course c, AppLocalizations t) {
  final q = c.impactQuantity;
  return c.isCharity && q != null && q > 0 && c.impactMetric != ImpactMetric.euroDirect
      ? declaredLabel(t, c.impactMetric, q)
      : '';
}
