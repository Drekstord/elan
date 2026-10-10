import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/charts.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/sync_badge.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../evolution/domain/year_recap.dart';
import '../../evolution/presentation/year_recap_card.dart';
import '../../impact/impact_providers.dart';
import '../courses_providers.dart';
import '../data/file_import.dart';
import '../data/gpx_batch.dart';
import '../domain/course.dart';
import '../domain/course_query.dart';
import '../domain/course_stats.dart';
import 'course_card.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  /// Plusieurs GPX d'un coup : une course par trace, doublons ignorés, résumé à la fin.
  Future<void> _importGpxFiles(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final picked = await FileImport.pickGpxFiles(dialogTitle: t.gpxBatchAction);
    if (picked == null || !context.mounted) return;
    final result = coursesFromGpx(
      picked.tracks,
      ref.read(coursesProvider).value ?? const [],
      newId: const Uuid().v4,
      defaultTitle: (day) => t.gpxBatchDefaultTitle(DateFormat('d MMMM y', formatLocale).format(day)),
    );
    final repository = ref.read(courseRepositoryProvider);
    for (final course in result.created) {
      await repository.save(course);
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.gpxBatchTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.gpxBatchCreated(result.created.length)),
            if (result.duplicates > 0) Text(t.gpxBatchDuplicates(result.duplicates)),
            if (result.undated > 0) Text(t.gpxBatchUndated(result.undated)),
            if (picked.unreadable > 0) Text(t.gpxBatchUnreadable(picked.unreadable)),
            if (result.created.isNotEmpty) ...[
              const SizedBox(height: Space.md),
              Text(t.gpxBatchHint, style: Theme.of(ctx).textTheme.bodySmall),
            ],
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(t.close))],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final all = ref.watch(coursesProvider);
    const side = EdgeInsets.symmetric(horizontal: Space.md);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Wordmark(size: 30),
        actions: [
          IconButton(
            tooltip: t.gpxBatchAction,
            icon: const Icon(Icons.upload_file_outlined),
            onPressed: () => _importGpxFiles(context, ref),
          ),
          const SyncBadge(),
          const SizedBox(width: Space.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newCourse),
        icon: const Icon(Icons.add),
        label: Text(t.coursesAdd.toUpperCase()),
      ),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, message: '$e'),
        data: (courses) => courses.isEmpty
            ? EmptyState(icon: Icons.directions_run, message: t.coursesEmpty)
            : LayoutBuilder(
                builder: (context, c) => c.maxWidth >= kTwoColumns
                    ? _WideHome(width: c.maxWidth.clamp(0, kWideMaxWidth).toDouble())
                    : ContentWidth(
                        child: CustomScrollView(
                          slivers: [
                            const SliverPadding(
                              padding: EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 0),
                              sliver: SliverToBoxAdapter(child: _Hero()),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 0),
                              sliver: SliverToBoxAdapter(child: _YearGoal()),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.fromLTRB(Space.md, 0, Space.md, 0),
                              sliver: SliverToBoxAdapter(child: _RecapBanner()),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, 0),
                              sliver: SliverToBoxAdapter(child: _AwaitingBanner()),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.fromLTRB(Space.md, Space.lg, Space.md, Space.md),
                              sliver: SliverToBoxAdapter(child: _Toolbar()),
                            ),
                            const _CourseSections(padding: side),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }
}

/// Bandeau des deux chiffres clés : distance et fonds engagés.
class _Hero extends ConsumerWidget {
  const _Hero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final stats = ref.watch(courseStatsProvider);
    final impact = ref.watch(impactSummaryProvider);
    final muted = p.onBandMuted;

