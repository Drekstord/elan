import 'package:flutter/material.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/course.dart';

/// Couleur de chaque discipline (toujours accompagnée de son nom : jamais la couleur seule).
Color sportColor(Sport sport, Palette p) => switch (sport) {
  Sport.swim => p.upcoming,
  Sport.bike => p.record,
  Sport.run => p.accent,
};

/// Une part du temps total : une discipline, ou l'ensemble des transitions.
class _Share {
  final String label;
  final int seconds;
  final Color color;

  const _Share(this.label, this.seconds, this.color);
}

/// Détail d'une épreuve enchaînée sur la fiche de la course : chaque discipline avec sa distance,
/// son temps et son rythme dans son unité, les transitions, puis la répartition du temps.
class MultisportCard extends StatelessWidget {
  final Course course;

  const MultisportCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final m = course.multisport!;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted);

    final shares = [
      if (m.hasSplits) ...[
        for (var i = 0; i < m.legs.length; i++)
          _Share(m.legLabel(i, t), m.legs[i].durationS, sportColor(m.legs[i].sport, p)),
        if (m.transitionsTotalS > 0) _Share(t.multisportTransitions, m.transitionsTotalS, p.textMuted),
      ],
    ];
    final shown = shares.fold(0, (sum, s) => sum + s.seconds);

    return SectionCard(
      title: m.title(t),
      children: [
        for (var i = 0; i < m.legs.length; i++) ...[
          if (i > 0) const Divider(height: Space.lg),
          _LegRow(
            label: m.legLabel(i, t),
            leg: m.legs[i],
            includesTransition: m.legIncludesTransition(i) && m.legs[i].durationS > 0,
          ),
          if (i < m.transitionsS.length && m.transitionsS[i] > 0)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm, left: 32),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, size: 16, color: p.textMuted),
                  const SizedBox(width: Space.xs),
                  Expanded(child: Text(t.multisportTransition(i + 1), style: small)),
                  Text(
                    formatDuration(m.transitionsS[i]),
                    style: small?.copyWith(fontFeatures: Fonts.tabular, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
        if (shares.length > 1 && shown > 0) ...[
          const Divider(height: Space.lg),
          Text(t.multisportBreakdown, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: Space.sm),
          // Barre décorative : la légende juste dessous donne les mêmes parts en texte.
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    for (var i = 0; i < shares.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(
                        flex: shares[i].seconds.clamp(1, 1 << 30),
                        child: ColoredBox(color: shares[i].color),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.md,
            runSpacing: Space.xs,
            children: [
              for (final s in shares)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 6),
                    Text('${s.label} ${(s.seconds * 100 / shown).round()} %', style: small),
                  ],
                ),
            ],
          ),
        ],
        if (course.isCompleted && m.runDistanceM > 0) ...[
          const SizedBox(height: Space.md),
          Text(t.multisportRunShare(formatKm(m.runDistanceM)), style: small),
        ],
      ],
    );
  }
}

class _LegRow extends StatelessWidget {
  final String label;
  final Leg leg;
  final bool includesTransition;

  const _LegRow({required this.label, required this.leg, required this.includesTransition});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted);
    final distance = formatLegDistance(leg);
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(leg.sport.icon, size: 22, color: sportColor(leg.sport, p)),
          ),
          const SizedBox(width: Space.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  [
                    distance,
                    if (leg.hasTime) formatLegPace(leg),
                    // Rythme un peu sous-estimé : le temps contient aussi la transition.
                    if (includesTransition) t.multisportTransitionIncludedNote,
                  ].join('  ·  '),
                  style: small?.copyWith(fontFeatures: Fonts.tabular),
                ),
              ],
            ),
          ),
          if (leg.durationS > 0) ...[
            const SizedBox(width: Space.sm),
            Text(formatDuration(leg.durationS), style: TextStyles.figure(p.text, size: 22)),
          ],
        ],
      ),
    );
  }
}
