import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/charts.dart';
import '../../../app/widgets/common.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/course_query.dart';
import '../../courses/domain/course_stats.dart';
import '../../courses/presentation/multisport_view.dart';
import '../domain/evolution_range.dart';

/// Évolution sportive : un bilan chiffré de la période, puis les graphiques qui le détaillent.
/// Les dons sont dans l'onglet Impact.
class EvolutionScreen extends ConsumerStatefulWidget {
  const EvolutionScreen({super.key});

  @override
  ConsumerState<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends ConsumerState<EvolutionScreen> {
  RangeKind _range = RangeKind.last12Months;
  int? _year;
  CourseKind _kind = CourseKind.all;
  bool _table = false;

  /// Barre sélectionnée (index dans la série affichée).
  int? _selected;

  void _update(VoidCallback change) => setState(() {
    change();
    _selected = null;
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final today = ref.watch(todayProvider).value ?? DateTime.now().toUtc();
    final all = ref.watch(coursesProvider).value ?? const <Course>[];
    final courses = all.where((c) => c.isCompleted && _kind.matches(c)).toList();
    final years = EvolutionRange.availableYears(all, today);
    final year = (_year ?? today.year).clamp(years.first, years.last);
    final range = EvolutionRange(_range, year: year);
    final totals = range.totals(courses, today);
    final inRange = range.coursesIn(courses, today);

    final controls = Wrap(
      spacing: Space.md,
      runSpacing: Space.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<RangeKind>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: RangeKind.last12Months,
              label: Text(MediaQuery.sizeOf(context).width < 600 ? t.rangeLast12Short : t.rangeLast12),
            ),
            ButtonSegment(value: RangeKind.year, label: Text(t.rangeByMonth)),
            ButtonSegment(value: RangeKind.allYears, label: Text(t.rangeByYear)),
          ],
          selected: {_range},
          onSelectionChanged: (s) => _update(() => _range = s.first),
        ),
        if (_range == RangeKind.year)
          _YearStepper(
            year: year,
            onPrevious: year > years.first ? () => _update(() => _year = year - 1) : null,
            onNext: year < years.last ? () => _update(() => _year = year + 1) : null,
          ),
        SegmentedButton<CourseKind>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: CourseKind.all, label: Text(t.kindAll)),
            ButtonSegment(value: CourseKind.official, label: Text(t.kindOfficial)),
            ButtonSegment(value: CourseKind.challenge, label: Text(t.kindChallenge)),
            // Proposé seulement à qui a déjà terminé une épreuve enchaînée.
            if (_kind == CourseKind.multisport || all.any((c) => c.isCompleted && c.isMultisport))
              ButtonSegment(value: CourseKind.multisport, label: Text(t.kindMultisport), tooltip: t.kindMultisportHint),
          ],
          selected: {_kind},
          onSelectionChanged: (s) => _update(() => _kind = s.first),
        ),
      ],
    );

    final byYear = _range == RangeKind.allYears;
    final selected = _selected == null || _selected! >= totals.length ? null : totals[_selected!];
    final paced = pacedRaces(inRange);
    final splits = {
      for (final sport in Sport.values)
        if (splitRaces(inRange, sport) case final races when races.length >= 2) sport: races,
    };
    final cumulYear = _range == RangeKind.year ? year : today.year;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.evolutionTitle.toUpperCase()),
        actions: [
          IconButton(
            tooltip: _table ? t.viewChart : t.viewTable,
            onPressed: () => setState(() => _table = !_table),
            icon: Icon(_table ? Icons.bar_chart : Icons.table_rows_outlined),
          ),
          const SizedBox(width: Space.sm),
        ],
      ),
      body: all.every((c) => !c.isCompleted)
          ? EmptyState(icon: Icons.insights_outlined, message: t.chartEmpty)
          : ContentWidth(
              maxWidth: kWideMaxWidth,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.xl),
                children: [
                  controls,
                  const SizedBox(height: Space.lg),
                  _Summary(range: range, courses: courses, inRange: inRange, today: today),
                  const SizedBox(height: Space.md),
                  if (inRange.any((c) => c.isMultisport)) ...[
                    _SportsSummary(range: range, courses: courses, inRange: inRange, today: today),
                    const SizedBox(height: Space.md),
                  ],
                  if (_table)
                    _PeriodTable(totals: totals, byYear: byYear)
                  else
                    _ChartGrid(
                      children: [
                        _ChartCard(
                          title: byYear ? t.chartKmByYear : t.chartKmByMonth,
                          subtitle: t.chartKmHint,
                          legend: ChartLegend([(LegendMark.bar, context.palette.chartPrimary, t.legendDistance, null)]),
                          children: [
                            BarChart(
                              color: context.palette.chartPrimary,
                              format: (v) => '${NumberFormat('#,##0', 'fr').format(v / 1000)} km',
                              valueLabel: (v) => NumberFormat('#,##0', 'fr').format(v / 1000),
                              selected: _selected,
                              onSelect: (i) => setState(() => _selected = _selected == i ? null : i),
                              data: [
                                for (final p in totals)
                                  BarDatum(
                                    axisLabel: byYear ? '${p.start.year}' : formatMonthShort(p.start),
                                    tooltip:
                                        '${_periodLabel(p.start, byYear)} : ${formatKm(p.distanceM, decimals: 1)}'
                                        ' · ${t.periodCount(p.count)}',
                                    value: p.distanceM.toDouble(),
                                  ),
                              ],
                            ),
                            if (selected != null) ...[
                              const SizedBox(height: Space.md),
                              _PeriodCourses(title: _periodLabel(selected.start, byYear), total: selected),
                            ],
                          ],
                        ),
                        if (!byYear)
                          _ChartCard(
                            title: t.chartCumulativeTitle(cumulYear),
                            subtitle: t.chartCumulativeHint,
                            children: [_CumulativeChart(courses: courses, year: cumulYear, today: today)],
                          ),
                        if (paced.length >= 2)
                          _ChartCard(
                            title: t.chartPaceTitle,
                            subtitle: t.chartPaceHint,
                            legend: ChartLegend([(LegendMark.dot, context.palette.chartPrimary, t.legendPace, null)]),
                            children: [_PaceChart(races: paced)],
                          ),
                        if (splits.isNotEmpty) _SportChartCard(splits: splits),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  static String _periodLabel(DateTime d, bool byYear) => byYear ? '${d.year}' : formatMonthYear(d);
}

class _YearStepper extends StatelessWidget {
  final int year;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _YearStepper({required this.year, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
      Text('$year', style: TextStyles.figure(context.palette.text, size: 22)),
      IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
    ],
  );
}

/// Bilan de la période en clair : chiffres clés et variation par rapport à la période précédente.
class _Summary extends StatelessWidget {
  final EvolutionRange range;
  final List<Course> courses;
  final List<Course> inRange;
  final DateTime today;

  const _Summary({required this.range, required this.courses, required this.inRange, required this.today});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final stats = CourseStats.of(inRange);
    final previous = range.previousWindow(today);
    final before = previous == null ? null : CourseStats.of(completedBetween(courses, previous.$1, previous.$2));
    final firstYear = courses.isEmpty
        ? today.year
        : courses.map((c) => c.raceDate.year).reduce((a, b) => a < b ? a : b);

    final title = switch (range.kind) {
      RangeKind.last12Months => t.summaryLast12,
      RangeKind.year => t.summaryYear(range.year),
      RangeKind.allYears => t.summaryAll(firstYear),
    };
    final compare = switch (previous?.$3) {
      CompareKind.previous12Months => t.compareLast12,
      CompareKind.previousYearToDate => t.compareYearToDate(range.year - 1, DateFormat('d MMMM', 'fr').format(today)),
      CompareKind.previousYear => t.compareYear(range.year - 1),
      null => null,
    };

    Widget tile(String label, String value, int? now, int? then) {
      final delta = (now == null || then == null) ? null : _Delta.of(now, then);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatTile(label: label, value: value),
          ?delta,
        ],
      );
    }

    return SectionCard(
      title: title,
      children: [
        if (stats.count == 0)
          Text(t.periodEmpty, style: Theme.of(context).textTheme.bodyMedium)
        else
          StatGrid(
            minTileWidth: 96,
            tiles: [
              tile(t.statRaces, '${stats.count}', stats.count, before?.count),
              tile(t.statDistance, formatKm(stats.distanceM, decimals: 0), stats.distanceM, before?.distanceM),
              tile(t.statTime, formatLongDuration(stats.durationS), stats.durationS, before?.durationS),
              tile(t.statElevation, formatMeters(stats.elevationGainM), stats.elevationGainM, before?.elevationGainM),
              tile(t.statPace, formatPace(stats.averagePaceSecondsPerKm), null, null),
            ],
          ),
        if (compare != null && stats.count > 0) ...[
          const SizedBox(height: Space.md),
          Text(compare, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted)),
        ],
      ],
    );
  }
}

