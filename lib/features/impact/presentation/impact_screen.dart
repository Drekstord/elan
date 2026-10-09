import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/charts.dart';
import '../../../app/widgets/common.dart';
import '../../../core/providers.dart';
import '../../courses/domain/course_stats.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/association_summary.dart';
import '../domain/impact_summary.dart';
import '../impact_providers.dart';

class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final impact = ref.watch(impactSummaryProvider);
    final charity = (ref.watch(coursesProvider).value ?? const []).where((c) => c.isCharity);
    final byYear = totalsByPeriod(charity, Period.year);
    final muted = p.onBandMuted;
    const gap = SizedBox(height: Space.lg);

    final causes = impact.distanceByCause.keys.toList()
      ..sort((a, b) => (impact.donationByCause[b] ?? 0).compareTo(impact.donationByCause[a] ?? 0));
    final maxDonation = causes.isEmpty ? 0 : (impact.donationByCause[causes.first] ?? 0);

    final highlights = impact.highlights;
    final associations = associationSummaries(ref.watch(coursesProvider).value ?? const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.impactTitle.toUpperCase()),
        actions: [
          IconButton(
            tooltip: t.docTitle,
            onPressed: () => context.push(Routes.documents),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: t.reportTitle,
            onPressed: () => context.push(Routes.report),
            icon: const Icon(Icons.summarize_outlined),
          ),
          const SizedBox(width: Space.sm),
        ],
      ),
      body: impact.charityCount == 0
          ? EmptyState(icon: Icons.volunteer_activism_outlined, message: t.impactEmpty)
          // Grand écran : bilan et équivalences à gauche ; causes et associations à droite.
          : AdaptiveColumns(
              left: [
                HeroBand(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, c) => HeroFigure(
                          size: (c.maxWidth / 4.2).clamp(64.0, 110.0),
                          count: (
                            id: 'impact.euros',
                            value: impact.donationCents,
                            format: (v) => formatEurosAmount(v.round()),
                          ),
                          unit: '€',
                          label: t.statDonations,
                          color: p.bandWarm,
                        ),
                      ),
                      if (highlights.isNotEmpty) ...[
                        const SizedBox(height: Space.lg),
                        // Une place égale pour chaque cause : équivalences annoncées,
                        // ou kilomètres courus pour la cause.
                        StatGrid(minTileWidth: 150, tiles: [for (final h in highlights) _Highlight(h)]),
                      ],
                      const SizedBox(height: Space.lg),
                      Container(height: 1, color: p.onBand.withValues(alpha: 0.2)),
                      const SizedBox(height: Space.md),
                      StatGrid(
                        minTileWidth: 130,
                        tiles: [
                          for (final (label, value) in [
                            (t.filterCharity, '${impact.charityCount}'),
                            (t.statDistance, formatKm(impact.charityDistanceM, decimals: 0)),
                            (t.impactAssociations, '${impact.associations.length}'),
                          ])
                            StatTile(label: label, value: value, color: p.onBand, labelColor: muted),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.sm),
                Text(t.impactHonesty, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: Space.md),
                Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.push(Routes.report),
                      icon: const Icon(Icons.summarize_outlined),
                      label: Text(t.reportAction),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push(Routes.documents),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(t.docTitle),
                    ),
                  ],
                ),
                gap,
              ],
              right: [
                if (byYear.isNotEmpty) ...[
                  SectionCard(
                    title: t.impactByYear,
                    children: [
                      Text(t.impactByYearHint, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: Space.md),
                      ChartLegend([(LegendMark.bar, p.chartMoney, t.legendDonations, null)]),
                      const SizedBox(height: Space.md),
                      BarChart(
                        height: 160,
                        color: p.chartMoney,
                        format: (v) => formatEuros(v.round()),
                        valueLabel: (v) => formatEurosAmount(v.round()),
                        data: [
                          for (final y in byYear)
                            BarDatum(
                              axisLabel: '${y.start.year}',
                              tooltip: '${y.start.year} : ${formatEuros(y.donationCents)} · ${t.periodCount(y.count)}',
                              value: y.donationCents.toDouble(),
                            ),
                        ],
                      ),
                    ],
                  ),
                  gap,
                ],
                if (causes.isNotEmpty) ...[
                  SectionHeader(t.impactByCause),
                  const SizedBox(height: Space.sm),
                  for (final cause in causes)
                    _CauseBar(
                      icon: cause.icon,
                      label: cause.label(t),
                      distance: formatKm(impact.distanceByCause[cause]!, decimals: 1),
                      cents: impact.donationByCause[cause] ?? 0,
                      share: maxDonation == 0 ? 0 : (impact.donationByCause[cause] ?? 0) / maxDonation,
                    ),
                ],
                if (impact.associations.isNotEmpty) ...[
                  gap,
                  SectionHeader(t.impactAssociations),
                  const SizedBox(height: Space.sm),
                  // Un appui ouvre le récapitulatif de l'association (courses, montants, justificatifs).
                  for (final asso in associations)
                    InkWell(
                      onTap: () => context.push(Routes.association(asso.name)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Space.sm),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, color: p.solidarity),
                            const SizedBox(width: Space.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(asso.name, style: Theme.of(context).textTheme.titleSmall),
                                  Text(
                                    t.periodCount(asso.courses.length),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (asso.donationCents > 0)
                              Text(formatEuros(asso.donationCents), style: TextStyles.figure(p.solidarity, size: 18)),
                            Icon(Icons.chevron_right, color: p.textMuted),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

/// Ligne par cause : libellé, montant, et barre proportionnelle au plus gros montant.
class _CauseBar extends StatelessWidget {
  final IconData icon;
  final String label;
  final String distance;
  final int cents;
  final double share;

  const _CauseBar({
    required this.icon,
    required this.label,
    required this.distance,
    required this.cents,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: p.solidarity),
              const SizedBox(width: Space.sm),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
              Text(distance, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: Space.md),
              Text(formatEuros(cents), style: TextStyles.figure(p.solidarity, size: 20)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: share.clamp(0.02, 1),
              minHeight: 6,
              color: p.solidarity,
              backgroundColor: p.border,
            ),
          ),
        ],
      ),
    );
  }
}

/// Un chiffre du bandeau : icône, grand nombre, libellé.
class _Highlight extends StatelessWidget {
  final ImpactHighlight highlight;

  const _Highlight(this.highlight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final (
      IconData icon,
      ({String id, num value, String Function(num) format}) count,
      String? unit,
      String label,
    ) = switch (highlight) {
      DeclaredHighlight(:final metric, :final quantity) => (
        metric.icon,
        (id: 'impact.${metric.name}', value: quantity, format: (v) => formatQuantity(v.toDouble())),
        null,
        metric.label(t),
      ),
      CauseDistanceHighlight(:final cause, :final meters) => (
        cause.icon,
        (
          id: 'impact.${cause.name}',
          value: meters,
          format: (v) => formatKm(v.round(), decimals: 1).replaceAll(' km', ''),
        ),
        'KM',
        t.impactKmFor(cause.label(t)),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: p.bandAccent, size: 22),
        const SizedBox(height: Space.xs),
        HeroFigure(size: 56, count: count, unit: unit, label: label, color: p.bandAccent),
      ],
    );
  }
}
