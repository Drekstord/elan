import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/domain/course_query.dart';
import 'package:app_course/features/courses/domain/course_rules.dart';
import 'package:app_course/features/courses/domain/course_stats.dart';
import 'package:app_course/features/impact/domain/impact_summary.dart';
import 'package:flutter_test/flutter_test.dart';

final today = calendarDate(2026, 10, 8);

Course run(
  String id, {
  String title = 'Course',
  DateTime? date,
  int distanceM = 10000,
  int durationS = 3000,
  int? elevation,
  bool planned = false,
  bool charity = false,
  CourseType type = CourseType.officialRace,
  CauseType? cause,
  String? association,
  int sponsorCentsPerKm = 0,
  int registrationCents = 0,
  int fundraisingCents = 0,
  ImpactMetric metric = ImpactMetric.euroDirect,
  double? quantity,
  DateTime? createdAt,
}) => Course(
  id: id,
  title: title,
  raceDate: date ?? calendarDate(2026, 9, 1),
  distanceM: distanceM,
  durationS: durationS,
  elevationGainM: elevation,
  isPlanned: planned,
  isCharity: charity,
  type: type,
  associationCause: cause,
  associationName: association,
  sponsorCentsPerKm: sponsorCentsPerKm,
  registrationDonationCents: registrationCents,
  fundraisingCents: fundraisingCents,
  impactMetric: metric,
  impactQuantity: quantity,
  createdAt: createdAt,
);

