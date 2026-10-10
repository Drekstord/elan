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
import '../../../app/widgets/image_export.dart';
import '../../impact/data/association_catalog.dart';
import '../courses_providers.dart';
import '../data/calendar_export.dart';
import '../domain/editions.dart';
import '../domain/course.dart';
import 'multisport_view.dart';
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
          if (status == CourseStatus.upcoming)
            IconButton(
              tooltip: t.calendarAdd,
              icon: const Icon(Icons.event_outlined),
              onPressed: () => exportFile(
                context,
                coursesToIcs([course], now: DateTime.now(), description: (c) => calendarDescription(c, t)),
                fileName: exportFileName('elan', course.title, extension: 'ics'),
                mimeType: 'text/calendar',
                extension: 'ics',
                savedMessage: t.calendarSaved,
              ),
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
                  course.isCharity && course.type == CourseType.officialRace ? t.formCharity : course.typeLabel(t),
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
              if (targetLabel(course, t) case final label?)
                Pill(
                  icon: (course.targetDeltaS ?? 1) <= 0 ? Icons.flag : Icons.flag_outlined,
                  label: course.isPlanned && !course.isMultisport && course.distanceM > 0
                      ? '$label  ·  ${formatPace(course.targetDurationS! / course.distanceKm)}'
                      : label,
                  color: course.isPlanned ? p.upcoming : ((course.targetDeltaS ?? 1) <= 0 ? p.record : p.textMuted),
                ),
            ],
          ),
          gap,
          if (status != CourseStatus.completed) ...[_PlannedNotice(course: course, status: status), gap],
          _PerformanceBand(course: course),
          if (course.isMultisport) ...[gap, MultisportCard(course: course)],
          if (course.ranking case final ranking?) ...[gap, _RankingCard(ranking: ranking)],
          if (previousEditions(course, ref.watch(coursesProvider).value ?? const []) case final editions
              when editions.isNotEmpty) ...[
            gap,
            _EditionsCard(course: course, editions: editions),
          ],
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
    MultisportRecord(:final event) => '${t.recordBadge} ${event.kind.label(t)} ${event.format}',
    SportRecord(:final sport) => '${t.recordBadge} ${sport.label(t).toLowerCase()}',
    LongestRecord() => t.recordsLongest,
    ElevationRecord() => t.recordsElevation,
  };
}

/// La même course les années d'avant : l'écart avec la dernière édition, puis chaque édition.
class _EditionsCard extends StatelessWidget {
  final Course course;

  /// De la plus récente à la plus ancienne.
  final List<Course> editions;

