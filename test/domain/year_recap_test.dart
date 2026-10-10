import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/evolution/domain/year_recap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final courses = [
    Course(
      id: 'a',
      title: '10 km de Valfleuri',
      raceDate: calendarDate(2026, 5, 17),
      distanceM: 10000,
      durationS: 2900,
    ),
    Course(
      id: 'b',
      title: '10 km de Bois-Joli',
      raceDate: calendarDate(2025, 10, 12),
      distanceM: 10000,
      durationS: 3010,
    ),
    Course(
      id: 'c',
      title: 'Trail des Monts Imaginaires',
      raceDate: calendarDate(2026, 6, 14),
      distanceM: 23400,
      durationS: 9000,
      elevationGainM: 640,
      isCharity: true,
      associationName: 'Les Amis de Démoville',
      registrationDonationCents: 2000,
    ),
    Course(
      id: 'd',
      title: 'La Course du Cœur',
      raceDate: calendarDate(2026, 9, 20),
      distanceM: 10000,
      durationS: 3150,
      isCharity: true,
      associationName: 'les amis de démoville ',
      sponsorCentsPerKm: 150,
    ),
    Course(
      id: 'tri',
      title: 'Triathlon de Démoville',
      raceDate: calendarDate(2026, 4, 12),
      type: CourseType.multisport,
      distanceM: 6700,
      durationS: 1680,
      multisport: Multisport(
        kind: MultisportKind.triathlon,
        format: 'XXS',
        legs: const [
          Leg(sport: Sport.swim, distanceM: 200, durationS: 420),
          Leg(sport: Sport.bike, distanceM: 5000, durationS: 780),
          Leg(sport: Sport.run, distanceM: 1500, durationS: 480),
        ],
      ),
    ),
    Course(id: 'e', title: 'Marathon', raceDate: calendarDate(2026, 11, 8), distanceM: 42195, isPlanned: true),
  ];

  test('bilan : courses terminées de l\'année, km courus, dons, records', () {
    final recap = YearRecap.of(courses, 2026);
    expect(recap.stats.count, 4);
    // 10 + 23,4 + 10 km, plus les 1,5 km à pied du triathlon ; le marathon à venir ne compte pas.
    expect(recap.stats.distanceM, 44900);
    expect(recap.stats.elevationGainM, 640);
    expect(recap.longest!.id, 'c');
    expect(recap.multisportCount, 1);
    expect(recap.donationCents, 3500);
    expect(recap.associations, 1, reason: 'même association, écrite différemment');
    // Record du 10 km (a devant b et d) et plus longue distance (c). Un seul dénivelé : pas de record.
    expect(recap.records, 2);
    expect(recap.isEmpty, isFalse);
  });

  test('année sans course : bilan vide ; années disponibles', () {
    expect(YearRecap.of(courses, 2024).isEmpty, isTrue);
    expect(YearRecap.years(courses), [2026, 2025]);
  });

  test('mise en avant : décembre pour l\'année en cours, janvier pour l\'année écoulée', () {
    expect(YearRecap.featuredYear(calendarDate(2026, 12, 1)), 2026);
    expect(YearRecap.featuredYear(calendarDate(2027, 1, 31)), 2026);
    expect(YearRecap.featuredYear(calendarDate(2026, 10, 8)), isNull);
    expect(YearRecap.featuredYear(calendarDate(2027, 2, 1)), isNull);
  });
}