/// Les épreuves enchaînées de la période, discipline par discipline : distance et temps cumulés.
class _SportsSummary extends StatelessWidget {
  final EvolutionRange range;
  final List<Course> courses;
  final List<Course> inRange;
  final DateTime today;

  const _SportsSummary({required this.range, required this.courses, required this.inRange, required this.today});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted);
    final totals = sportTotals(inRange);
    final previous = range.previousWindow(today);
    final before = previous == null ? null : completedBetween(courses, previous.$1, previous.$2);
    final totalsBefore = before == null ? null : sportTotals(before);
    final count = inRange.where((c) => c.isMultisport).length;
    final countBefore = before?.where((c) => c.isMultisport).length;

    Widget tile(String label, String value, int now, int? then, {String? note, IconData? icon, Color? color}) =>
        MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: color), const SizedBox(height: Space.xs)],
              StatTile(label: label, value: value),
              if (note != null) Text(note, style: small?.copyWith(fontFeatures: Fonts.tabular)),
              ?(then == null ? null : _Delta.of(now, then)),
            ],
          ),
        );

    return SectionCard(
      title: t.evolutionSportsTitle,
      children: [
        Text(t.evolutionSportsHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: Space.md),
        StatGrid(
          minTileWidth: 110,
          tiles: [
            tile(t.evolutionSportsEvents, '$count', count, countBefore, icon: Icons.flag_outlined, color: p.textMuted),
            for (final sport in Sport.values)
              if (totals[sport] case final total?)
                tile(
                  sport.label(t),
                  sport == Sport.swim ? formatMeters(total.distanceM) : formatKm(total.distanceM, decimals: 1),
                  total.distanceM,
                  totalsBefore == null ? null : (totalsBefore[sport]?.distanceM ?? 0),
                  note: total.durationS > 0 ? formatLongDuration(total.durationS) : null,
                  icon: sport.icon,
                  color: sportColor(sport, p),
                ),
          ],
        ),
      ],
    );
  }
}

