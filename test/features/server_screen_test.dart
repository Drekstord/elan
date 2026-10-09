import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/core/server/server_config.dart';
import 'package:app_course/features/auth/presentation/server_screen.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _builtIn = ServerConfig(url: 'https://exemple.supabase.co', key: 'cle-integree-de-test-assez-longue', builtIn: true);
const _key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.cle.publique';

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

  Future<void> fillAndSave(WidgetTester tester, String address, String key) async {
    await tester.tap(find.text('Mon serveur'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Adresse du serveur'), address);
    await tester.enterText(find.widgetWithText(TextField, 'Clé publique'), key);
    await tester.ensureVisible(find.text('Vérifier et enregistrer'));
    await tester.tap(find.text('Vérifier et enregistrer'));
    await tester.pump();
  }

  testWidgets('serveur ÉLAN par défaut, champs cachés', (tester) async {
    await show(tester);
    expect(find.text('Serveur ÉLAN'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Adresse du serveur'), findsNothing);
  });

  testWidgets('serveur personnel vérifié puis enregistré, adresse nettoyée', (tester) async {
    await show(tester);
    await fillAndSave(tester, ' 192.168.1.20:8000/ ', '$_key\n');
    expect(checked, [const ServerConfig(url: 'http://192.168.1.20:8000', key: _key)]);
    expect(saved, [const ServerConfig(url: 'http://192.168.1.20:8000', key: _key)]);
  });

  testWidgets('http sur Internet refusé avant tout contact', (tester) async {
    await show(tester);
    await fillAndSave(tester, 'http://elan.exemple.fr', _key);
    expect(find.textContaining('https://'), findsOneWidget);
    expect(checked, isEmpty);
    expect(saved, isEmpty);
  });

  testWidgets('clé refusée par le serveur : rien enregistré, message clair', (tester) async {
    await show(tester, result: ServerCheck.wrongKey);
    await fillAndSave(tester, 'http://nas.local:8000', _key);
    expect(find.text('Le serveur refuse cette clé. Vérifie la clé publique.'), findsOneWidget);
    expect(saved, isEmpty);
  });

  testWidgets('retour au serveur ÉLAN depuis un serveur personnel', (tester) async {
    await show(tester, current: const ServerConfig(url: 'http://nas.local:8000', key: _key));
    expect(find.widgetWithText(TextField, 'Adresse du serveur'), findsOneWidget);
    await tester.tap(find.text('Serveur ÉLAN'));
    await tester.pump();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    expect(saved, [null]);
  });
}
