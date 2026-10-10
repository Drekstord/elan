import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/evolution/presentation/evolution_screen.dart';
import 'package:app_course/features/records/presentation/records_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _triathlonS = Course(
  id: 'tri',
  title: 'Triathlon de Valfleuri',
  raceDate: calendarDate(2026, 6, 14),
  type: CourseType.multisport,
  distanceM: 25750,
  durationS: 5010,
  multisport: Multisport(
    kind: MultisportKind.triathlon,
    format: 'S',
    legs: const [
      Leg(sport: Sport.swim, distanceM: 750, durationS: 900),
      Leg(sport: Sport.bike, distanceM: 20000, durationS: 2400),
      Leg(sport: Sport.run, distanceM: 5000, durationS: 1500),
    ],
    transitionsS: const [120, 90],
  ),
);

final _triathlonXxs = Course(
  id: 'xxs',
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
    transitionsIncluded: true,
  ),
);

void main() {
  setUpAll(TestEnv.init);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('formulaire : triathlon XXS, transitions comptées dans les disciplines', (tester) async {
    final env = TestEnv();
    await env.pump(tester, location: '/courses/nouvelle');

    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), 'Triathlon de Démoville');
    await tester.tap(find.text('Triathlon'));
    await tester.pump();
    // La distance et le temps uniques laissent place au détail des disciplines.
    expect(find.widgetWithText(TextField, 'Distance (km)'), findsNothing);
    expect(find.text('Natation'), findsOneWidget);
    expect(find.text('Vélo'), findsOneWidget);
    expect(find.text('Course à pied'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Transition 1'), findsOneWidget);

    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'XXS'));
    await tapVisible(tester, find.text('Transitions comptées dans les disciplines'));
    expect(find.widgetWithText(TextField, 'Transition 1'), findsNothing);

    final times = find.widgetWithText(TextField, 'Temps');
    expect(times, findsNWidgets(3));
    await tester.enterText(times.at(0), '7:00');
    await tester.enterText(times.at(1), '13:00');
    await tester.enterText(times.at(2), '8:00');
    await tester.pump();
    // Le temps total se déduit des trois temps saisis.
    expect(find.textContaining('28:00'), findsWidgets);

    await tapVisible(tester, find.text('Enregistrer'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single;
    expect(saved.type, CourseType.multisport);
    expect(saved.multisport!.kind, MultisportKind.triathlon);
    expect(saved.multisport!.format, 'XXS');
    expect(saved.multisport!.transitionsIncluded, isTrue);
    expect(saved.multisport!.legs.map((l) => l.durationS), [420, 780, 480]);
    expect(saved.distanceM, 6700);
    expect(saved.runDistanceM, 1500);
    expect(saved.durationS, 1680);

    // La fiche s'ouvre : chaque discipline, et la mention sur les deux temps qui contiennent une transition.
    expect(find.textContaining(RegExp('triathlon xxs', caseSensitive: false)), findsWidgets);
    expect(find.textContaining('transition comprise'), findsNWidgets(2));
    expect(find.textContaining('1,5 km de course à pied'), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('formulaire : détail incomplet refusé avec un message clair', (tester) async {
    final env = TestEnv();
    await env.pump(tester, location: '/courses/nouvelle');
    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), 'Aquathlon');
    await tester.tap(find.text('Triathlon'));
    await tester.pump();
    await tester.tap(find.text('Aquathlon').last);
    await tester.pump();
    expect(find.text('Vélo'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Temps').first, '12:00');
    await tapVisible(tester, find.text('Enregistrer'));
    expect(find.textContaining('Renseigne le temps de chaque discipline'), findsWidgets);
    expect(await env.stored(tester), isEmpty);
    await env.dispose(tester);
  });

  testWidgets('fiche et liste : disciplines détaillées, km courus = course à pied seulement', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      _triathlonS,
      Course(
        id: 'dix',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2026, 5, 1),
        distanceM: 10000,
        durationS: 3000,
      ),
    ]);

    await env.pump(tester);
    // 10 km + les 5 km à pied du triathlon : le vélo et la natation ne gonflent pas le total.
    expect(find.textContaining('15 km'), findsWidgets);
    expect(find.textContaining('36 km'), findsNothing);
    expect(findText('Triathlon S  ·  750 m  ·  20 km  ·  5 km'), findsOneWidget);
    // Le filtre n'apparaît que parce qu'une épreuve enchaînée existe.
    await tapVisible(tester, find.text('Triathlons'));
    await env.settle(tester);
    expect(find.text('TRIATHLON DE VALFLEURI'), findsOneWidget);
    expect(find.text('10 KM DE BOIS-JOLI'), findsNothing);
    await env.dispose(tester);

    final detail = TestEnv();
    await detail.seed(tester, [_triathlonS]);
    await detail.pump(tester, location: '/courses/tri');
    expect(find.text('1:23:30'), findsOneWidget);
    expect(findText('750 m  ·  2\'00" /100 m'), findsOneWidget);
    expect(findText('20 km  ·  30,0 km/h'), findsOneWidget);
    expect(findText('5 km  ·  5\'00" /km'), findsOneWidget);
    expect(find.text('Transition 1'), findsOneWidget);
    expect(find.textContaining('transition comprise'), findsNothing);
    expect(find.text('Répartition du temps'), findsOneWidget);
    await detail.dispose(tester);
  });

  testWidgets('sans épreuve enchaînée, le filtre « Triathlons » reste caché', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(id: 'dix', title: '10 km', raceDate: calendarDate(2026, 5, 1), distanceM: 10000, durationS: 3000),
    ]);
    await env.pump(tester);
    expect(find.text('Officielles'), findsOneWidget);
    expect(find.text('Triathlons'), findsNothing);
    await env.dispose(tester);
  });

  testWidgets('modifier une course garde ses justificatifs', (tester) async {
    final env = TestEnv();
    final doc = CourseDocument(
      key: 'user-1/docs/facture.pdf',
      name: 'facture.pdf',
      sizeBytes: 2048,
      addedAt: DateTime.utc(2026, 9, 2),
      kind: DocumentKind.invoice,
    );
    await env.seed(tester, [
      Course(
        id: 'a',
        title: 'Semi de Démoville',
        raceDate: calendarDate(2026, 3, 8),
        distanceM: 21100,
        durationS: 6100,
        documents: [doc],
      ),
    ]);
    await env.pump(tester, location: '/courses/a/modifier');

    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), 'Semi-marathon de Démoville');
    await tapVisible(tester, find.text('Enregistrer'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single;
    expect(saved.title, 'Semi-marathon de Démoville');
    expect(saved.documents.single.key, 'user-1/docs/facture.pdf', reason: 'la facture ne doit pas disparaître');
    expect(saved.documents.single.kind, DocumentKind.invoice);
    await env.dispose(tester);
  });

  testWidgets('évolution : cumuls par discipline, filtre et rythme d\'une épreuve à l\'autre', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [_triathlonS, _triathlonXxs]);
    await env.pump(tester, home: const EvolutionScreen());

    expect(find.text('TRIATHLONS : PAR DISCIPLINE'), findsOneWidget);
    expect(find.text('950 m'), findsOneWidget);
    expect(find.text('25 km'), findsOneWidget);
    expect(find.text('6,5 km'), findsWidgets);
    expect(find.text('RYTHME PAR DISCIPLINE EN TRIATHLON'), findsOneWidget);
    // Chaque point se lit aussi sans la souris, transition comprise signalée.
    expect(
      find.bySemanticsLabel(
        RegExp(r'''Triathlon de Démoville.*3'30" /100 m · 200 m · transition comprise ; .*2'00" /100 m'''),
      ),
      findsOneWidget,
    );
    await tapVisible(tester, find.descendant(of: find.byType(SegmentedButton<Sport>), matching: find.text('Vélo')));
    expect(
      find.bySemanticsLabel(RegExp(r'23,1 km/h · 5 km · transition comprise ; .*30,0 km/h · 20 km')),
      findsOneWidget,
    );

    await tapVisible(tester, find.text('Triathlons'));
    await env.settle(tester);
    expect(find.text('TRIATHLONS : PAR DISCIPLINE'), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('évolution : sans épreuve enchaînée, rien ne change', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(id: 'dix', title: '10 km', raceDate: calendarDate(2026, 5, 1), distanceM: 10000, durationS: 3000),
    ]);
    await env.pump(tester, home: const EvolutionScreen());
    expect(find.text('Officielles'), findsOneWidget);
    expect(find.text('Triathlons'), findsNothing);
    expect(find.text('TRIATHLONS : PAR DISCIPLINE'), findsNothing);
    expect(find.text('RYTHME PAR DISCIPLINE EN TRIATHLON'), findsNothing);
    await env.dispose(tester);
  });

  testWidgets('records : meilleur rythme de chaque discipline', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [_triathlonS, _triathlonXxs]);
    await env.pump(tester, home: const RecordsScreen());

    expect(find.text('MEILLEURS RYTHMES EN TRIATHLON'), findsOneWidget);
    expect(find.text('2\'00" /100 m'), findsOneWidget);
    expect(find.text('30,0 km/h'), findsOneWidget);
    expect(find.text('5\'00" /km'), findsOneWidget);
    // Deuxième place : le XXS, dont la natation et le vélo contiennent une transition.
    expect(find.text('3\'30" /100 m'), findsOneWidget);
    expect(find.textContaining(RegExp(r'Triathlon\sXXS\s+·\s+200\sm\s+·\s+transition\scomprise')), findsOneWidget);
    expect(find.textContaining(RegExp(r'Triathlon\sXXS\s+·\s+1,5\skm')), findsOneWidget);
    await env.dispose(tester);
  });
}