  const _EditionsCard({required this.course, required this.editions});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted);
    final last = editions.where((c) => c.hasTime).firstOrNull;
    final delta = course.isCompleted && course.hasTime && last != null ? course.durationS - last.durationS : null;
    final year = last?.raceDate.year;

    return SectionCard(
      title: t.editionsTitle,
      children: [
        if (delta != null && year != null) ...[
          Row(
            children: [
              Icon(
                delta < 0 ? Icons.trending_up : (delta > 0 ? Icons.trending_down : Icons.trending_flat),
                color: delta < 0 ? p.record : p.textMuted,
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  delta == 0
                      ? t.editionsSame(year)
                      : delta < 0
                      ? t.editionsFaster(formatGap(-delta), year)
                      : t.editionsSlower(formatGap(delta), year),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
        ],
        for (final c in editions)
          InkWell(
            onTap: () => context.push(Routes.course(c.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.sm),
              child: MergeSemantics(
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text('${c.raceDate.year}', style: TextStyles.figure(p.textMuted, size: 18)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (c.ranking?.overall != null)
                            Text(rankLabel(c.ranking!.overall, c.ranking!.finishers, t), style: small),
                        ],
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    Text(
                      c.hasTime ? formatDuration(c.durationS) : formatKm(c.distanceM),
                      style: TextStyles.figure(p.text, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Text(t.editionsHint, style: small),
      ],
    );
  }
}

/// Classement officiel : la place, le nombre d'arrivants et ce que ça représente.
class _RankingCard extends StatelessWidget {
  final Ranking ranking;

  const _RankingCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted);

    Widget row(String label, int? rank, int? total, double? percent) => MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                // Au moins 1 % : « dans les 0 % premiers » ne voudrait rien dire.
                if (percent != null) Text(t.rankingTop(percent.ceil().clamp(1, 100)), style: small),
              ],
            ),
          ),
          const SizedBox(width: Space.sm),
          Text(rankLabel(rank, total, t), style: TextStyles.figure(p.text, size: 22)),
        ],
      ),
    );

    final hasOverall = ranking.overall != null || ranking.finishers != null;
    final hasCategory = ranking.category != null || ranking.categoryFinishers != null;
    return SectionCard(
      title: t.formRanking,
      children: [
        if (hasOverall) row(t.rankingOverall, ranking.overall, ranking.finishers, ranking.overallPercent),
        if (hasOverall && (hasCategory || ranking.categoryName != null)) const Divider(height: Space.lg),
        if (hasCategory)
          row(
            [t.rankingCategory, ?ranking.categoryName].join(' '),
            ranking.category,
            ranking.categoryFinishers,
            ranking.categoryPercent,
          )
        else if (ranking.categoryName != null)
          Text('${t.rankingCategory} ${ranking.categoryName}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
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
    final multisport = course.multisport;
    final tiles = [
      // Épreuve enchaînée : la distance de chaque discipline (allures détaillées dans la carte dessous).
      if (multisport != null)
        for (var i = 0; i < multisport.legs.length; i++)
          tile(multisport.legLabel(i, t), formatLegDistance(multisport.legs[i]))
      else if (course.hasTime) ...[
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
              // Épreuve enchaînée : plusieurs temps à saisir, donc le formulaire complet.
              onPressed: () => course.isMultisport
                  ? context.push(Routes.editCourse(course.id))
                  : showDialog<void>(
                      context: context,
                      builder: (_) => ResultDialog(course: course),
                    ),
              icon: const Icon(Icons.timer_outlined),
              label: Text(course.isMultisport ? t.multisportEditResult : t.detailEnterResult),
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
          Text(
            associationDescription(
              id: course.associationId,
              stored: course.associationDescription,
              language: formatLocale,
            )!,
            style: TextStyle(color: p.textMuted),
          ),
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
  final _rank = TextEditingController();
  final _finishers = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _duration.dispose();
    _distance.dispose();
    _elevation.dispose();
    _rank.dispose();
    _finishers.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final duration = parseDuration(_duration.text);
    final km = parseDecimal(_distance.text);
    if (duration == null || duration <= 0) return setState(() => _error = t.issueInvalidDuration);
    if (km == null || km <= 0) return setState(() => _error = t.issueDistance);
    // Classement facultatif : vide, ou un nombre positif.
    int? place(TextEditingController c) => c.text.trim().isEmpty ? null : (int.tryParse(c.text.trim()) ?? -1);
    final rank = place(_rank);
    final finishers = place(_finishers);
    if ((rank ?? 1) <= 0 || (finishers ?? 1) <= 0) return setState(() => _error = t.issueInvalidNumber);
    if (rank != null && finishers != null && rank > finishers) {
      return setState(() => _error = t.issueRankAboveFinishers);
    }
    final existing = widget.course.ranking;
    final done =
        completeWithResult(
          widget.course,
          durationS: duration,
          distanceM: (km * 1000).round(),
          elevationGainM: int.tryParse(_elevation.text.trim()),
        ).copyWith(
          ranking: Ranking(
            overall: rank ?? existing?.overall,
            finishers: finishers ?? existing?.finishers,
            category: existing?.category,
            categoryFinishers: existing?.categoryFinishers,
            categoryName: existing?.categoryName,
          ),
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
            if (widget.course.type != CourseType.theConqueror) ...[
              const SizedBox(height: Space.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(t.resultRanking, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rank,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t.formRank),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: TextField(
                      controller: _finishers,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t.formFinishers),
                    ),
                  ),
                ],
              ),
            ],
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
