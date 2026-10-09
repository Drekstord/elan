import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/records/domain/personal_records.dart';
import 'package:flutter_test/flutter_test.dart';

Course race(
  String id,
  int distanceM,
  int durationS, {
  int? elevation,
  bool planned = false,
  CourseType type = CourseType.officialRace,
  int day = 1,
}) => Course(
  id: id,
  title: id,
  raceDate: calendarDate(2026, 1, day),
  distanceM: distanceM,
  durationS: durationS,
  elevationGainM: elevation,
  isPlanned: planned,
  type: type,
);

void main() {
  test('distances de référence avec tolérance de mesure', () {
    expect(StandardDistance.of(10150), StandardDistance.tenK);
    expect(StandardDistance.of(21300), StandardDistance.halfMarathon);
    expect(StandardDistance.of(42600), StandardDistance.marathon);
    expect(StandardDistance.of(15000), isNull);
  });

  test('records par distance : un 5 km rapide n\'éclipse pas le marathon', () {
    final records = PersonalRecords.compute([
      race('5k-lent', 5000, 1500),
      race('5k-rapide', 5020, 1290),
      race('10k', 10100, 2900),
      race('marathon', 42195, 13500, elevation: 250),
      race('trail', 30000, 12000, elevation: 1400),
      race('a-venir', 10000, 0, planned: true),
      race('defi', 145000, 0, type: CourseType.theConqueror),
    ]);
    expect(records.byDistance[StandardDistance.fiveK]!.map((c) => c.id), ['5k-rapide', '5k-lent']);
    expect(records.byDistance[StandardDistance.tenK]!.single.id, '10k');
    expect(records.byDistance[StandardDistance.marathon]!.single.id, 'marathon');
    expect(records.longest.first.id, 'marathon'); // le défi virtuel est exclu
    expect(records.highestElevation.first.id, 'trail');
  });

  test('badge record : seulement face à au moins une autre course comparable', () {
    final a = race('a', 10000, 2900);
    final b = race('b', 10000, 3100);
    final solo = race('solo', 21097, 6000);
    final records = PersonalRecords.compute([a, b, solo]);
    expect(records.heldBy(a), contains(const DistanceRecord(StandardDistance.tenK)));
    expect(records.heldBy(b), isEmpty);
    expect(records.heldBy(solo), {const LongestRecord()}); // seul semi, mais plus longue course
  });

  test('égalité de temps : la plus ancienne garde le record', () {
    final records = PersonalRecords.compute([race('recent', 5000, 1300, day: 20), race('ancien', 5000, 1300, day: 2)]);
    expect(records.byDistance[StandardDistance.fiveK]!.first.id, 'ancien');
  });

  test("records par année : seules les courses de l'année comptent", () {
    final courses = [
      Course(id: 'vieux', title: 'v', raceDate: calendarDate(2025, 5, 1), distanceM: 10000, durationS: 2700),
      Course(id: 'recent', title: 'r', raceDate: calendarDate(2026, 5, 1), distanceM: 10000, durationS: 2900),
      Course(id: 'r2', title: 'r2', raceDate: calendarDate(2026, 9, 1), distanceM: 10050, durationS: 3000),
      Course(
        id: 'defi',
        title: 'd',
        type: CourseType.theConqueror,
        raceDate: calendarDate(2024, 1, 1),
        distanceM: 50000,
      ),
    ];
    expect(PersonalRecords.compute(courses).byDistance[StandardDistance.tenK]!.first.id, 'vieux');
    expect(PersonalRecords.forYear(courses, 2026).byDistance[StandardDistance.tenK]!.map((c) => c.id), [
      'recent',
      'r2',
    ]);
    expect(PersonalRecords.forYear(courses, 2024).byDistance, isEmpty);
    // Les défis ne comptent pas : 2024 n'est pas proposée.
    expect(PersonalRecords.years(courses), [2026, 2025]);
  });
}
