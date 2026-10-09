import 'package:app_course/core/legacy/legacy_import.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conversion v1 : unités entières, date sans heure, champs solidaires', () {
    final c = LegacyImport.fromV1({
      'id': 'semi-1',
      'title': 'Semi solidaire',
      'date': '2026-04-12T00:00:00.000',
      'created_at': '2026-04-13T10:00:00.000Z',
      'distance_km': 21.0975,
      'duration_seconds': 5400,
      'elevation_gain': 120,
      'is_charity': true,
      'association_name': 'Les Restos du Cœur',
      'association_cause': 'precarite',
      'sponsored_euro_per_km': 0.5,
      'registration_fee_donated': 15.0,
      'impact_metric': 'meals',
      'impact_rate_per_km': 0.5,
    });
    expect(c.distanceM, 21098);
    expect(c.raceDate, calendarDate(2026, 4, 12));
    expect(c.sponsorCentsPerKm, 50);
    expect(c.registrationDonationCents, 1500);
    expect(c.associationCause, CauseType.precarite);
    // Équivalence v1 calculée au km (0,5 repas/km) : fictive, donc abandonnée.
    expect(c.impactMetric, ImpactMetric.euroDirect);
    expect(c.impactQuantity, isNull);
  });

  test('conversion v1 : course officielle sans volet solidaire', () {
    final c = LegacyImport.fromV1({
      'id': 'essec',
      'title': 'Essec Night Run',
      'date': '2026-02-13T00:00:00.000',
      'distance_km': 16.18,
      'duration_seconds': 7873,
      'is_charity': false,
      'association_name': 'Ne doit pas rester',
      'registration_fee_donated': 45.0,
    });
    expect(c.isCharity, isFalse);
    expect(c.associationName, isNull);
    expect(c.registrationDonationCents, 0);
  });

  test('conversion v1 : arbres retirés hors programme officiel, gardés pour The Conqueror', () {
    final course = LegacyImport.fromV1({
      'id': 'solidaire',
      'title': 'Octobre Solidaire',
      'date': '2026-10-06T00:00:00.000',
      'distance_km': 7.3,
      'is_charity': true,
      'association_cause': 'handicap',
      'impact_metric': 'trees',
      'custom_impact_quantity': 3.0,
      'registration_fee_donated': 10.0,
    });
    expect(course.associationCause, CauseType.handicap);
    expect(course.impactMetric, ImpactMetric.euroDirect);
    expect(course.impactQuantity, isNull);
    expect(course.registrationDonationCents, 1000);

    final conqueror = LegacyImport.fromV1({
      'id': 'tc',
      'title': 'The Conqueror - Grand Défi',
      'date': '2026-10-06T00:00:00.000',
      'distance_km': 72.5,
      'course_type': 'theConqueror',
      'is_team': true,
      'team_size': 2,
      'total_challenge_distance_km': 145.0,
      'is_charity': true,
      'impact_metric': 'trees',
      'custom_impact_quantity': 4.0,
    });
    expect(conqueror.impactMetric, ImpactMetric.trees);
    expect(conqueror.impactQuantity, 4.0);
    expect(conqueror.teamSize, 2);
    expect(conqueror.challengeDistanceM, 145000);
  });

  test('format distant : aller-retour sans perte', () {
    final c = Course(
      id: 'x',
      title: 'Trail',
      raceDate: calendarDate(2026, 10, 5),
      distanceM: 15200,
      durationS: 4560,
      elevationGainM: 320,
      isCharity: true,
      associationName: 'AFM-Téléthon',
      associationCause: CauseType.sante,
      registrationDonationCents: 1200,
      bibPhotoKey: 'u/abc.jpg',
    );
    final back = Course.fromRemoteJson(c.toRemoteJson());
    expect(back.toRemoteJson(), c.toRemoteJson());
  });
}