    Widget km(double size) => HeroFigure(
      size: size,
      // Défile jusqu'à sa valeur au lancement.
      count: (
        id: 'accueil.km',
        value: stats.distanceM,
        format: (v) => formatKm(v.round(), decimals: 0).replaceAll(' km', ''),
      ),
      unit: 'KM',
      label: t.statDistance,
    );
    Widget euros(double size) => InkWell(
      onTap: () => context.go(Routes.impact),
      child: HeroFigure(
        size: size,
        count: (id: 'accueil.euros', value: impact.donationCents, format: (v) => formatEurosAmount(v.round())),
        unit: '€',
        label: t.statDonations,
        color: p.bandWarm,
      ),
    );

    return HeroBand(
      child: LayoutBuilder(
        builder: (context, c) {
          // Deux chiffres côte à côte, taille adaptée à la largeur disponible.
          final size = (c.maxWidth / 5.2).clamp(48.0, 96.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: km(size)),
                  const SizedBox(width: Space.md),
                  Expanded(child: euros(size)),
                ],
              ),
              const SizedBox(height: Space.lg),
              Container(height: 1, color: p.onBand.withValues(alpha: 0.2)),
              const SizedBox(height: Space.md),
              StatGrid(
                minTileWidth: 120,
                tiles: [
                  StatTile(label: t.statRaces, value: '${stats.count}', color: p.onBand, labelColor: muted),
                  StatTile(
                    label: t.statTime,
                    value: formatLongDuration(stats.durationS),
                    color: p.onBand,
                    labelColor: muted,
                  ),
                  StatTile(
                    label: t.statElevation,
                    value: formatMeters(stats.elevationGainM),
                    color: p.onBand,
                    labelColor: muted,
                  ),
                  StatTile(
                    label: t.statPace,
                    value: formatPace(stats.averagePaceSecondsPerKm),
                    color: p.onBand,
                    labelColor: muted,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Objectif annuel de kilomètres courus : où l'on en est, et l'avance ou le retard sur le rythme.
/// Sans objectif, une simple invitation à en fixer un.
class _YearGoal extends ConsumerWidget {
  const _YearGoal();

  Future<void> _edit(BuildContext context, WidgetRef ref, int year, int? current) async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController(text: current == null ? '' : '${(current / 1000).round()}');
    final km = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.goalYearTitle(year)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: t.goalDialogField(year),
            suffixText: 'km',
            helperText: t.goalDialogHint,
            helperMaxLines: 3,
          ),
          onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v.trim()) ?? 0),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text.trim()) ?? 0),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (km != null) await ref.read(yearGoalProvider.notifier).set(km <= 0 ? null : km * 1000);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider).value;
    final goal = ref.watch(yearGoalProvider);
    if (today == null || goal.isLoading) return const SizedBox.shrink();
    final goalM = goal.value;
    if (goalM == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => _edit(context, ref, today.year, null),
          icon: const Icon(Icons.flag_outlined),
          label: Text(t.goalSet),
        ),
      );
    }

    final progress = goalProgress(ref.watch(coursesProvider).value ?? const [], today, goalM);
    // En dessous d'un kilomètre d'écart, on est dans le rythme.
    final status = progress.reached
        ? t.goalReached
        : progress.aheadM.abs() < 1000
        ? t.goalOnTrack
        : progress.aheadM > 0
        ? t.goalAhead(formatKm(progress.aheadM, decimals: 0))
        : t.goalBehind(formatKm(-progress.aheadM, decimals: 0));
    final summary = t.goalProgress(formatKm(progress.doneM, decimals: 0), formatKm(goalM, decimals: 0));

    return SectionCard(
      title: t.goalYearTitle(today.year),
      trailing: IconButton(
        tooltip: t.goalEdit,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.edit_outlined, size: 20),
        onPressed: () => _edit(context, ref, today.year, goalM),
      ),
      children: [
        MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text(summary, style: TextStyles.figure(p.text, size: 26))),
                  Text('${(progress.ratio * 100).round()} %', style: TextStyles.figure(p.textMuted, size: 18)),
                ],
              ),
              const SizedBox(height: Space.sm),
              // Décoratif : les chiffres au-dessus disent la même chose.
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: LinearProgressIndicator(
                    value: progress.ratio,
                    minHeight: 10,
                    color: p.accent,
                    backgroundColor: p.border,
                  ),
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(status, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// En décembre et en janvier : le bilan de l'année est prêt à être partagé. Se ferme d'un geste.
class _RecapBanner extends ConsumerWidget {
  const _RecapBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider).value;
    final year = today == null ? null : YearRecap.featuredYear(today);
    final dismissed = ref.watch(recapDismissedProvider).value;
    if (year == null || dismissed == null || dismissed >= year) return const SizedBox.shrink();
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    if (!courses.any((c) => c.isCompleted && !c.isDeleted && c.raceDate.year == year)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.xs, Space.sm),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: p.accent),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.recapBanner(year), style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(t.recapBannerHint, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => showYearRecap(context, year: year),
                child: Text(t.recapBannerOpen),
              ),
              IconButton(
                tooltip: t.close,
                onPressed: () => ref.read(recapDismissedProvider.notifier).dismiss(year),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste en blocs : résultats à saisir, à venir, puis courses terminées par année.
class _CourseSections extends ConsumerWidget {
  final EdgeInsets padding;

  const _CourseSections({required this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final visible = ref.watch(visibleCoursesProvider).value;
    final query = ref.watch(courseQueryProvider);
    final today = ref.watch(todayProvider).value;
    if (visible == null || today == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    if (visible.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            EmptyState(icon: Icons.search_off, message: t.coursesNoMatch),
            if (query.isFiltered)
              TextButton(onPressed: () => ref.read(courseQueryProvider.notifier).reset(), child: Text(t.filterReset)),
          ],
        ),
      );
    }

    final sections = sectionsOf(visible, today, sort: query.sort);
    return SliverPadding(
      padding: padding.copyWith(bottom: 112),
      sliver: SliverMainAxisGroup(
        slivers: [
          for (final section in sections) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: Space.md, bottom: Space.sm),
                child: SectionHeader(
                  switch (section.kind) {
                    SectionKind.awaiting => t.sectionAwaiting,
                    SectionKind.upcoming => t.sectionUpcoming,
                    SectionKind.year => '${section.year}',
                    SectionKind.done => t.sectionDone,
                  },
                  trailing: Text(
                    section.kind == SectionKind.year || section.kind == SectionKind.done
                        ? t.sectionSummary(section.courses.length, formatKm(section.distanceM, decimals: 0))
                        : '${section.courses.length}',
                    style: TextStyles.figure(p.textMuted, size: 16),
                  ),
                ),
              ),
            ),
            SliverList.separated(
              itemCount: section.courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
              itemBuilder: (_, i) => CourseCard(course: section.courses[i], showYear: section.kind != SectionKind.year),
            ),
          ],
        ],
      ),
    );
  }
}

