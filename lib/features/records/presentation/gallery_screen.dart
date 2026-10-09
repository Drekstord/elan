import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/domain/course.dart';
import '../domain/gallery.dart';

/// Mosaïque des médailles et dossards, par année. Appui : la course ; appui long : plein écran.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  GalleryFilter _filter = GalleryFilter.all;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final photos = galleryOf(courses, filter: _filter);

    // Regroupement par année (l'ordre, du plus récent au plus ancien, est conservé).
    final byYear = <int, List<GalleryPhoto>>{};
    for (final photo in photos) {
      (byYear[photo.course.raceDate.year] ??= []).add(photo);
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.galleryTitle.toUpperCase())),
      body: ContentWidth(
        maxWidth: kWideMaxWidth,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.md),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: Space.sm,
                  runSpacing: Space.sm,
                  children: [
                    for (final (filter, label, icon) in [
                      (GalleryFilter.all, t.galleryAll, Icons.photo_library_outlined),
                      (GalleryFilter.medals, t.galleryMedals, Icons.military_tech_outlined),
                      (GalleryFilter.bibs, t.galleryBibs, Icons.confirmation_number_outlined),
                    ])
                      ChoiceChip(
                        avatar: Icon(icon, size: 16),
                        label: Text(label),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                  ],
                ),
              ),
            ),
            if (photos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(icon: Icons.photo_library_outlined, message: t.galleryEmpty),
              ),
            for (final MapEntry(key: year, value: list) in byYear.entries) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.sm),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    '$year',
                    trailing: Text(
                      t.galleryCount(list.length),
                      style: TextStyles.figure(context.palette.textMuted, size: 16),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.md),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: Space.sm,
                    crossAxisSpacing: Space.sm,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _Tile(photo: list[i]),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: Space.xl)),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final GalleryPhoto photo;

  const _Tile({required this.photo});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Semantics(
      label: '${photo.isMedal ? t.formMedal : t.formBib}, ${photo.course.title}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.md),
        child: Material(
          color: context.palette.surface,
          child: InkWell(
            onTap: () => context.push(Routes.course(photo.course.id)),
            onLongPress: () => showPhoto(
              context,
              photo.key,
              label: '${photo.isMedal ? t.formMedal : t.formBib}, ${photo.course.title}',
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CoursePhoto(photoKey: photo.key, thumbnail: true),
                // Bandeau bas : nom de la course, lisible sur n'importe quelle photo.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(Space.sm, Space.lg, Space.sm, Space.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.75)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          photo.isMedal ? Icons.military_tech : Icons.confirmation_number,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: Space.xs),
                        Expanded(
                          child: Text(
                            photo.course.title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.kicker(Colors.white, size: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
