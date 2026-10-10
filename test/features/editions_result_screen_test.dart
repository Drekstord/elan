import 'package:app_course/features/courses/domain/course.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  setUpAll(TestEnv.init);

  testWidgets('fiche : écart avec l\'édition précédente, et liste des éditions', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(
        id: 'e26',
        title: '10 km de Valfleuri 2026',
        raceDate: calendarDate(2026, 5, 17),
        distanceM: 10000,
        durationS: 2892,
      ),
      Course(
        id: 'e25',
        title: '10 km de Valfleuri 2025',
        raceDate: calendarDate(2025, 5, 18),
        distanceM: 10000,
        durationS: 3022,
        ranking: const Ranking(overall: 300, finishers: 1000),
      ),
      Course(
        id: 'e24',
        title: '10 km de Valfleuri',
        raceDate: calendarDate(2024, 5, 19),
        distanceM: 10100,
        durationS: 3100,
      ),
      Course(
        id: 'x',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2025, 10, 12),
        distanceM: 10000,
        durationS: 3010,
      ),
    ]);
    await env.pump(tester, location: '/courses/e26');

    expect(find.text('ÉDITIONS PRÉCÉDENTES'), findsOneWidget);
    expect(find.text("2:10 de mieux qu'en 2025"), findsOneWidget);
    expect(find.text('10 km de Valfleuri 2025'), findsOneWidget);
    expect(find.text('50:22'), findsOneWidget);
    expect(findText('300e sur 1 000'), findsOneWidget);
    expect(find.text('51:40'), findsOneWidget);
    expect(find.text('10 km de Bois-Joli'), findsNothing);
    await env.dispose(tester);

    // Une course sans édition précédente n'affiche rien.
    final alone = TestEnv();
    await alone.seed(tester, [
      Course(
        id: 'x',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2025, 10, 12),
        distanceM: 10000,
        durationS: 3010,
      ),
    ]);
    await alone.pump(tester, location: '/courses/x');
    expect(find.text('ÉDITIONS PRÉCÉDENTES'), findsNothing);
    await alone.dispose(tester);
  });

  testWidgets('course à venir : les éditions passées sont rappelées, sans écart', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(
        id: 'e26',
        title: 'Semi de Démoville 2026',
        raceDate: calendarDate(2026, 11, 15),
        distanceM: 21100,
        isPlanned: true,
      ),
      Course(
        id: 'e25',
        title: 'Semi de Démoville 2025',
        raceDate: calendarDate(2025, 11, 16),
        distanceM: 21100,
        durationS: 6130,
      ),
    ]);
    await env.pump(tester, location: '/courses/e26');
    expect(find.text('ÉDITIONS PRÉCÉDENTES'), findsOneWidget);
    expect(find.text('1:42:10'), findsOneWidget);
    expect(find.textContaining("qu'en 2025"), findsNothing);
    // Une course à venir se met dans l'agenda.
    expect(find.byTooltip("Ajouter à l'agenda"), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('saisir mon résultat : le classement se saisit dans la même fenêtre', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(
        id: 'lyon',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2026, 10, 5),
        distanceM: 10000,
        isPlanned: true,
        targetDurationS: 3000,
      ),
    ]);
    await env.pump(tester, location: '/courses/lyon');
    await tester.tap(find.text('Saisir mon résultat'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Temps (h:mm:ss)'), '48:12');
    await tester.enterText(find.widgetWithText(TextField, 'Place'), '500');
    await tester.enterText(find.widgetWithText(TextField, 'Arrivants'), '400');
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    expect(find.textContaining('La place ne peut pas dépasser'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Place'), '142');
    await tester.enterText(find.widgetWithText(TextField, 'Arrivants'), '980');
    await tester.tap(find.text('Enregistrer'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single;
    expect(saved.isCompleted, isTrue);
    expect(saved.durationS, 2892);
    expect(saved.ranking, const Ranking(overall: 142, finishers: 980));
    expect(saved.targetDurationS, 3000, reason: 'le temps visé reste');
    await env.dispose(tester);
  });

  testWidgets('saisir mon résultat : sans classement, rien n\'est inventé', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(id: 'lyon', title: '10 km', raceDate: calendarDate(2026, 10, 5), distanceM: 10000, isPlanned: true),
    ]);
    await env.pump(tester, location: '/courses/lyon');
    await tester.tap(find.text('Saisir mon résultat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Temps (h:mm:ss)'), '48:12');
    await tester.tap(find.text('Enregistrer'));
    await env.settle(tester);
    expect((await env.stored(tester)).single.ranking, isNull);
    await env.dispose(tester);
  });
}