/// Rythme d'une discipline d'une épreuve enchaînée à l'autre. Une discipline se choisit
/// dès que plusieurs ont assez de points.
class _SportChartCard extends StatefulWidget {
  /// Par discipline, les épreuves chronométrées (au moins deux), dans l'ordre chronologique.
  final Map<Sport, List<Course>> splits;

  const _SportChartCard({required this.splits});

  @override
  State<_SportChartCard> createState() => _SportChartCardState();
}

class _SportChartCardState extends State<_SportChartCard> {
  Sport? _sport;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final sports = widget.splits.keys.toList();
    final sport = sports.contains(_sport) ? _sport! : sports.first;
    final races = widget.splits[sport]!;
    final color = sportColor(sport, p);
    final note = t.multisportTransitionIncludedNote;

    double day(DateTime d) => d.millisecondsSinceEpoch / Duration.millisecondsPerDay;
    final first = races.first.raceDate;
    final last = races.last.raceDate;
    final years = last.year - first.year;

    return _ChartCard(
      title: t.chartSportTitle,
      subtitle: switch (sport) {
        Sport.swim => t.chartSportHintSwim,
        Sport.bike => t.chartSportHintBike,
        Sport.run => t.chartSportHintRun,
      },
      legend: ChartLegend([(LegendMark.dot, color, '${t.legendSport} · ${sport.label(t)}', null)]),
      children: [
        if (sports.length > 1) ...[
          SegmentedButton<Sport>(
            showSelectedIcon: false,
            segments: [for (final s in sports) ButtonSegment(value: s, label: Text(s.label(t)))],
            selected: {sport},
            onSelectionChanged: (s) => setState(() => _sport = s.first),
          ),
          const SizedBox(height: Space.md),
        ],
        DotChart(
          color: color,
          // À vélo, la vitesse : le plus haut est le plus rapide sans rien inverser.
          invertY: sport != Sport.bike,
          step: sport == Sport.bike ? 2 : 15,
          minX: day(first) - 10,
          maxX: day(last) + 10,
          xTicks: [
            (day(first), years == 0 ? formatMonthShort(first) : '${first.year}'),
            if (day(last) - day(first) > 45) (day(last), years == 0 ? formatMonthShort(last) : '${last.year}'),
          ],
          // Axe compact ; l'infobulle garde l'unité.
          formatY: (v) => switch (sport) {
            Sport.swim => formatSwimPace(v).replaceAll(' /100 m', ''),
            Sport.bike => formatSpeed(v).replaceAll(' km/h', ''),
            Sport.run => formatPace(v).replaceAll(' /km', ''),
          },
          data: [
            for (final c in races)
              if (c.multisport!.split(sport) case final leg?)
                DotDatum(
                  x: day(c.raceDate),
                  y: sport == Sport.bike ? leg.speedKmh! : leg.effort!,
                  tooltipTitle: '${c.title} · ${formatDay(c.raceDate)}',
                  tooltipValue: [
                    formatLegPace(leg),
                    formatLegDistance(leg),
                    if (c.multisport!.splitIncludesTransition(sport)) note,
                  ].join(' · '),
                ),
          ],
        ),
      ],
    );
  }
}

