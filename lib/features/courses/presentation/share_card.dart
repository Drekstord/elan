import 'package:flutter/material.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/elan_emblem.dart';
import '../../../app/widgets/image_export.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/course.dart';

/// Taille logique de la carte ; exportée ×3 = 1080 × 1350 (format portrait des réseaux).
const Size kShareCardSize = Size(360, 450);

/// Aperçu de la carte de partage, puis enregistrement (ordinateur) ou partage (téléphone).
Future<void> showShareCard(BuildContext context, Course course) => showDialog<void>(
  context: context,
  builder: (_) => _ShareDialog(course: course),
);

class _ShareDialog extends StatefulWidget {
  final Course course;

  const _ShareDialog({required this.course});

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final done = await exportImage(context, _boundary, fileName: exportFileName('elan', widget.course.title));
      if (done && mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(t.shareTitle.toUpperCase()),
      contentPadding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
      content: SingleChildScrollView(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.lg),
            child: RepaintBoundary(
              key: _boundary,
              child: ShareCard(course: widget.course),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton.icon(
          onPressed: _busy ? null : _export,
          icon: _busy
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(exportShares ? Icons.share : Icons.download),
          label: Text(exportShares ? t.shareShare : t.shareSave),
        ),
      ],
    );
  }
}

/// La carte elle-même : toujours en palette claire « nature », quel que soit le thème.
class ShareCard extends StatelessWidget {
  final Course course;

  const ShareCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const p = Palette.light;
    final photo = course.medalPhotoKey ?? course.bibPhotoKey;
    final onBand = p.onBand;
    final muted = p.onBandMuted;
    final hero = course.hasTime ? formatDuration(course.durationS) : formatKm(course.distanceM).replaceAll(' km', '');
    final multisport = course.multisport;
    final stats = [
      // Épreuve enchaînée : chaque discipline avec sa distance, et son temps s'il est connu.
      if (multisport != null)
        for (var i = 0; i < multisport.legs.length; i++)
          multisport.legs[i].durationS > 0
              ? (
                  '${multisport.legLabel(i, t)} ${formatLegDistance(multisport.legs[i])}',
                  formatDuration(multisport.legs[i].durationS),
                )
              : (multisport.legLabel(i, t), formatLegDistance(multisport.legs[i]))
      else ...[
        if (course.hasTime) (t.statDistance, formatKm(course.distanceM)),
        if (course.hasTime) (t.detailPace, formatPace(course.paceSecondsPerKm)),
      ],
      if ((course.elevationGainM ?? 0) > 0) (t.statElevation, formatMeters(course.elevationGainM!)),
    ];

    final kind = course.isCharity && course.type == CourseType.officialRace ? t.formCharity : course.typeLabel(t);

    return SizedBox.fromSize(
      size: kShareCardSize,
      child: Container(
        color: p.band,
        child: Stack(
          children: [
            // Grand élan en filigrane dans la partie haute.
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
                            const Spacer(),
                            if (photo != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Radii.md),
                                child: SizedBox.square(
                                  dimension: 64,
                                  child: CoursePhoto(photoKey: photo, thumbnail: true),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '$kind  ·  ${formatDay(course.raceDate)}'.toUpperCase(),
                          style: TextStyles.kicker(p.bandAccent, size: 11),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          course.title.toUpperCase(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.courseTitle(onBand, size: 30),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(hero, style: TextStyles.hero(onBand, size: 84)),
                              if (!course.hasTime) Text(' KM', style: TextStyles.figure(onBand, size: 28)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final (label, value) in stats)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(label.toUpperCase(), maxLines: 2, style: TextStyles.kicker(muted, size: 10)),
                                    Text(value, style: TextStyles.figure(onBand, size: 18)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                if (course.isCharity) _SolidarityBanner(course: course),
                Container(height: 6, color: p.bandAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau terre cuite : l'argent versé et à qui, puis ce que la course a produit
/// (équivalence annoncée : arbres, bouteilles…) ou, à défaut, la cause soutenue.
class _SolidarityBanner extends StatelessWidget {
  final Course course;

  const _SolidarityBanner({required this.course});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const p = Palette.light;
    final quantity = course.impactQuantity;
    final declared = quantity != null && quantity > 0 && course.impactMetric != ImpactMetric.euroDirect;
    final cause = course.associationCause;

    final lines = <(IconData, String, double)>[
      if (course.donationCents > 0 || course.associationName != null)
        (
          Icons.favorite,
          [
            if (course.donationCents > 0) formatEuros(course.donationCents),
            if (course.associationName != null) t.shareFor(course.associationName!),
          ].join(' '),
          16,
        ),
      if (declared)
        (course.impactMetric.icon, '${formatQuantity(quantity)} ${course.impactMetric.label(t).toLowerCase()}', 15)
      else if (cause != null)
        (cause.icon, cause.label(t), 15),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      color: p.solidarity,
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (icon, text, size)) in lines.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: Row(
                children: [
                  Icon(icon, color: p.onSolidarity, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.courseTitle(p.onSolidarity, size: size),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