/// Grand écran : tableau de bord à gauche, liste des courses à droite.
class _WideHome extends StatelessWidget {
  final double width;

  const _WideHome({required this.width});

  @override
  Widget build(BuildContext context) {
    final leftWidth = (width * 0.4).clamp(400.0, 560.0);
    return Center(
      child: SizedBox(
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftWidth,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, 0, Space.xl),
                children: const [
                  _Hero(),
                  SizedBox(height: Space.sm),
                  _YearGoal(),
                  _RecapBanner(),
                  SizedBox(height: Space.md),
                  _AwaitingBanner(),
                  _NextRace(),
                  SizedBox(height: Space.lg),
                  _MonthlyBars(),
                ],
              ),
            ),
            const SizedBox(width: Space.lg),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(0, Space.sm, Space.lg, Space.md),
                    sliver: SliverToBoxAdapter(child: _Toolbar()),
                  ),
                  const _CourseSections(padding: EdgeInsets.only(right: Space.lg)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prochaine course inscrite à l'avance, avec son compte à rebours.
class _NextRace extends ConsumerWidget {
  const _NextRace();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider).value;
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    if (today == null) return const SizedBox.shrink();
    final upcoming = courses.where((c) => c.statusOn(today) == CourseStatus.upcoming).toList()
      ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final next = upcoming.first;

    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.course(next.id)),
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker(t.nextRace, color: p.upcoming),
                      const SizedBox(height: Space.xs),
                      Text(next.title.toUpperCase(), style: TextStyles.courseTitle(p.text, size: 22)),
                      Text(
                        '${formatLongDay(next.raceDate)}  ·  ${next.isMultisport ? next.typeLabel(t) : formatKm(next.distanceM)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text('J-${next.raceDate.difference(today).inDays}', style: TextStyles.hero(p.upcoming, size: 52)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Distance courue par mois sur les 12 derniers mois ; un appui ouvre Évolution.
class _MonthlyBars extends ConsumerWidget {
  const _MonthlyBars();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider).value;
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    if (today == null) return const SizedBox.shrink();

    final months = monthlyTotals(courses, DateTime.utc(today.year, today.month - 11), 12);
    if (months.every((m) => m.distanceM == 0)) return const SizedBox.shrink();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.evolution),
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Kicker(t.last12Months, color: p.text)),
                  Icon(Icons.arrow_forward, size: 18, color: p.textMuted),
                ],
              ),
              const SizedBox(height: Space.md),
              BarChart(
                height: 140,
                color: p.chartPrimary,
                format: (v) => '${NumberFormat('#,##0', formatLocale).format(v / 1000)} km',
                valueLabel: (v) => NumberFormat('#,##0', formatLocale).format(v / 1000),
                data: [
                  for (final m in months)
                    BarDatum(
                      axisLabel: formatMonthShort(m.start),
                      tooltip: '${formatMonthYear(m.start)} : ${formatKm(m.distanceM, decimals: 1)}',
                      value: m.distanceM.toDouble(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Volet solidaire, en un seul menu : toutes les courses, les solidaires, ou une cause.
/// Il s'ajoute au type choisi (Officielles / Défis).
class _SolidarityFilter extends ConsumerWidget {
  const _SolidarityFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final query = ref.watch(courseQueryProvider);
    final controller = ref.read(courseQueryProvider.notifier);
    final cause = query.cause;
    final active = query.charityOnly || cause != null;
    // Valeurs du menu : 'all', 'charity' ou le nom d'une cause.
    final current = cause?.name ?? (query.charityOnly ? 'charity' : 'all');
    return PopupMenuButton<String>(
      tooltip: t.filterSolidarity,
      onSelected: (value) => switch (value) {
        'all' => controller.setCharityOnly(false),
        'charity' => controller.setCause(null, charityOnly: true),
        _ => controller.setCause(CauseType.values.byName(value), charityOnly: true),
      },
      itemBuilder: (_) => [
        CheckedPopupMenuItem(value: 'all', checked: current == 'all', child: Text(t.filterSolidarityAll)),
        CheckedPopupMenuItem(value: 'charity', checked: current == 'charity', child: Text(t.filterSolidarityOnly)),
        const PopupMenuDivider(),
        for (final c in CauseType.values)
          CheckedPopupMenuItem(value: c.name, checked: current == c.name, child: Text(c.label(t))),
      ],
      // Le menu reçoit le clic ; la puce n'est qu'un affichage.
      child: IgnorePointer(
        child: FilterChip(
          avatar: Icon(cause?.icon ?? (active ? Icons.favorite : Icons.favorite_outline), size: 16),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  cause?.label(t) ?? (active ? t.filterSolidarityOnly : t.filterSolidarityAll),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
          selected: active,
          onSelected: (_) {},
        ),
      ),
    );
  }
}

/// Ce que montre la liste, en une phrase : « 3 défis solidaires · Environnement & climat ».
String _filterSummary(AppLocalizations t, CourseQuery q, int count) {
  final base = switch (q.kind) {
    CourseKind.all => t.summaryCourses(count),
    CourseKind.official => t.summaryOfficial(count),
    CourseKind.challenge => t.summaryChallenges(count),
    CourseKind.multisport => t.summaryMultisport(count),
  };
  return [
    if (q.charityOnly || q.cause != null) '$base ${t.summarySolidarity(count)}' else base,
    if (q.cause != null) q.cause!.label(t),
    if (q.search.trim().isNotEmpty) '« ${q.search.trim()} »',
  ].join('  ·  ');
}

class _AwaitingBanner extends ConsumerWidget {
  const _AwaitingBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(awaitingResultCountProvider);
    if (count == 0) return const SizedBox.shrink();
    final p = context.palette;
    // En sombre, un grand aplat saturé éblouit : fond teinté et texte d'accent.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? p.accent : p.onAccent;
    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: dark ? p.accent.withValues(alpha: 0.16) : p.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: dark ? BorderSide(color: p.accent.withValues(alpha: 0.5)) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: () {
            // Ouvre directement la (première) course qui attend son résultat.
            final today = ref.read(todayProvider).value;
            final first =
                (ref.read(coursesProvider).value ?? const <Course>[])
                    .where((c) => today != null && c.statusOn(today) == CourseStatus.awaitingResult)
                    .toList()
                  ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
            if (first.isNotEmpty) context.push(Routes.course(first.first.id));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: fg),
                const SizedBox(width: Space.sm),
                Expanded(child: Kicker(AppLocalizations.of(context).awaitingBanner(count), color: fg, size: 16)),
                Icon(Icons.arrow_forward, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final query = ref.watch(courseQueryProvider);
    final controller = ref.read(courseQueryProvider.notifier);
    final count = ref.watch(visibleCoursesProvider).value?.length ?? 0;
    final hasMultisport = ref.watch(coursesProvider.select((list) => list.value?.any((c) => c.isMultisport) ?? false));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          t.navCourses,
          trailing: Text('$count', style: TextStyles.figure(context.palette.textMuted, size: 16)),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: controller.setSearch,
                decoration: InputDecoration(
                  hintText: t.coursesSearch,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: Space.sm),
            PopupMenuButton<Object>(
              tooltip: t.sortTooltip,
              icon: const Icon(Icons.swap_vert),
              onSelected: (value) => value is CourseSort ? controller.setSort(value) : controller.toggleDirection(),
              itemBuilder: (_) => [
                CheckedPopupMenuItem(
                  value: CourseSort.raceDate,
                  checked: query.sort == CourseSort.raceDate,
                  child: Text(t.sortRaceDate),
                ),
                CheckedPopupMenuItem(
                  value: CourseSort.addedDate,
                  checked: query.sort == CourseSort.addedDate,
                  child: Text(t.sortAddedDate),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'direction',
                  child: Row(
                    children: [
                      Icon(query.descending ? Icons.arrow_upward : Icons.arrow_downward, size: 18),
                      const SizedBox(width: Space.sm),
                      Text(query.descending ? t.sortAscending : t.sortDescending),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        // Passe à la ligne au besoin : rien ne déborde, rien à faire défiler.
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            SegmentedButton<CourseKind>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: CourseKind.all, label: Text(t.kindAll)),
                ButtonSegment(value: CourseKind.official, label: Text(t.kindOfficial)),
                ButtonSegment(value: CourseKind.challenge, label: Text(t.kindChallenge)),
                // Proposé seulement à qui a déjà saisi un triathlon, un duathlon ou un aquathlon.
                if (hasMultisport || query.kind == CourseKind.multisport)
                  ButtonSegment(
                    value: CourseKind.multisport,
                    label: Text(t.kindMultisport),
                    tooltip: t.kindMultisportHint,
                  ),
              ],
              selected: {query.kind},
              onSelectionChanged: (s) => controller.setKind(s.first),
            ),
            const _SolidarityFilter(),
          ],
        ),
        if (query.isFiltered) ...[
          const SizedBox(height: Space.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  _filterSummary(t, query, count),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: controller.reset, child: Text(t.filterReset)),
            ],
          ),
        ],
      ],
    );
  }
}
