import 'package:flutter/material.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/elan_emblem.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/domain/course.dart';
import '../../impact/domain/impact_summary.dart';
import '../domain/engagement_report.dart';
import '../report_text.dart';

/// Largeur logique de l'image du bilan ; exportée ×3 (1080 px de large). La hauteur part de
/// 450 (1350 px, portrait des réseaux) et s'allonge si les associations ou les causes l'exigent.
const double kReportCardWidth = 360;
const double kReportCardMinHeight = 450;

/// Image du bilan : période, fonds engagés, chiffres clés (courses, défis, distance, solidaires),
/// impact de chaque cause et toutes les associations. Palette claire « nature », quel que soit le thème.
class ReportCard extends StatelessWidget {
  final EngagementReport report;

  /// Titre et sous-titre à la place de « Bilan d'engagement » et de la période
  /// (récapitulatif d'une association, par exemple).
  final String? title;
  final String? subtitle;

  const ReportCard({super.key, required this.report, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const p = Palette.light;
    final onBand = p.onBand;
    final muted = p.onBandMuted;
    final impact = report.impact;
    final stats = report.stats;
    final hasMoney = impact.donationCents > 0;
    final highlights = impact.highlights;
    final period = (subtitle ?? t.reportPeriod(formatDay(report.from), formatDay(report.to))).toUpperCase();
    final challenges = report.courses.where((c) => c.type == CourseType.theConqueror).length;

    // Les défis justifient les gros kilométrages : ils sont comptés à part.
    final figures = [
      (t.statRaces, '${stats.count - challenges}'),
      if (challenges > 0) (t.kindChallenge, '$challenges'),
      (t.statDistance, formatKm(stats.distanceM, decimals: 0)),
      if (impact.charityCount > 0) (t.filterCharity, '${impact.charityCount}'),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: kReportCardWidth,
        maxWidth: kReportCardWidth,
        minHeight: kReportCardMinHeight,
      ),
      child: Container(
        color: p.band,
        child: Stack(
          children: [
            Positioned(top: -20, right: -50, child: ElanEmblem(size: 300, color: p.bandAccent.withValues(alpha: 0.07))),
            // IntrinsicHeight : la colonne remplit au moins la hauteur minimale, bandeau en bas.
            IntrinsicHeight(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kReportCardMinHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                      child: Row(
                        children: [
                          ElanEmblem(size: 30, color: p.bandAccent),
                          const SizedBox(width: 8),
                          Text('ÉLAN', style: TextStyles.courseTitle(onBand, size: 20).copyWith(letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 40, 22, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (title ?? t.reportCardTitle).toUpperCase(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.courseTitle(onBand, size: 26),
                          ),
                          const SizedBox(height: 2),
                          Text(period, style: TextStyles.kicker(p.bandAccent, size: 11)),
                          const SizedBox(height: 8),
                          // Chiffre héros : l'argent engagé, ou à défaut la distance.
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  hasMoney
                                      ? formatEurosAmount(impact.donationCents)
                                      : formatKm(stats.distanceM, decimals: 0).replaceAll(' km', ''),
                                  style: TextStyles.hero(hasMoney ? p.bandWarm : onBand, size: 76),
                                ),
                                Text(
                                  hasMoney ? ' €' : ' KM',
                                  style: TextStyles.figure(hasMoney ? p.bandWarm : onBand, size: 26),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            (hasMoney ? t.statDonations : t.statDistance).toUpperCase(),
                            style: TextStyles.kicker(muted, size: 10),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (final (label, value) in figures)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(label.toUpperCase(), style: TextStyles.kicker(muted, size: 10)),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(value, style: TextStyles.figure(onBand, size: 18)),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (highlights.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            // Toutes les causes, trois par ligne.
                            for (var i = 0; i < highlights.length; i += 3)
                              Padding(
                                padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var j = i; j < i + 3; j++)
                                      Expanded(
                                        child: j < highlights.length ? _Highlight(highlights[j]) : const SizedBox(),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    if (impact.associations.isNotEmpty)
                      Container(
                        color: p.solidarity,
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(Icons.favorite, color: p.onSolidarity, size: 18),
                            ),
                            const SizedBox(width: 10),
                            // Toutes les associations, sans abréviation : la carte s'allonge.
                            Expanded(
                              child: Text(
                                t.reportCardFor(joinFr(impact.associations, t)),
                                style: TextStyles.courseTitle(p.onSolidarity, size: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(height: 6, color: p.bandAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une équivalence annoncée ou les kilomètres courus pour une cause.
class _Highlight extends StatelessWidget {
  final ImpactHighlight highlight;

  const _Highlight(this.highlight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const p = Palette.light;
    final (IconData icon, String value, String label) = switch (highlight) {
      DeclaredHighlight(:final metric, :final quantity) => (metric.icon, formatQuantity(quantity), metric.label(t)),
      CauseDistanceHighlight(:final cause, :final meters) => (
        cause.icon,
        formatKm(meters, decimals: 1),
        cause.label(t),
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: p.bandAccent),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: TextStyles.figure(p.bandAccent, size: 20)),
                ),
              ),
            ],
          ),
          Text(
            label.toUpperCase(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.kicker(p.onBandMuted, size: 9),
          ),
        ],
      ),
    );
  }
}
