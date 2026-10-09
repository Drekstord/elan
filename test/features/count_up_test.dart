import 'package:app_course/app/widgets/count_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: child),
  ),
);

String fmt(num v) => '${v.round()}';

void main() {
  setUp(CountUp.resetForTest);

  testWidgets('défile de 0 jusqu\'à la valeur, puis ne rejoue plus', (tester) async {
    await tester.pumpWidget(app(CountUp(id: 'a', value: 200, format: fmt)));
    expect(find.text('0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    final mid = int.parse((tester.widget<Text>(find.byType(Text)).data)!);
    expect(mid, inExclusiveRange(0, 200));
    await tester.pumpAndSettle();
    expect(find.text('200'), findsOneWidget);

    // Même compteur réaffiché (retour sur l'écran) : valeur directe.
    await tester.pumpWidget(app(const SizedBox()));
    await tester.pumpWidget(app(CountUp(id: 'a', value: 200, format: fmt)));
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('animations réduites : valeur affichée tout de suite', (tester) async {
    await tester.pumpWidget(app(CountUp(id: 'b', value: 42, format: fmt), reduceMotion: true));
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('lecteur d\'écran : seulement la valeur finale', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(app(CountUp(id: 'c', value: 585, format: fmt)));
    expect(find.bySemanticsLabel('585'), findsOneWidget);
    await tester.pumpAndSettle();
    handle.dispose();
  });
}
