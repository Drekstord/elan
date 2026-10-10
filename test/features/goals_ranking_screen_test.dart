import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/evolution/presentation/evolution_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  setUpAll(TestEnv.init);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('formulaire : temps visé et classement enregistrés, puis affichés sur la fiche', (tester) async {
    final env = TestEnv();
    await env.pump(tester, location: '/courses/nouvelle');

    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), '10 km de Valfleuri');
    await tester.enterText(find.widgetWithText(TextField, 'Distance (km)'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Temps (h:mm:ss)'), '48:12');
    await tester.enterText(find.widgetWithText(TextField, 'Temps visé (facultatif)'), '49:00');
    await tester.enterText(find.widgetWithText(TextField, 'Place'), '142');
    await tester.enterText(find.widgetWithText(TextField, 'Arrivants'), '980');
    await tester.enterText(find.widgetWithText(TextField, 'Catégorie'), 'SEH');
    await tester.enterText(find.widgetWithText(TextField, 'Place dans la catégorie'), '12');
    await tester.enterText(find.widgetWithText(TextField, 'Arrivants de la catégorie'), '85');
    await tapVisible(tester, find.text('Enregistrer'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single;
    expect(saved.targetDurationS, 2940);
    expect(
      saved.ranking,
      const Ranking(overall: 142, finishers: 980, category: 12, categoryFinishers: 85, categoryName: 'SEH'),
    );

    expect(findText('OBJECTIF BATTU DE 0:48'), findsOneWidget);
    expect(findText('142e sur 980'), findsOneWidget);
    expect(findText('dans les 15 % premiers'), findsWidgets);
    expect(findText('Catégorie SEH'), findsOneWidget);
    expect(findText('12e sur 85'), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('formulaire : une place au-delà du nombre d\'arrivants est refusée', (tester) async {
    final env = TestEnv();
    await env.pump(tester, location: '/courses/nouvelle');
    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), '10 km');
    await tester.enterText(find.widgetWithText(TextField, 'Distance (km)'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Place'), '50');
    await tester.enterText(find.widgetWithText(TextField, 'Arrivants'), '40');
    await tapVisible(tester, find.text('Enregistrer'));
    expect(find.textContaining('La place ne peut pas dépasser'), findsWidgets);
    expect(await env.stored(tester), isEmpty);
    await env.dispose(tester);
  });

  testWidgets('course à venir : temps visé gardé, pas de classement à saisir', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(
        id: 'semi',
        title: 'Semi de Démoville',
        raceDate: calendarDate(2026, 11, 15),
        distanceM: 21100,
        isPlanned: true,
        targetDurationS: 6300,
      ),
    ]);
    await env.pump(tester, location: '/courses/semi');
    expect(find.textContaining('OBJECTIF 1:45:00'), findsOneWidget);
    expect(find.textContaining("4'59\" /KM"), findsOneWidget);
    await env.dispose(tester);

    final form = TestEnv();
    await form.seed(tester, [
      Course(id: 'semi', title: 'Semi', raceDate: calendarDate(2026, 11, 15), distanceM: 21100, isPlanned: true),
    ]);
    await form.pump(tester, location: '/courses/semi/modifier');
    expect(find.widgetWithText(TextField, 'Temps visé (facultatif)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Place'), findsNothing);
    await form.dispose(tester);
  });

  testWidgets('accueil : objectif annuel fixé, avancement et retard sur le rythme', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(id: 'a', title: 'Trail', raceDate: calendarDate(2026, 3, 1), distanceM: 120000, durationS: 50000),
      Course(id: 'b', title: 'Ultra', raceDate: calendarDate(2026, 6, 1), distanceM: 87000, durationS: 40000),
    ]);
    await env.pump(tester);
    expect(find.text('OBJECTIF 2026'), findsNothing);

    await tapVisible(tester, find.text('Fixer un objectif annuel'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Kilomètres à courir en 2026'), '500');
    await tester.tap(find.text('Enregistrer'));
    await env.settle(tester);

    expect(find.text('OBJECTIF 2026'), findsOneWidget);
    expect(findText('207 km sur 500 km'), findsOneWidget);
    expect(findText('41 %'), findsOneWidget);
    // 8 octobre : il faudrait en être à 385 km.
    expect(find.textContaining('En retard de'), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('évolution : classement d\'une course à l\'autre', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(
        id: 'a',
        title: '10 km de Valfleuri',
        raceDate: calendarDate(2026, 3, 1),
        distanceM: 10000,
        durationS: 3000,
        ranking: const Ranking(overall: 300, finishers: 1000),
      ),
      Course(
        id: 'b',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2026, 9, 1),
        distanceM: 10000,
        durationS: 2900,
        ranking: const Ranking(overall: 142, finishers: 980),
      ),
    ]);
    await env.pump(tester, home: const EvolutionScreen());
    final chart = find.bySemanticsLabel(
      RegExp(r'10 km de Valfleuri.*300e sur 1.000.*30 % premiers ; .*142e sur 980.*15 % premiers'),
    );
    await tester.scrollUntilVisible(chart, 300, scrollable: find.byType(Scrollable).first);
    expect(chart, findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('évolution : le bilan annuel se prépare, prêt à partager', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(
        id: 'a',
        title: '10 km de Valfleuri',
        raceDate: calendarDate(2026, 3, 1),
        distanceM: 10000,
        durationS: 3000,
      ),
      Course(
        id: 'b',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2025, 9, 1),
        distanceM: 10000,
        durationS: 2900,
      ),
    ]);
    await env.pump(tester, home: const EvolutionScreen());
    await tester.tap(find.byTooltip("Bilan de l'année à partager"));
    await tester.pumpAndSettle();
    expect(find.text('BILAN 2026'), findsOneWidget);
    expect(find.textContaining('10 km de Valfleuri'), findsOneWidget);
    // Année précédente.
    await tester.tap(find.byTooltip('2025'));
    await tester.pumpAndSettle();
    expect(find.text('BILAN 2025'), findsOneWidget);
    await env.dispose(tester);
  });
}
