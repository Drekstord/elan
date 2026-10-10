import 'package:app_course/app/labels.dart';
import 'package:app_course/core/database/database.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/domain/course_query.dart';
import 'package:app_course/features/courses/domain/course_stats.dart';
import 'package:app_course/features/courses/presentation/multisport_editor.dart';
import 'package:app_course/features/records/domain/personal_records.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';

/// Triathlon S, transitions chronométrées à part : 15:00 + 2:00 + 40:00 + 1:30 + 25:00 = 1:23:30.
final _triathlonS = Multisport(
  kind: MultisportKind.triathlon,
  format: 'S',
  legs: const [
    Leg(sport: Sport.swim, distanceM: 750, durationS: 900),
    Leg(sport: Sport.bike, distanceM: 20000, durationS: 2400),
    Leg(sport: Sport.run, distanceM: 5000, durationS: 1500),
  ],
  transitionsS: const [120, 90],
);

Course _course(String id, Multisport m, {int? durationS, DateTime? date, int sponsor = 0}) => Course(
  id: id,
  title: 'Épreuve $id',
  raceDate: date ?? calendarDate(2026, 6, 14),
  type: CourseType.multisport,
  distanceM: m.distanceM,
  durationS: durationS ?? m.splitsTotalS ?? 0,
  multisport: m,
  isCharity: sponsor > 0,
  sponsorCentsPerKm: sponsor,
);