/// Variation sous un chiffre : flèche + pourcentage, en couleur de texte.
class _Delta extends StatelessWidget {
  final int? percent;
  final bool isNew;

  const _Delta._(this.percent, {this.isNew = false});

  static Widget? of(int now, int then) {
    if (now == 0 && then == 0) return null;
    if (then == 0) return const _Delta._(null, isNew: true);
    return _Delta._(percentChange(now, then));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final pct = percent ?? 0;
    final icon = isNew || pct > 0
        ? Icons.arrow_upward
        : pct < 0
        ? Icons.arrow_downward
        : Icons.drag_handle;
    // Au-delà du triple, un multiplicateur parle mieux qu'un pourcentage (« ×20 »).
    final text = isNew
        ? t.deltaNew
        : pct >= 200
        ? '×${NumberFormat('#,##0.#', 'fr').format(1 + pct / 100)}'
        : '${pct > 0
              ? '+'
              : pct < 0
              ? '−'
              : ''}${pct.abs()} %';
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: p.textMuted),
          const SizedBox(width: 2),
          // Se réduit plutôt que de déborder (colonnes étroites, textes agrandis).
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(text, style: TextStyles.figure(p.textMuted, size: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Deux cartes par rangée sur grand écran, une sur téléphone.
class _ChartGrid extends StatelessWidget {
  final List<Widget> children;

  const _ChartGrid({required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final perRow = c.maxWidth >= 900 ? 2 : 1;
      final width = (c.maxWidth - (perRow - 1) * Space.md) / perRow;
      return Wrap(
        spacing: Space.md,
        runSpacing: Space.md,
        children: [for (final child in children) SizedBox(width: width, child: child)],
      );
    },
  );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? legend;
  final List<Widget> children;

  const _ChartCard({required this.title, this.subtitle, this.legend, required this.children});

  @override
  Widget build(BuildContext context) => SectionCard(
    title: title,
    children: [
      if (subtitle != null) ...[
        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: Space.md),
      ],
      if (legend != null) ...[legend!, const SizedBox(height: Space.md)],
      ...children,
    ],
  );
}

/// Les courses d'une barre sélectionnée.
class _PeriodCourses extends StatelessWidget {
  final String title;
  final PeriodTotal total;

  const _PeriodCourses({required this.title, required this.total});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final list = [...total.courses]..sort((a, b) => a.raceDate.compareTo(b.raceDate));
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      padding: const EdgeInsets.only(top: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Kicker(title, color: p.text, size: 14)),
              Text(
                total.count == 0 ? '' : '${t.periodCount(total.count)} · ${formatKm(total.distanceM, decimals: 1)}',
                style: TextStyles.figure(p.text, size: 15),
              ),
            ],
          ),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Space.sm),
              child: Text(t.periodEmpty, style: Theme.of(context).textTheme.bodySmall),
            ),
          for (final c in list)
            InkWell(
              onTap: () => context.push(Routes.course(c.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        DateFormat('d MMM', 'fr').format(c.raceDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    Text(
                      [formatKm(c.runDistanceM, decimals: 1), if (c.hasTime) formatDuration(c.durationS)].join('  ·  '),
                      style: TextStyles.figure(p.text, size: 15),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Année affichée contre l'année précédente, jour par jour.
class _CumulativeChart extends StatelessWidget {
  final List<Course> courses;
  final int year;
  final DateTime today;

  const _CumulativeChart({required this.courses, required this.year, required this.today});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final current = year == today.year;
    final endDay = current ? today.difference(DateTime.utc(year)).inDays + 1 : 366;
    List<(double, double)> points(int y) => [
      for (final (d, m) in cumulativeDistance(courses, y)) (d.toDouble(), m.toDouble()),
    ];

    return StepLineChart(
      maxX: 366,
      series: [
        LineSeries(
          name: '$year',
          color: p.chartPrimary,
          points: points(year),
          endX: endDay.toDouble(),
          note: current ? t.cumulativeAt(DateFormat('d MMM', 'fr').format(today)) : t.cumulativeYear,
        ),
        LineSeries(
          name: '${year - 1}',
          color: p.chartCompare,
          points: points(year - 1),
          endX: 366,
          note: t.cumulativeYear,
        ),
      ],
      formatY: (v) => '${NumberFormat('#,##0', 'fr').format(v / 1000)} km',
      formatX: (x) => DateFormat('d MMMM', 'fr').format(DateTime.utc(year).add(Duration(days: x.round() - 1))),
      xTicks: [
        for (var m = 1; m <= 12; m++)
          (DateTime.utc(year, m).difference(DateTime.utc(year)).inDays + 1.0, formatMonthShort(DateTime.utc(year, m))),
      ],
    );
  }
}

class _PaceChart extends StatelessWidget {
  final List<Course> races;

  const _PaceChart({required this.races});

  @override
  Widget build(BuildContext context) {
    double day(DateTime d) => d.millisecondsSinceEpoch / Duration.millisecondsPerDay;
    final first = races.first.raceDate;
    final last = races.last.raceDate;
    final months = (last.year - first.year) * 12 + last.month - first.month;
    // Tous les mois sur un an ou moins, sinon un trimestre sur deux… : ~12 graduations au plus.
    final step = months <= 12 ? 1 : (months <= 24 ? 2 : (months <= 48 ? 3 : 12));
    final ticks = <(double, String)>[
      for (
        var m = DateTime.utc(first.year, first.month + 1);
        !m.isAfter(last);
        m = DateTime.utc(m.year, m.month + step)
      )
        if (step < 12 || m.month == 1) (day(m), m.month == 1 && step > 1 ? '${m.year}' : formatMonthShort(m)),
    ];
    return DotChart(
      color: context.palette.chartPrimary,
      invertY: true,
      minX: day(first) - 10,
      maxX: day(last) + 10,
      xTicks: ticks,
      // Axe compact (« 4'30" ») ; l'infobulle garde l'unité.
      formatY: (v) => formatPace(v).replaceAll(' /km', ''),
      data: [
        for (final c in races)
          DotDatum(
            x: day(c.raceDate),
            y: c.paceSecondsPerKm!,
            tooltipTitle: '${c.title} · ${formatDay(c.raceDate)}',
            tooltipValue: '${formatPace(c.paceSecondsPerKm)} · ${formatKm(c.distanceM, decimals: 1)}',
          ),
      ],
    );
  }
}

/// Les mêmes données en tableau (lisible sans couleur, copiable).
class _PeriodTable extends StatelessWidget {
  final List<PeriodTotal> totals;
  final bool byYear;

  const _PeriodTable({required this.totals, required this.byYear});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final head = TextStyles.kicker(p.textMuted, size: 12);
    final num = TextStyles.figure(p.text, size: 18);
    final muted = TextStyles.figure(p.textMuted, size: 18);
    Widget cell(String text, TextStyle style, {bool right = true}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: Space.sm),
      child: Text(text, textAlign: right ? TextAlign.right : TextAlign.left, style: style),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.sm),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.6),
            4: FlexColumnWidth(1.2),
          },
          border: TableBorder(horizontalInside: BorderSide(color: p.border)),
          children: [
            TableRow(
              children: [
                cell(t.tablePeriod.toUpperCase(), head, right: false),
                cell(t.tableRaces.toUpperCase(), head),
                cell(t.statDistance.toUpperCase(), head),
                cell(t.detailTime.toUpperCase(), head),
                cell('D+', head),
              ],
            ),
            for (final row in totals.reversed)
              TableRow(
                children: [
                  cell(
                    _EvolutionScreenState._periodLabel(row.start, byYear),
                    Theme.of(context).textTheme.titleSmall!,
                    right: false,
                  ),
                  cell('${row.count}', row.count == 0 ? muted : num),
                  cell(row.count == 0 ? '–' : formatKm(row.distanceM, decimals: 1), row.count == 0 ? muted : num),
                  cell(
                    row.stats.durationS == 0 ? '–' : formatLongDuration(row.stats.durationS),
                    row.count == 0 ? muted : num,
                  ),
                  cell(
                    row.stats.elevationGainM == 0 ? '–' : formatMeters(row.stats.elevationGainM),
                    row.count == 0 ? muted : num,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
