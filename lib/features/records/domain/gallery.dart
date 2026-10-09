import '../../courses/domain/course.dart';

enum GalleryFilter { all, medals, bibs }

/// Une photo de la galerie : médaille ou dossard, et sa course.
class GalleryPhoto {
  final Course course;
  final String key;
  final bool isMedal;

  const GalleryPhoto(this.course, this.key, {required this.isMedal});
}

/// Photos des courses (non supprimées), de la course la plus récente à la plus ancienne ;
/// pour une même course, la médaille avant le dossard.
List<GalleryPhoto> galleryOf(Iterable<Course> courses, {GalleryFilter filter = GalleryFilter.all}) {
  final sorted = courses.where((c) => !c.isDeleted).toList()..sort((a, b) => b.raceDate.compareTo(a.raceDate));
  return [
    for (final c in sorted) ...[
      if (c.medalPhotoKey != null && filter != GalleryFilter.bibs) GalleryPhoto(c, c.medalPhotoKey!, isMedal: true),
      if (c.bibPhotoKey != null && filter != GalleryFilter.medals) GalleryPhoto(c, c.bibPhotoKey!, isMedal: false),
    ],
  ];
}
