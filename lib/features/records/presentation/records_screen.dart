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
import '../../courses/domain/course.dart';
import '../../../core/providers.dart';
import '../domain/personal_records.dart';
import '../records_providers.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  /// null = records de tous les temps.
  int? _year;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final years = PersonalRecords.years(courses);
    final year = years.contains(_year) ? _year : null;
    final records = year == null ? ref.watch(personalRecordsProvider) : PersonalRecords.forYear(courses, year);
    final hasAny = !records.isEmpty;

    // Tous les temps, puis chaque année ayant des courses comparables.
    final yearChips = years.length < 2
        ? null
        : Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final y in <int?>[null, ...years])
                ChoiceChip(
                  label: Text(y == null ? t.recordsAllTime : '$y'),
                  selected: year == y,
                  onSelected: (_) => setState(() => _year = y),
                ),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.recordsTitle.toUpperCase()),
        actions: [
          IconButton(
            tooltip: t.galleryTitle,
            onPressed: () => context.push(Routes.gallery),
            icon: const Icon(Icons.photo_library_outlined),
          ),
          const SizedBox(width: Space.sm),
        ],
      ),
      body: !hasAny && year == null
          ? EmptyState(icon: Icons.emoji_events_outlined, message: t.recordsEmpty)
          : ContentWidth(
              maxWidth: kWideMaxWidth,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.xl),
                children: [
                  if (yearChips != null) ...[yearChips, const SizedBox(height: Space.lg)],
                  if (!hasAny) Text(t.recordsEmptyYear(year!), style: Theme.of(context).textTheme.bodyMedium),
                  if (records.byDistance.isNotEmpty) ...[
                    SectionHeader(t.recordsByDistance),
                    const SizedBox(height: Space.md),
                    _PodiumGrid(
                      children: [
                        for (final distance in StandardDistance.values)
                          if (records.byDistance[distance] case final list?)
                            _Podium(
                              title: distance.label(t),
                              courses: list,
                              value: (c) => formatDuration(c.durationS),
                              detail: (c) => formatPace(c.paceSecondsPerKm),
                            ),
                      ],
                    ),
                  ],
                  if (records.multisport.isNotEmpty) ...[
                    if (records.byDistance.isNotEmpty) const SizedBox(height: Space.md),
                    SectionHeader(t.recordsMultisport),
                    const SizedBox(height: Space.md),
                    _PodiumGrid(
                      children: [
                        // Dans l'ordre des épreuves, puis des formats du plus court au plus long.
                        for (final kind in MultisportKind.values)
                          for (final format in MultisportFormat.of(kind))
                            if (records.multisport[(kind: kind, format: format.name)] case final list?)
                              _Podium(
                                title: '${kind.label(t)} ${format.name}',
                                courses: list,
                                value: (c) => formatDuration(c.durationS),
                              ),
                      ],
                    ),
                  ],
                  if (records.bySport.isNotEmpty) ...[
                    if (records.byDistance.isNotEmpty || records.multisport.isNotEmpty)
                      const SizedBox(height: Space.md),
                    SectionHeader(t.recordsBySport),
                    const SizedBox(height: Space.sm),
                    Text(t.recordsBySportHint, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: Space.md),
                    _PodiumGrid(
                      children: [
                        for (final sport in Sport.values)
                          if (records.bySport[sport] case final list?)
                            _Podium(
                              title: sport.label(t),
                              courses: list,
                              value: (c) => formatLegPace(c.multisport!.split(sport)!),
                              detail: (c) => [
                                c.typeLabel(t),
                                formatLegDistance(c.multisport!.split(sport)!),
                                // Rythme un peu sous-estimé : le temps contient aussi la transition.
                                if (c.multisport!.splitIncludesTransition(sport)) t.multisportTransitionIncludedNote,
                                // Chaque élément reste entier à la ligne (« 5 km » ne se coupe pas).
                              ].map((part) => part.replaceAll(' ', ' ')).join('  ·  '),
                            ),
                      ],
                    ),
                  ],
                  _PodiumGrid(
                    children: [
                      if (records.longest.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: Space.md),
                            SectionHeader(t.recordsLongest),
                            const SizedBox(height: Space.md),
                            _Podium(courses: records.longest, value: (c) => formatKm(c.distanceM)),
                          ],
                        ),
                      if (records.highestElevation.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: Space.md),
                            SectionHeader(t.recordsElevation),
                            const SizedBox(height: Space.md),
                            _Podium(courses: records.highestElevation, value: (c) => formatMeters(c.elevationGainM!)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

/// Podiums côte à côte sur grand écran (cartes d'au moins 380 px).
class _PodiumGrid extends StatelessWidget {
  final List<Widget> children;

  const _PodiumGrid({required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // Pas de colonne vide : au plus autant de colonnes que de cartes.
      final perRow = (c.maxWidth / 380).floor().clamp(1, children.isEmpty ? 1 : children.length.clamp(1, 3));
      final width = (c.maxWidth - (perRow - 1) * Space.md) / perRow;
      return Wrap(
        spacing: Space.md,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [for (final child in children) SizedBox(width: width, child: child)],
      );
    },
  );
}

/// Le record en grand, puis les 2e et 3e places.
class _Podium extends StatelessWidget {
  final String? title;
  final List<Course> courses;
  final String Function(Course) value;
  final String Function(Course)? detail;

  const _Podium({this.title, required this.courses, required this.value, this.detail});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final best = courses.first;
    String subtitle(Course c) => [formatDay(c.raceDate), if (detail != null) detail!(c)].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => context.push(Routes.course(best.id)),
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[Kicker(title!, color: p.accent, size: 15), const SizedBox(height: Space.sm)],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(value(best), style: TextStyles.hero(p.text, size: 64)),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(best.title.toUpperCase(), style: TextStyles.courseTitle(p.text, size: 18)),
                    Text(subtitle(best), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            for (final (i, c) in courses.skip(1).take(2).indexed) ...[
              Divider(height: 1, color: p.border),
              InkWell(
                onTap: () => context.push(Routes.course(c.id)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 28, child: Text('${i + 2}', style: TextStyles.figure(p.textMuted, size: 22))),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.courseTitle(p.text, size: 16),
                            ),
                            Text(subtitle(c), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Text(value(c), style: TextStyles.figure(p.text, size: 22)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
