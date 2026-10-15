import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/core/server/server_config.dart';
import 'package:app_course/features/auth/presentation/server_screen.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _builtIn = ServerConfig.onlineForTest('https://exemple.supabase.co');

void main() {
  late List<ServerConfig?> saved;
  late List<ServerConfig> checked;

  Future<void> show(WidgetTester tester, {ServerConfig current = _builtIn, ServerCheck result = ServerCheck.ok}) async {
    saved = [];
    checked = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ServerScreen(
          current: current,
          builtIn: _builtIn,
          onSave: (s) async => saved.add(s),
          check: (s) async {
            checked.add(s);
            return result;
          },
        ),
      ),
    );
  }

  Future<void> fillAndSave(WidgetTester tester, String address) async {
    await tester.tap(find.text('Mon serveur'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Adresse du serveur'), address);
    await tester.ensureVisible(find.text('Vérifier et enregistrer'));
    await tester.tap(find.text('Vérifier et enregistrer'));
    await tester.pump();
  }

  testWidgets("serveur ÉLAN par défaut, champ d'adresse caché", (tester) async {
    await show(tester);
    expect(find.text('Serveur ÉLAN'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Adresse du serveur'), findsNothing);
  });

  testWidgets('serveur personnel : une adresse suffit, vérifiée puis enregistrée, nettoyée', (tester) async {
    await show(tester);
    await fillAndSave(tester, ' 192.168.1.20:8000/ ');
    // Un seul champ : plus de clé à recopier.
    expect(find.byType(TextField), findsOneWidget);
    expect(checked, [const ServerConfig.personal('http://192.168.1.20:8000')]);
    expect(saved, [const ServerConfig.personal('http://192.168.1.20:8000')]);
  });

  testWidgets('http sur Internet refusé avant tout contact', (tester) async {
    await show(tester);
    await fillAndSave(tester, 'http://elan.exemple.fr');
    expect(find.textContaining('https://'), findsOneWidget);
    expect(checked, isEmpty);
    expect(saved, isEmpty);
  });

  testWidgets("l'adresse ne mène pas à un serveur ÉLAN : rien enregistré, message clair", (tester) async {
    await show(tester, result: ServerCheck.notElan);
    await fillAndSave(tester, 'http://nas.local:5000');
    expect(find.textContaining("ce n'est pas un serveur ÉLAN"), findsOneWidget);
    expect(saved, isEmpty);
  });

  testWidgets('serveur injoignable : rien enregistré, pistes données', (tester) async {
    await show(tester, result: ServerCheck.unreachable);
    await fillAndSave(tester, 'http://nas.local:8000');
    expect(find.textContaining('Serveur injoignable'), findsOneWidget);
    expect(saved, isEmpty);
  });

  testWidgets('retour au serveur ÉLAN depuis un serveur personnel', (tester) async {
    await show(tester, current: const ServerConfig.personal('http://nas.local:8000'));
    expect(find.widgetWithText(TextField, 'Adresse du serveur'), findsOneWidget);
    await tester.tap(find.text('Serveur ÉLAN'));
    await tester.pump();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    expect(saved, [null]);
  });

  Future<void> fillOnline(WidgetTester tester, String address, String key) async {
    await tester.tap(find.text('Serveur en ligne (Supabase)'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Adresse du serveur'), address);
    await tester.enterText(find.widgetWithText(TextField, 'Clé publique'), key);
    await tester.ensureVisible(find.text('Vérifier et enregistrer'));
    await tester.tap(find.text('Vérifier et enregistrer'));
    await tester.pump();
  }

  testWidgets('serveur en ligne : adresse et clé publique, vérifiées puis enregistrées', (tester) async {
    await show(tester);
    await fillOnline(tester, 'https://projet-test.exemple.fr/', 'sb_publishable_cle-de-test-publique');
    const expected = ServerConfig.online(
      url: 'https://projet-test.exemple.fr',
      key: 'sb_publishable_cle-de-test-publique',
    );
    expect(checked, [expected]);
    expect(saved, [expected]);
  });

  testWidgets('serveur en ligne : une clé secrète est refusée avant tout contact', (tester) async {
    await show(tester);
    await fillOnline(tester, 'https://projet-test.exemple.fr', 'sb_secret_cle-de-test');
    expect(find.textContaining("C'est une clé secrète"), findsOneWidget);
    expect(checked, isEmpty);
    expect(saved, isEmpty);
  });

  testWidgets('serveur en ligne : clé refusée par le projet, message clair', (tester) async {
    await show(tester, result: ServerCheck.badKey);
    await fillOnline(tester, 'https://projet-test.exemple.fr', 'sb_publishable_cle-de-test-publique');
    expect(find.textContaining('Le serveur refuse cette clé'), findsOneWidget);
    expect(saved, isEmpty);
  });

  testWidgets('app sans serveur intégré : serveur personnel par défaut, serveur en ligne proposé', (tester) async {
    saved = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ServerScreen(current: null, builtIn: null, onSave: (s) async => saved.add(s)),
      ),
    );
    expect(find.text('Serveur ÉLAN'), findsNothing);
    expect(find.text('Mon serveur'), findsOneWidget);
    expect(find.text('Serveur en ligne (Supabase)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Adresse du serveur'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Clé publique'), findsNothing);
  });
}
