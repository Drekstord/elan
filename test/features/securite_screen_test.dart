import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/core/server/server_config.dart';
import 'package:app_course/features/auth/data/auth_repository.dart';
import 'package:app_course/features/auth/presentation/sign_in_screen.dart';
import 'package:app_course/features/settings/presentation/settings_screen.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/sync_engine_test.dart' show FakeServer;
import '../helpers.dart';

void main() {
  setUpAll(() async {
    await TestEnv.init();
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'ÉLAN',
      packageName: 'fr.elan.course',
      version: '2.14.0',
      buildNumber: '22',
      buildSignature: '',
    );
  });

  testWidgets('premier compte : le code d\'installation est demandé et vérifié', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final backend = FakeBackend(FakeServer(), firstAccount: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(backend)),
          serverChoiceProvider.overrideWithValue(testServerChoice),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SignInScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, "Code d'installation"), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Adresse e-mail'), 'coureuse@exemple.fr');
    await tester.enterText(find.widgetWithText(TextField, 'Mot de passe'), 'mot-de-passe-1');
    await tester.enterText(find.widgetWithText(TextField, 'Confirmer le mot de passe'), 'mot-de-passe-1');

    Future<void> submit() async {
      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();
    }

    await submit();
    expect(find.text("Saisis le code d'installation du serveur."), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, "Code d'installation"), 'FAUX2345');
    await submit();
    expect(find.textContaining("Code d'installation incorrect"), findsOneWidget);
    // On reste sur la création du premier compte : on peut corriger le code.
    expect(find.text('Créer mon compte'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, "Code d'installation"), 'abcd2345');
    await submit();
    expect(find.textContaining("Code d'installation"), findsWidgets);
    expect(find.textContaining('incorrect'), findsNothing);
  });

  testWidgets('réglages : déconnecter mes autres appareils, après confirmation', (tester) async {
    final env = TestEnv();
    await env.pump(tester, home: const SettingsScreen());
    final button = find.text('Déconnecter mes autres appareils');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.textContaining('devront se reconnecter'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();
    expect(env.backend.signOutOthersCount, 0);

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Déconnecter mes autres appareils'));
    await tester.pumpAndSettle();
    expect(env.backend.signOutOthersCount, 1);
    expect(find.text('Tes autres appareils sont déconnectés.'), findsOneWidget);
    // Le message disparaît de lui-même.
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    await env.dispose(tester);
  });
}
