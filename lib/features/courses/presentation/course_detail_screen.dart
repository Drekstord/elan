import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../records/domain/personal_records.dart';
import '../../records/records_providers.dart';
import '../courses_providers.dart';
import '../domain/course.dart';
import '../domain/course_rules.dart';
import '../../documents/presentation/document_widgets.dart';
import 'share_card.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final course = ref.watch(
      coursesProvider.select((v) => v.whenData((l) => l.where((c) => c.id == courseId).firstOrNull)),
    );

    return course.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: EmptyState(icon: Icons.error_outline, message: '$e'),
      ),
      data: (c) => c == null
          ? Scaffold(
              appBar: AppBar(),
              body: EmptyState(icon: Icons.search_off, message: t.detailNotFound),
            )
          : _Detail(course: c),
    );
  }
}

class _Detail extends ConsumerWidget {
  final Course course;

  const _Detail({required this.course});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteCourseTitle),
        content: Text(t.deleteCourseBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.pop();
    await ref.read(courseRepositoryProvider).delete(course.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider).value ?? course.raceDate;
    final status = course.statusOn(today);
    final records = ref.watch(personalRecordsProvider).heldBy(course);
    const gap = SizedBox(height: Space.md);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (status == CourseStatus.completed)
            IconButton(
              tooltip: t.shareTitle,
              icon: const Icon(Icons.ios_share),
              onPressed: () => showShareCard(context, course),
            ),
          IconButton(
            tooltip: t.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Routes.editCourse(course.id)),
          ),
          IconButton(tooltip: t.delete, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref)),
        ],
      ),
      // Grand écran : performance à gauche ; solidarité, photos et notes à droite.
      body: AdaptiveColumns(
        leftShare: 0.48,
        left: [
          Row(
            children: [
              Icon(
                course.isCharity && course.type == CourseType.officialRace ? Icons.favorite : course.type.icon,
                size: 16,
                color: course.isCharity ? p.solidarity : p.accent,
              ),
              const SizedBox(width: Space.xs),
              Flexible(
                child: Kicker(
                  course.isCharity && course.type == CourseType.officialRace ? t.formCharity : course.type.label(t),
                  color: course.isCharity ? p.solidarity : p.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Semantics(
            header: true,
            child: Text(
              course.title.toUpperCase(),
              semanticsLabel: course.title,
              style: TextStyles.courseTitle(p.text, size: 40),
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(formatLongDay(course.raceDate), style: theme.textTheme.bodyMedium?.copyWith(color: p.textMuted)),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.xs,
            children: [
              if (status != CourseStatus.completed) StatusChip(status: status),
              for (final r in records)
                Pill(icon: Icons.emoji_events_outlined, label: _recordLabel(r, t), color: p.record),
            ],
          ),
          gap,
          if (status != CourseStatus.completed) ...[_PlannedNotice(course: course, status: status), gap],
          _PerformanceBand(course: course),
          const SizedBox(height: Space.md),
        ],
        right: [
          if (course.isCharity) ...[_SolidarityCard(course: course), gap],
          CourseDocumentsCard(course: course),
          if (course.photoKeys.isNotEmpty) ...[
            gap,
            SectionCard(
              title: t.formPhotos,
              children: [
                Row(
                  children: [
                    for (final (key, label) in [(course.medalPhotoKey, t.formMedal), (course.bibPhotoKey, t.formBib)])
                      if (key != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: Space.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Radii.md),
                                    child: InkWell(
                                      onTap: () => showPhoto(context, key, label: '$label : ${course.title}'),
                                      child: CoursePhoto(
                                        photoKey: key,
                                        thumbnail: true,
                                        semanticLabel: '$label : ${course.title}',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Space.xs),
                                Text(label, style: TextStyle(color: p.textMuted)),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ],
          if (course.notes != null) ...[
            gap,
            SectionCard(title: t.formNotes, children: [SelectableText(course.notes!)]),
          ],
        ],
      ),
    );
  }

  static String _recordLabel(RecordKind r, AppLocalizations t) => switch (r) {
    DistanceRecord(:final distance) => '${t.recordBadge} ${distance.label(t)}',
    LongestRecord() => t.recordsLongest,
    ElevationRecord() => t.recordsElevation,
  };
}

/// Bandeau noir : le chrono en héros, puis distance, allure, vitesse, D+.
class _PerformanceBand extends StatelessWidget {
  final Course course;

  const _PerformanceBand({required this.course});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final muted = p.onBandMuted;
    final km = formatKm(course.distanceM).replaceAll(' km', '');
    StatTile tile(String label, String value) =>
        StatTile(label: label, value: value, color: p.onBand, labelColor: muted);
    final tiles = [
      if (course.hasTime) ...[
        tile(t.statDistance, formatKm(course.distanceM)),
        tile(t.detailPace, formatPace(course.paceSecondsPerKm)),
        tile(t.detailSpeed, formatSpeed(course.speedKmh)),
      ],
      if ((course.elevationGainM ?? 0) > 0) tile(t.statElevation, formatMeters(course.elevationGainM!)),
    ];

    return HeroBand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (course.hasTime)
            HeroFigure(value: formatDuration(course.durationS), label: t.detailTime, size: 80)
          else
            HeroFigure(value: km, unit: 'KM', label: t.statDistance, size: 80),
          if (tiles.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            Container(height: 1, color: p.onBand.withValues(alpha: 0.2)),
            const SizedBox(height: Space.md),
            StatGrid(minTileWidth: 110, tiles: tiles),
          ],
          if (course.isTeam && course.challengeDistanceM != null) ...[
            const SizedBox(height: Space.md),
            Text(
              t.detailTeam(course.teamSize!, formatKm(course.challengeDistanceM!, decimals: 0)),
              style: TextStyle(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlannedNotice extends ConsumerWidget {
  final Course course;
  final CourseStatus status;

  const _PlannedNotice({required this.course, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final awaiting = status == CourseStatus.awaitingResult;
    final color = awaiting ? p.accent : p.upcoming;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(Radii.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            awaiting ? t.detailAwaitingInfo : t.detailUpcomingInfo,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          if (awaiting) ...[
            const SizedBox(height: Space.md),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ResultDialog(course: course),
              ),
              icon: const Icon(Icons.timer_outlined),
              label: Text(t.detailEnterResult),
            ),
          ],
        ],
      ),
    );
  }
}

class _SolidarityCard extends StatelessWidget {
  final Course course;

  const _SolidarityCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final sponsorCents = (course.sponsorCentsPerKm * course.distanceM / 1000).round();
    final lines = [
      if (course.sponsorCentsPerKm > 0)
        ('${t.detailSponsor} (${formatEuros(course.sponsorCentsPerKm)}/km)', sponsorCents),
      if (course.registrationDonationCents > 0) (t.detailRegistration, course.registrationDonationCents),
      if (course.fundraisingCents > 0) (t.detailFundraising, course.fundraisingCents),
    ];
    final quantity = course.impactQuantity;

    return SectionCard(
      title: t.detailSolidarity,
      children: [
        if (course.associationName != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(course.associationCause?.icon ?? Icons.volunteer_activism_outlined, color: p.solidarity),
            title: Text(course.associationName!, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: course.associationCause == null ? null : Text(course.associationCause!.label(t)),
          ),
        if (course.associationDescription != null) ...[
          Text(course.associationDescription!, style: TextStyle(color: p.textMuted)),
          const SizedBox(height: Space.md),
        ],
        for (final (label, cents) in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                Text(formatEuros(cents)),
              ],
            ),
          ),
        if (course.donationCents > 0) ...[
          const Divider(),
          const SizedBox(height: Space.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Kicker(t.detailDonationTotal, color: p.text)),
              Text(formatEuros(course.donationCents), style: TextStyles.figure(p.solidarity, size: 36)),
            ],
          ),
        ],
        if (quantity != null) ...[
          const SizedBox(height: Space.md),
          Row(
            children: [
              Icon(course.impactMetric.icon, color: p.solidarity),
              const SizedBox(width: Space.sm),
              Expanded(child: Text('${formatQuantity(quantity)} ${course.impactMetric.label(t).toLowerCase()}')),
              Text(t.detailDeclaredImpact, style: TextStyle(color: p.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }
}

/// Saisie du résultat d'une course à venir : temps, et distance / D+ réels si besoin.
class ResultDialog extends ConsumerStatefulWidget {
  final Course course;

  const ResultDialog({super.key, required this.course});

  @override
  ConsumerState<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends ConsumerState<ResultDialog> {
  late final _duration = TextEditingController();
  late final _distance = TextEditingController(text: metersToKmInput(widget.course.distanceM));
  late final _elevation = TextEditingController(text: widget.course.elevationGainM?.toString());
  String? _error;

  @override
  void dispose() {
    _duration.dispose();
    _distance.dispose();
    _elevation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final duration = parseDuration(_duration.text);
    final km = parseDecimal(_distance.text);
    if (duration == null || duration <= 0) return setState(() => _error = t.issueInvalidDuration);
    if (km == null || km <= 0) return setState(() => _error = t.issueDistance);
    final done = completeWithResult(
      widget.course,
      durationS: duration,
      distanceM: (km * 1000).round(),
      elevationGainM: int.tryParse(_elevation.text.trim()),
    );
    await ref.read(courseRepositoryProvider).save(done);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const decimal = TextInputType.numberWithOptions(decimal: true);
    return AlertDialog(
      title: Text(t.resultTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _duration,
              autofocus: true,
              decoration: InputDecoration(labelText: t.formDuration, hintText: '1:05:30'),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: _distance,
              keyboardType: decimal,
              decoration: InputDecoration(labelText: t.formDistance),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: _elevation,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.formElevation),
            ),
            if (_error != null) ...[
              const SizedBox(height: Space.md),
              Text(_error!, style: TextStyle(color: context.palette.danger)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}
