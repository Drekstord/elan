import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/format.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/elan_emblem.dart';
import '../../../app/widgets/image_export.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/domain/course.dart';
import '../../courses/presentation/share_card.dart';
import '../domain/year_recap.dart';

/// Aperçu du bilan de l'année, puis enregistrement (ordinateur) ou partage (téléphone).
Future<void> showYearRecap(BuildContext context, {int? year}) => showDialog<void>(
  context: context,
  builder: (_) => _RecapDialog(initialYear: year),
);

class _RecapDialog extends ConsumerStatefulWidget {
  final int? initialYear;

  const _RecapDialog({this.initialYear});

  @override
  ConsumerState<_RecapDialog> createState() => _RecapDialogState();
}

class _RecapDialogState extends ConsumerState<_RecapDialog> {
  final _boundary = GlobalKey();
  late int? _year = widget.initialYear;
  bool _busy = false;

  Future<void> _export(int year) async {
    setState(() => _busy = true);
    try {
      final done = await exportImage(context, _boundary, fileName: exportFileName('elan', 'bilan-$year'));
      if (done && mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final years = YearRecap.years(courses);
    final year = years.contains(_year) ? _year! : (years.firstOrNull ?? DateTime.now().year);
    final index = years.indexOf(year);
    final recap = YearRecap.of(courses, year);

    return AlertDialog(
      title: Text(t.recapTitle.toUpperCase()),
      contentPadding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (years.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: '${year - 1}',
                    // La liste va de la plus récente à la plus ancienne.
                    onPressed: index < years.length - 1 ? () => setState(() => _year = years[index + 1]) : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$year', style: TextStyles.figure(context.palette.text, size: 22)),
                  IconButton(
                    tooltip: '${year + 1}',
                    onPressed: index > 0 ? () => setState(() => _year = years[index - 1]) : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            if (recap.isEmpty)
              Padding(padding: const EdgeInsets.all(Space.lg), child: Text(t.recapEmpty(year)))
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.lg),
                child: RepaintBoundary(
                  key: _boundary,
                  child: YearRecapCard(recap: recap),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton.icon(
          onPressed: _busy || recap.isEmpty ? null : () => _export(year),
          icon: _busy
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(exportShares ? Icons.share : Icons.download),
          label: Text(exportShares ? t.shareShare : t.shareSave),
        ),
      ],
    );
  }
}

/// La carte du bilan : même format et même palette claire que la carte d'une course.
class YearRecapCard extends StatelessWidget {
  final YearRecap recap;

  const YearRecapCard({super.key, required this.recap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const p = Palette.light;
    final onBand = p.onBand;
    final muted = p.onBandMuted;
    final stats = recap.stats;
    final tiles = [
      (t.statRaces, '${stats.count}'),
      if (stats.durationS > 0) (t.detailTime, formatLongDuration(stats.durationS)),
      if (stats.elevationGainM > 0) (t.statElevation, formatMeters(stats.elevationGainM)),
      if (recap.multisportCount > 0) (t.kindMultisport, '${recap.multisportCount}'),
      if (recap.records > 0) (t.recapRecords, '${recap.records}'),
    ].take(4).toList();
    final longest = recap.longest;

    return SizedBox.fromSize(
      size: kShareCardSize,
      child: Container(
        color: p.band,
        child: Stack(
          children: [
            Positioned(top: -20, right: -50, child: ElanEmblem(size: 300, color: p.bandAccent.withValues(alpha: 0.07))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ElanEmblem(size: 30, color: p.bandAccent),
                            const SizedBox(width: 8),
                            Text('ÉLAN', style: TextStyles.courseTitle(onBand, size: 20).copyWith(letterSpacing: 1.5)),
                          ],
                        ),
                        const Spacer(),
                        Text(t.recapKicker(recap.year).toUpperCase(), style: TextStyles.kicker(p.bandAccent, size: 13)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formatKm(stats.distanceM, decimals: 0).replaceAll(' km', ''),
                                style: TextStyles.hero(onBand, size: 96),
                              ),
                              Text(' KM', style: TextStyles.figure(onBand, size: 30)),
                            ],
                          ),
                        ),
                        Text(t.recapRun.toUpperCase(), style: TextStyles.kicker(muted, size: 10)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final (label, value) in tiles)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyles.kicker(muted, size: 10),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(value, style: TextStyles.figure(onBand, size: 18)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (longest != null) ...[
                          const SizedBox(height: 14),
                          Text(t.recapLongest.toUpperCase(), style: TextStyles.kicker(muted, size: 10)),
                          Text(
                            '${longest.title}  ·  ${formatKm(longest.distanceM, decimals: 1)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.courseTitle(onBand, size: 15),
                          ),
                        ],
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                if (recap.donationCents > 0)
                  Container(
                    color: p.solidarity,
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: p.onSolidarity, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recap.associations > 0
                                ? t.recapDonations(formatEuros(recap.donationCents), recap.associations)
                                : t.recapDonationsOnly(formatEuros(recap.donationCents)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.courseTitle(p.onSolidarity, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(height: 6, color: p.bandAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
