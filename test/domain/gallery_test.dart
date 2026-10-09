import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/records/domain/gallery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final courses = [
    Course(id: 'a', title: 'A', raceDate: calendarDate(2025, 5, 1), distanceM: 1, medalPhotoKey: 'm-a'),
    Course(
      id: 'b',
      title: 'B',
      raceDate: calendarDate(2026, 5, 1),
      distanceM: 1,
      medalPhotoKey: 'm-b',
      bibPhotoKey: 'd-b',
    ),
    Course(id: 'c', title: 'C', raceDate: calendarDate(2026, 6, 1), distanceM: 1),
    Course(
      id: 'x',
      title: 'X',
      raceDate: calendarDate(2026, 7, 1),
      distanceM: 1,
      medalPhotoKey: 'm-x',
      deletedAt: DateTime.utc(2026, 7, 2),
    ),
  ];

  test('galerie : plus récente d\'abord, médaille avant dossard, courses supprimées exclues', () {
    expect(galleryOf(courses).map((p) => p.key), ['m-b', 'd-b', 'm-a']);
    expect(galleryOf(courses, filter: GalleryFilter.medals).map((p) => p.key), ['m-b', 'm-a']);
    expect(galleryOf(courses, filter: GalleryFilter.bibs).map((p) => p.key), ['d-b']);
    expect(galleryOf(courses).first.isMedal, isTrue);
  });
}