void main() {
  final t = AppLocalizationsFr();

  group('épreuve enchaînée', () {
    test('distances, temps total reconstitué, rythmes par discipline', () {
      expect(_triathlonS.distanceM, 25750);
      expect(_triathlonS.runDistanceM, 5000);
      expect(_triathlonS.hasSplits, isTrue);
      expect(_triathlonS.splitsTotalS, 5010);
      expect(_triathlonS.legs[0].secondsPer100m, 120); // 2'00" aux 100 m
      expect(_triathlonS.legs[1].speedKmh, 30);
      expect(_triathlonS.legs[2].secondsPerKm, 300); // 5'00" au km
      expect(_triathlonS.title(t), 'Triathlon S');
    });

    test('transitions comptées dans les disciplines : T1 dans la natation, T2 dans le vélo', () {
      final xxs = Multisport(
        kind: MultisportKind.triathlon,
        format: 'XXS',
        legs: const [
          Leg(sport: Sport.swim, distanceM: 200, durationS: 420),
          Leg(sport: Sport.bike, distanceM: 5000, durationS: 780),
          Leg(sport: Sport.run, distanceM: 1500, durationS: 480),
        ],
        // Ignorées : elles sont déjà dans les temps ci-dessus.
        transitionsS: const [60, 60],
        transitionsIncluded: true,
      );
      expect(xxs.transitionsS, isEmpty);
      expect(xxs.transitionsTotalS, 0);
      expect(xxs.splitsTotalS, 1680, reason: 'somme des trois disciplines, rien à ajouter');
      expect(xxs.legIncludesTransition(0), isTrue);
      expect(xxs.legIncludesTransition(1), isTrue);
      expect(xxs.legIncludesTransition(2), isFalse, reason: 'rien après la course à pied');
      expect(
        multisportSummary(xxs, t),
        'Natation 200 m 07:00 (transition comprise) · Vélo 5 km 13:00 (transition comprise) · Course à pied 1,5 km 08:00',
      );
    });

    test('duathlon : deux courses à pied numérotées, toutes deux comptées', () {
      final duathlon = Multisport(
        kind: MultisportKind.duathlon,
        format: 'S',
        legs: const [
          Leg(sport: Sport.run, distanceM: 5000),
          Leg(sport: Sport.bike, distanceM: 20000),
          Leg(sport: Sport.run, distanceM: 2500),
        ],
      );
      expect(duathlon.runDistanceM, 7500);
      expect(duathlon.hasSplits, isFalse);
      expect(duathlon.splitsTotalS, isNull);
      expect([for (var i = 0; i < 3; i++) duathlon.legLabel(i, t)], ['Course à pied 1', 'Vélo', 'Course à pied 2']);
      expect(duathlon.transitionsS, [0, 0]);
    });

    test('format JSON : aller-retour, données inconnues ignorées', () {
      expect(Multisport.tryFromJson(_triathlonS.toJson()), _triathlonS);
      final free = Multisport(
        kind: MultisportKind.aquathlon,
        legs: const [
          Leg(sport: Sport.swim, distanceM: 600),
          Leg(sport: Sport.run, distanceM: 4000),
        ],
        transitionsIncluded: true,
      );
      expect(free.toJson().containsKey('format'), isFalse);
      expect(Multisport.tryFromJson(free.toJson()), free);
      expect(Multisport.tryFromJson(null), isNull);
      expect(Multisport.tryFromJson({'kind': 'triathlon', 'legs': []}), isNull);
      // Discipline d'une version future : ignorée, le reste est gardé.
      final partial = Multisport.tryFromJson({
        'kind': 'triathlon',
        'legs': [
          {'sport': 'ski', 'distance_m': 1},
          {'sport': 'run', 'distance_m': 5000, 'duration_s': 1500},
        ],
      });
      expect(partial!.legs.single.sport, Sport.run);
    });
  });

  group('dans une course', () {
    test('kilomètres courus = course à pied ; pas d\'allure globale ; format distant fidèle', () {
      final c = _course('tri', _triathlonS);
      expect(c.isMultisport, isTrue);
      expect(c.distanceM, 25750);
      expect(c.runDistanceM, 5000);
      expect(c.paceSecondsPerKm, isNull);
      expect(c.speedKmh, isNull);
      expect(c.typeLabel(t), 'Triathlon S');

      final back = Course.fromRemoteJson(c.toRemoteJson());
      expect(back.multisport, _triathlonS);
      expect(back.type, CourseType.multisport);
      expect(back.durationS, 5010);

      // Une course ordinaire n'a jamais de détail d'épreuve enchaînée, même si on lui en donne un.
      final run = Course(
        id: 'r',
        title: '10 km',
        raceDate: calendarDate(2026, 1, 1),
        distanceM: 10000,
        multisport: _triathlonS,
      );
      expect(run.multisport, isNull);
      expect(run.runDistanceM, 10000);
    });

    test('base locale : enregistrement et relecture', () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      await db.into(db.courses).insert(AppDatabase.toRow(_course('tri', _triathlonS), pending: true));
      final reread = AppDatabase.toCourse(await db.select(db.courses).getSingle());
      expect(reread.multisport, _triathlonS);
      expect(reread.runDistanceM, 5000);
    });

    test('totaux : seule la course à pied dans les km courus, les trois disciplines pour l\'engagement', () {
      final courses = [
        _course('tri', _triathlonS, sponsor: 100), // 1 € par km parcouru
        Course(id: 'dix', title: '10 km', raceDate: calendarDate(2026, 5, 1), distanceM: 10000, durationS: 3000),
      ];
      final stats = CourseStats.of(courses);
      expect(stats.count, 2);
      expect(stats.distanceM, 15000, reason: '10 km + les 5 km à pied du triathlon');
      expect(stats.totalDistanceM, 35750, reason: 'natation et vélo compris');
      expect(stats.durationS, 8010);
      expect(stats.averagePaceSecondsPerKm, 300, reason: "le triathlon ne fausse pas l'allure moyenne");
      // Parrainage au kilomètre : les trois disciplines comptent (25,75 km).
      expect(courses.first.donationCents, 2575);

      expect(totalsByPeriod(courses, Period.year).single.distanceM, 15000);
      expect(cumulativeDistance(courses, 2026).last.$2, 15000);
      expect(pacedRaces(courses).map((c) => c.id), ['dix']);
    });

    test('filtre « Triathlons » et records par format, à part de la course à pied', () {
      final fast = _course('rapide', _triathlonS, date: calendarDate(2026, 9, 1));
      final slow = _course('lent', _triathlonS, durationS: 5600, date: calendarDate(2025, 9, 1));
      final free = _course(
        'libre',
        Multisport(kind: MultisportKind.triathlon, legs: _triathlonS.legs),
        durationS: 4000,
      );
      final fiveK = Course(
        id: '5k',
        title: '5 km',
        raceDate: calendarDate(2026, 3, 1),
        distanceM: 5000,
        durationS: 1400,
      );
      final all = [fast, slow, free, fiveK];

      expect(all.where(CourseKind.multisport.matches).map((c) => c.id), ['rapide', 'lent', 'libre']);
      expect(all.where(CourseKind.official.matches).map((c) => c.id), ['5k']);

      final records = PersonalRecords.compute(all);
      // Les 5 km à pied d'un triathlon n'entrent pas dans le record du 5 km.
      expect(records.byDistance[StandardDistance.fiveK]!.map((c) => c.id), ['5k']);
      expect(records.longest.map((c) => c.id), ['5k']);
      // Un classement par épreuve et format ; les distances libres ne se comparent pas.
      expect(records.multisport.keys, [(kind: MultisportKind.triathlon, format: 'S')]);
      expect(records.multisport.values.single.map((c) => c.id), ['rapide', 'lent']);
      expect(records.heldBy(fast), {const MultisportRecord((kind: MultisportKind.triathlon, format: 'S'))});
      // Mêmes temps intermédiaires dans les trois : à égalité, la plus ancienne garde le record.
      expect(records.heldBy(slow), {for (final sport in Sport.values) SportRecord(sport)});
      expect(PersonalRecords.years(all), [2026, 2025]);
    });
  });

  group('saisie', () {
    MultisportEditorController editor() {
      final c = MultisportEditorController();
      addTearDown(c.dispose);
      return c;
    }

    test('triathlon S proposé par défaut ; changer de format préremplit les distances', () {
      final c = editor();
      expect(c.kind, MultisportKind.triathlon);
      expect(c.format, 'S');
      expect(c.distances.map((d) => d.text), ['750', '20', '5']);
      c.selectFormat('XXS');
      expect(c.distances.map((d) => d.text), ['200', '5', '1,5']);
      expect(c.previewDistanceM, 6700);
      // Distance corrigée à la main : ce n'est plus le format standard.
      c.distances[1].text = '6';
      c.distanceEdited();
      expect(c.format, isNull);
      // Aquathlon : deux disciplines, une seule transition.
      c.kind = MultisportKind.aquathlon;
      expect(c.sports, [Sport.swim, Sport.run]);
      expect(c.transitions, hasLength(1));
      expect(c.format, 'S');
    });

    test('XXS avec transitions comptées dans les disciplines : total = somme des trois temps', () {
      final c = editor()..selectFormat('XXS');
      c.transitionsIncluded = true;
      c.durations[0].text = '7:00';
      c.durations[1].text = '13:00';
      c.durations[2].text = '8:00';
      expect(c.computedTotalS, 1680);
      final input = c.read(t, planned: false)!;
      expect(input.durationS, 1680);
      expect(input.multisport.format, 'XXS');
      expect(input.multisport.transitionsIncluded, isTrue);
      expect(input.multisport.transitionsS, isEmpty);
      expect(input.multisport.legs.map((l) => l.durationS), [420, 780, 480]);
    });

    test('transitions à part : ajoutées au total ; temps total officiel accepté s\'il est cohérent', () {
      final c = editor();
      c.durations[0].text = '15:00';
      c.durations[1].text = '40:00';
      c.durations[2].text = '25:00';
      c.transitions[0].text = '2:00';
      c.transitions[1].text = '1:30';
      expect(c.read(t, planned: false)!.durationS, 5010);

      c.total.text = '1:24:00';
      expect(c.read(t, planned: false)!.durationS, 5040);

      c.total.text = '1:00:00';
      expect(c.read(t, planned: false), isNull);
      expect(c.error, contains('1:23:30'));
    });

    test('temps total seul, sans détail ; détail incomplet refusé ; épreuve à venir sans temps', () {
      final c = editor();
      c.total.text = '1:30:00';
      final totalOnly = c.read(t, planned: false)!;
      expect(totalOnly.durationS, 5400);
      expect(totalOnly.multisport.hasSplits, isFalse);

      c.durations[0].text = '15:00';
      expect(c.read(t, planned: false), isNull);
      expect(c.error, t.issueLegTimes);

      final planned = c.read(t, planned: true)!;
      expect(planned.durationS, 0);
      expect(planned.multisport.legs.every((l) => l.durationS == 0), isTrue);

      c.distances[0].text = '';
      expect(c.read(t, planned: true), isNull);
      expect(c.error, t.issueLegDistance);
    });

    test('modification : la saisie retrouve l\'épreuve enregistrée', () {
      final c = MultisportEditorController(initial: _triathlonS, initialDurationS: 5010);
      addTearDown(c.dispose);
      expect(c.format, 'S');
      expect(c.durations.map((d) => d.text), ['15:00', '40:00', '25:00']);
      expect(c.transitions.map((d) => d.text), ['02:00', '01:30']);
      expect(c.total.text, isEmpty, reason: 'total calculé, rien à ressaisir');
      expect(c.read(t, planned: false)!.multisport, _triathlonS);
    });
  });

  group('performances par discipline', () {
    Course tri(String id, int day, List<Leg> legs, {String? format, bool included = false, MultisportKind? kind}) =>
        Course(
          id: id,
          title: id,
          raceDate: calendarDate(2026, 5, day),
          type: CourseType.multisport,
          distanceM: legs.fold(0, (sum, l) => sum + l.distanceM),
          durationS: legs.fold(0, (sum, l) => sum + l.durationS),
          multisport: Multisport(
            kind: kind ?? MultisportKind.triathlon,
            format: format,
            legs: legs,
            transitionsIncluded: included,
          ),
        );

    final xxs = tri(
      'xxs',
      1,
      const [
        Leg(sport: Sport.swim, distanceM: 200, durationS: 420),
        Leg(sport: Sport.bike, distanceM: 5000, durationS: 780),
        Leg(sport: Sport.run, distanceM: 1500, durationS: 480),
      ],
      format: 'XXS',
      included: true,
    );
    final s = tri('s', 20, const [
      Leg(sport: Sport.swim, distanceM: 750, durationS: 900),
      Leg(sport: Sport.bike, distanceM: 20000, durationS: 2400),
      Leg(sport: Sport.run, distanceM: 5000, durationS: 1500),
    ], format: 'S');
    final duathlon = tri('duathlon', 10, const [
      Leg(sport: Sport.run, distanceM: 5000, durationS: 1400),
      Leg(sport: Sport.bike, distanceM: 20000, durationS: 2880),
      Leg(sport: Sport.run, distanceM: 2500, durationS: 775),
    ], kind: MultisportKind.duathlon);
    final sansDetail = tri('sans-detail', 25, const [
      Leg(sport: Sport.swim, distanceM: 750),
      Leg(sport: Sport.bike, distanceM: 20000),
      Leg(sport: Sport.run, distanceM: 5000),
    ]);

    test('une discipline sur toute l\'épreuve : les deux courses d\'un duathlon réunies', () {
      final run = duathlon.multisport!.split(Sport.run)!;
      expect(run.distanceM, 7500);
      expect(run.durationS, 2175);
      expect(run.secondsPerKm, 290);
      expect(duathlon.multisport!.split(Sport.swim), isNull);
      expect(sansDetail.multisport!.split(Sport.bike)!.hasTime, isFalse);
    });

    test('transition comprise : signalée sur la natation et le vélo, pas sur la course finale', () {
      final m = xxs.multisport!;
      expect(m.splitIncludesTransition(Sport.swim), isTrue);
      expect(m.splitIncludesTransition(Sport.bike), isTrue);
      expect(m.splitIncludesTransition(Sport.run), isFalse);
      expect(s.multisport!.splitIncludesTransition(Sport.swim), isFalse);
    });

    test('cumuls par discipline : épreuves terminées seulement, courses ordinaires ignorées', () {
      final totals = sportTotals([
        xxs,
        s,
        duathlon,
        Course(id: 'dix', title: '10 km', raceDate: calendarDate(2026, 5, 2), distanceM: 10000, durationS: 3000),
        tri('a-venir', 28, const [Leg(sport: Sport.swim, distanceM: 1500)]).copyWith(isPlanned: true),
      ]);
      expect(totals[Sport.swim], (distanceM: 950, durationS: 1320));
      expect(totals[Sport.bike], (distanceM: 45000, durationS: 6060));
      expect(totals[Sport.run], (distanceM: 14000, durationS: 4155));
      expect(sportTotals([duathlon]).containsKey(Sport.swim), isFalse);
    });

    test('progression : épreuves chronométrées de la discipline, dans l\'ordre des dates', () {
      expect(splitRaces([s, sansDetail, duathlon, xxs], Sport.bike).map((c) => c.id), ['xxs', 'duathlon', 's']);
      expect(splitRaces([s, sansDetail, duathlon, xxs], Sport.swim).map((c) => c.id), ['xxs', 's']);
    });

    test('records par discipline : meilleur rythme, tous formats confondus', () {
      final records = PersonalRecords.compute([xxs, s, duathlon, sansDetail]);
      // Natation : 2'00" /100 m (S) devant 3'30" (XXS). Vélo : 30 km/h (S), 25 (duathlon), 23,1 (XXS).
      expect(records.bySport[Sport.swim]!.map((c) => c.id), ['s', 'xxs']);
      expect(records.bySport[Sport.bike]!.map((c) => c.id), ['s', 'duathlon', 'xxs']);
      // Course à pied : 4'50" /km (duathlon), 5'00" (S), 5'20" (XXS).
      expect(records.bySport[Sport.run]!.map((c) => c.id), ['duathlon', 's', 'xxs']);
      expect(records.heldBy(s), containsAll([const SportRecord(Sport.swim), const SportRecord(Sport.bike)]));
      expect(records.heldBy(duathlon), {const SportRecord(Sport.run)});
      expect(records.heldBy(xxs), isEmpty);
      // Les records de course à pied ne bougent pas : aucun 5 km ici.
      expect(records.byDistance, isEmpty);
    });

    test('une seule épreuve : un rythme affiché, mais pas de badge record', () {
      final records = PersonalRecords.compute([xxs]);
      expect(records.isEmpty, isFalse);
      expect(records.bySport.keys, Sport.values);
      expect(records.heldBy(xxs), isEmpty);
    });
  });
}
