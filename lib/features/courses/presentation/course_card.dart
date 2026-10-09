import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../records/records_providers.dart';
import '../courses_providers.dart';
import '../domain/course.dart';

/// Ligne de course façon calendrier de courses : date à gauche, titre en capitales, chrono à droite.
class CourseCard extends ConsumerWidget {
  final Course course;

  /// Affiche l'année sous la date (listes qui ne sont pas groupées par année).
  final bool showYear;

  const CourseCard({super.key, required this.course, this.showYear = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider).value ?? course.raceDate;
    final status = course.statusOn(today);
    final isRecord = ref.watch(personalRecordsProvider.select((r) => r.heldBy(course).isNotEmpty));
    final photo = course.medalPhotoKey ?? course.bibPhotoKey;
    final awaiting = status == CourseStatus.awaitingResult;

    // Valeur mise en avant à droite : chrono, compte à rebours, ou action attendue.
    final (String headline, Color headlineColor) = switch (status) {
      CourseStatus.completed when course.hasTime => (formatDuration(course.durationS), p.text),
      CourseStatus.completed => (formatKm(course.distanceM, decimals: 1), p.text),
      CourseStatus.upcoming => ('J-${course.raceDate.difference(today).inDays}', p.upcoming),
      CourseStatus.awaitingResult => (t.statusAwaitingShort, p.accent),
    };

    final details = [
      course.type.label(t),
      formatKm(course.distanceM),
      if (status == CourseStatus.completed && course.hasTime) formatPace(course.paceSecondsPerKm),
      if ((course.elevationGainM ?? 0) > 0) 'D+ ${formatMeters(course.elevationGainM!)}',
    ];

    final tags = [
      if (isRecord) Pill(icon: Icons.emoji_events_outlined, label: t.recordBadge, color: p.record),
      if (course.isCharity && course.associationCause != null)
        Pill(
          icon: course.associationCause!.icon,
          label: course.associationName ?? course.associationCause!.label(t),
          color: p.solidarity,
        ),
      if (course.donationCents > 0)
        Pill(icon: Icons.favorite_outline, label: formatEuros(course.donationCents), color: p.solidarity),
    ];

    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: BorderSide(color: awaiting ? p.accent : p.border, width: awaiting ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.course(course.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, 14, Space.md, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBlock(
                date: course.raceDate,
                showYear: showYear,
                color: awaiting ? p.accent : (status == CourseStatus.upcoming ? p.upcoming : p.text),
              ),
              const SizedBox(width: Space.md),
              if (photo != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.md),
                  child: SizedBox.square(dimension: 56, child: CoursePhoto(photoKey: photo, thumbnail: true)),
                ),
                const SizedBox(width: Space.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title.toUpperCase(),
                      semanticsLabel: course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.courseTitle(p.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details.join('  ·  '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFeatures: Fonts.tabular),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: Space.sm),
                      Wrap(spacing: 6, runSpacing: 6, children: tags),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Space.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: awaiting
                    ? Kicker(headline, color: headlineColor, size: 14)
                    : Text(headline, textAlign: TextAlign.right, style: TextStyles.figure(headlineColor, size: 26)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jour en grand, mois abrégé dessous (et l'année si demandée).
class _DateBlock extends StatelessWidget {
  final DateTime date;
  final bool showYear;
  final Color color;

  const _DateBlock({required this.date, required this.showYear, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Text('${date.day}', style: TextStyles.hero(color, size: 30)),
          Text(formatMonthShort(date), style: TextStyles.kicker(color, size: 12)),
          if (showYear) Text('${date.year}', style: TextStyles.kicker(p.textMuted, size: 11)),
        ],
      ),
    );
  }
}