void main() {
  group('Course', () {
    test('allure et vitesse', () {
      final c = run('a', distanceM: 21100, durationS: 5400);
      expect(c.paceSecondsPerKm, closeTo(255.9, 0.1)); // 4'16"/km
      expect(c.speedKmh, closeTo(14.07, 0.01));
      expect(run('b', durationS: 0).paceSecondsPerKm, isNull);
    });

    test('dons : parrainage au km + inscription + collecte, arrondis au centime', () {
      final c = run(
        'a',
        distanceM: 21097,
        charity: true,
        sponsorCentsPerKm: 150,
        registrationCents: 2000,
        fundraisingCents: 5000,
      );
      expect(c.donationCents, 3165 + 2000 + 5000); // 21,097 km x 1,50 € = 31,65 €
    });

    test('course non solidaire : aucun don, aucune association, même si saisis', () {
      final c = run('a', charity: false, association: 'X', registrationCents: 4500, cause: CauseType.sante);
      expect(c.donationCents, 0);
      expect(c.associationName, isNull);
      expect(c.associationCause, isNull);
    });

    test('impact déclaré : unité sans quantité (ou l\'inverse) ignorée', () {
      expect(run('a', charity: true, metric: ImpactMetric.trees).impactMetric, ImpactMetric.euroDirect);
      expect(run('b', charity: true, quantity: 4).impactQuantity, isNull);
      final ok = run('c', charity: true, metric: ImpactMetric.trees, quantity: 4);
      expect((ok.impactMetric, ok.impactQuantity), (ImpactMetric.trees, 4.0));
    });

    test('statut d\'une course à venir', () {
      expect(run('a', planned: true, date: calendarDate(2026, 10, 20)).statusOn(today), CourseStatus.upcoming);
      expect(run('b', planned: true, date: today).statusOn(today), CourseStatus.awaitingResult);
      expect(run('c', planned: true, date: calendarDate(2026, 10, 1)).statusOn(today), CourseStatus.awaitingResult);
      expect(run('d').statusOn(today), CourseStatus.completed);
    });

    test('saisie du résultat : la course devient terminée', () {
      final planned = run('a', planned: true, durationS: 0, date: calendarDate(2026, 10, 5));
      final done = completeWithResult(planned, durationS: 2950, distanceM: 10050);
      expect(done.isPlanned, isFalse);
      expect((done.durationS, done.distanceM), (2950, 10050));
      expect(done.statusOn(today), CourseStatus.completed);
    });
  });

  group('Validation', () {
    test('course valide', () => expect(validateCourse(run('a'), today: today), isEmpty));

    test('incohérences détectées', () {
      expect(
        validateCourse(run('a', title: ' ', distanceM: 0), today: today),
        containsAll([CourseIssue.missingTitle, CourseIssue.distanceNotPositive]),
      );
      expect(validateCourse(run('b', date: calendarDate(2026, 12, 1)), today: today), [CourseIssue.completedInFuture]);
      expect(validateCourse(run('c', planned: true, date: calendarDate(2026, 12, 1)), today: today), [
        CourseIssue.plannedWithResult,
      ]);
    });

    test('plafonds The Conqueror : 4 arbres, 40 bouteilles', () {
      Course tc(ImpactMetric m, double q) =>
          run('t', type: CourseType.theConqueror, charity: true, metric: m, quantity: q, durationS: 0);
      expect(validateCourse(tc(ImpactMetric.trees, 4), today: today), isEmpty);
      expect(validateCourse(tc(ImpactMetric.trees, 5), today: today), [CourseIssue.impactAboveCap]);
      expect(validateCourse(tc(ImpactMetric.oceanBottles, 41), today: today), [CourseIssue.impactAboveCap]);
    });

    test('part personnelle d\'un défi en équipe', () {
      expect(ConquerorRules.personalShareM(145000, 2), 72500);
      expect(ConquerorRules.personalShareM(145000, 1), 145000);
    });
  });

  group('Totaux', () {
    test('les courses à venir ne comptent pas', () {
      final stats = CourseStats.of([
        run('a', distanceM: 10000, durationS: 3000, elevation: 100),
        run('b', distanceM: 5000, durationS: 0),
        run('c', distanceM: 42195, planned: true, durationS: 0),
      ]);
      expect(stats.count, 2);
      expect(stats.distanceM, 15000);
      expect(stats.elevationGainM, 100);
      // Allure moyenne calculée sur les seules courses chronométrées.
      expect(stats.averagePaceSecondsPerKm, 300);
    });

    test('bilan solidaire : euros réels et quantités déclarées seulement', () {
      final summary = ImpactSummary.of([
        run('a', charity: true, cause: CauseType.sante, association: 'AFM-Téléthon', registrationCents: 2000),
        run(
          'b',
          charity: true,
          cause: CauseType.environnement,
          association: 'The Conqueror',
          metric: ImpactMetric.trees,
          quantity: 4,
        ),
        run(
          'c',
          charity: true,
          cause: CauseType.environnement,
          association: 'The Conqueror',
          metric: ImpactMetric.trees,
          quantity: 4,
        ),
        run('d', charity: true, planned: true, registrationCents: 9900, cause: CauseType.sante),
        run('e', registrationCents: 4500),
      ]);
      expect(summary.donationCents, 2000);
      expect(summary.charityCount, 3);
      expect(summary.declared, {ImpactMetric.trees: 8.0});
      expect(summary.distanceByCause, {CauseType.sante: 10000, CauseType.environnement: 20000});
      expect(summary.associations, ['AFM-Téléthon', 'The Conqueror']);
    });

    test('distance cumulée sur l\'année, courses à venir exclues', () {
      final points = cumulativeDistance([
        run('a', date: calendarDate(2026, 1, 10), distanceM: 10000),
        run('b', date: calendarDate(2026, 3, 1), distanceM: 5000),
        run('c', date: calendarDate(2025, 12, 31), distanceM: 42000),
        run('d', date: calendarDate(2026, 4, 1), distanceM: 21000, planned: true, durationS: 0),
      ], 2026);
      expect(points, [(0, 0), (10, 10000), (60, 15000)]);
    });

    test('allures : courses officielles chronométrées, dans l\'ordre', () {
      final races = pacedRaces([
        run('b', date: calendarDate(2026, 3, 1)),
        run('a', date: calendarDate(2026, 1, 1)),
        run('tc', type: CourseType.theConqueror),
        run('sans-chrono', durationS: 0),
      ]);
      expect(races.map((c) => c.id), ['a', 'b']);
    });

    test('séries mensuelles continues, mois vides inclus', () {
      final series = totalsByPeriod([
        run('a', date: calendarDate(2026, 1, 10), distanceM: 10000),
        run('b', date: calendarDate(2026, 3, 2), distanceM: 5000),
        run('c', date: calendarDate(2026, 3, 20), distanceM: 5000),
        run('d', date: calendarDate(2026, 6, 1), planned: true, durationS: 0),
      ], Period.month);
      expect(series.map((p) => p.start.month), [1, 2, 3]);
      expect(series.map((p) => p.distanceM), [10000, 0, 10000]);
      expect(totalsByPeriod([], Period.year), isEmpty);
    });

    test('mois consécutifs à partir d\'un mois donné, même à cheval sur deux années', () {
      final months = monthlyTotals(
        [
          run('a', date: calendarDate(2025, 12, 31), distanceM: 7000),
          run('b', date: calendarDate(2026, 2, 1), distanceM: 3000),
          run('c', date: calendarDate(2026, 3, 1), distanceM: 9000),
        ],
        DateTime.utc(2025, 11),
        4,
      );
      expect(months.map((m) => (m.start.year, m.start.month)), [(2025, 11), (2025, 12), (2026, 1), (2026, 2)]);
      expect(months.map((m) => m.distanceM), [0, 7000, 0, 3000]);
      expect(months[1].courses.single.id, 'a');
    });
  });

  test('chiffres mis en avant : équivalences annoncées puis km des autres causes', () {
    final summary = ImpactSummary.of([
      run('tc', charity: true, cause: CauseType.environnement, metric: ImpactMetric.trees, quantity: 13),
      run('tc2', charity: true, cause: CauseType.environnement, metric: ImpactMetric.oceanBottles, quantity: 40),
      run('rett', charity: true, cause: CauseType.handicap, distanceM: 7300),
      run('restos', charity: true, cause: CauseType.precarite, distanceM: 10000),
    ]);
    final h = summary.highlights;
    expect(h.whereType<DeclaredHighlight>().map((e) => e.metric), [ImpactMetric.oceanBottles, ImpactMetric.trees]);
    // L'environnement a déjà ses équivalences : pas de doublon en kilomètres.
    expect(h.whereType<CauseDistanceHighlight>().map((e) => (e.cause, e.meters)), [
      (CauseType.precarite, 10000),
      (CauseType.handicap, 7300),
    ]);
  });

  group('Liste', () {
    final courses = [
      run('official', title: 'Semi de Paris', date: calendarDate(2026, 3, 1), createdAt: DateTime.utc(2026, 9, 1)),
      run(
        'charity',
        title: 'Course du Cœur',
        charity: true,
        cause: CauseType.precarite,
        association: 'Les Restos du Cœur',
        date: calendarDate(2026, 5, 1),
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      run('tc', title: 'Grand Défi', type: CourseType.theConqueror, date: calendarDate(2026, 6, 1)),
      run('waiting', title: 'Trail', planned: true, durationS: 0, date: calendarDate(2026, 10, 1)),
      run('future', title: 'Marathon', planned: true, durationS: 0, date: calendarDate(2026, 11, 1)),
    ];
    List<String> ids(CourseQuery q) => q.apply(courses, today).map((c) => c.id).toList();

    test('le résultat à saisir passe en tête, puis tri par date de course', () {
      expect(ids(const CourseQuery()), ['waiting', 'future', 'tc', 'charity', 'official']);
      expect(ids(const CourseQuery(descending: false)), ['waiting', 'official', 'charity', 'tc', 'future']);
    });

    test('tri par date d\'ajout', () {
      final done = courses.where((c) => c.id == 'official' || c.id == 'charity');
      List<String> sorted(bool desc) =>
          CourseQuery(sort: CourseSort.addedDate, descending: desc).apply(done, today).map((c) => c.id).toList();
      expect(sorted(true), ['official', 'charity']);
      expect(sorted(false), ['charity', 'official']);
    });

    test('filtres : nature de l\'épreuve et volet solidaire sont indépendants', () {
      // Une course officielle solidaire reste une course officielle.
      expect(ids(const CourseQuery(kind: CourseKind.official)), ['waiting', 'future', 'charity', 'official']);
      expect(ids(const CourseQuery(kind: CourseKind.challenge)), ['tc']);
      expect(ids(const CourseQuery(charityOnly: true)), ['charity']);
      expect(ids(const CourseQuery(kind: CourseKind.challenge, charityOnly: true)), isEmpty);
      expect(ids(const CourseQuery(cause: CauseType.precarite)), ['charity']);
      expect(ids(const CourseQuery(cause: CauseType.sante)), isEmpty);
      expect(const CourseQuery().isFiltered, isFalse);
      expect(const CourseQuery(cause: CauseType.sante).copyWith(cause: null).cause, isNull);
    });

    test('sections : à saisir, à venir (la plus proche d\'abord), puis par année', () {
      final list = [...courses, run('old', date: calendarDate(2025, 4, 6))];
      final sorted = const CourseQuery().apply(list, today);
      final sections = sectionsOf(sorted, today, sort: CourseSort.raceDate);
      expect(sections.map((s) => (s.kind, s.year)), [
        (SectionKind.awaiting, null),
        (SectionKind.upcoming, null),
        (SectionKind.year, 2026),
        (SectionKind.year, 2025),
      ]);
      expect(sections[0].courses.map((c) => c.id), ['waiting']);
      expect(sections[1].courses.map((c) => c.id), ['future']);
      expect(sections[2].courses.map((c) => c.id), ['tc', 'charity', 'official']);
      expect(sections[2].distanceM, 30000);

      final byAdded = sectionsOf(sorted, today, sort: CourseSort.addedDate);
      expect(byAdded.last.kind, SectionKind.done);
      expect(byAdded.last.courses, hasLength(4));
    });

    test('recherche insensible aux accents et à la casse, sur le titre et l\'association', () {
      expect(ids(const CourseQuery(search: 'coeur')), ['charity']);
      expect(ids(const CourseQuery(search: 'DEFI')), ['tc']);
    });
  });
}
