import 'dart:io';

import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/core/backend/backend.dart';
import 'package:app_course/core/database/database.dart';
import 'package:app_course/core/media/media_store.dart';
import 'package:app_course/core/providers.dart';
import 'package:app_course/core/server/server_config.dart';
import 'package:app_course/core/sync/remote_gateway.dart';
import 'package:app_course/features/courses/courses_providers.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/presentation/course_detail_screen.dart';
import 'package:app_course/features/courses/presentation/course_form_screen.dart';
import 'package:app_course/features/courses/presentation/courses_screen.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/sync_engine_test.dart' show FakeServer;

/// Serveur personnel en cours (serveur intégré disponible), pour les écrans qui l'affichent.
final testServerChoice = ServerChoice(
  current: const ServerConfig.personal('http://192.168.1.20:8000'),
  builtIn: const ServerConfig.onlineForTest('https://exemple.supabase.co'),
  switchTo: (_) async {},
);

/// Faux serveur personnel : le compte de test en est le propriétaire, avec un proche.
class FakeBackend implements Backend, ServerAccounts {
  final RemoteGateway _gateway;

  /// Serveur tout neuf : l'écran de connexion propose de créer le premier compte.
  final bool firstAccount;

  final List<ServerAccount> people = [
    const ServerAccount(id: 'user-1', email: 'coureuse@exemple.fr', isOwner: true),
    const ServerAccount(id: 'user-2', email: 'proche@exemple.fr', isOwner: false),
  ];

  FakeBackend(this._gateway, {this.firstAccount = false});

  @override
  BackendUser? get currentUser => const BackendUser(id: 'user-1', email: 'coureuse@exemple.fr', isOwner: true);

  @override
  Stream<BackendUser?> get userChanges => const Stream.empty();

  @override
  RemoteGateway get gateway => _gateway;

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> signOut() async {}

  int signOutOthersCount = 0;

  @override
  Future<void> signOutOtherDevices() async => signOutOthersCount++;

  @override
  bool get needsCurrentPassword => true;

  @override
  Future<void> changePassword(String newPassword, {String? current}) async {}

  /// Préférences gardées par le faux serveur (null : serveur qui n'en garde pas).
  Map<String, dynamic>? preferences;

  /// Serveur injoignable pour les préférences.
  bool failPreferences = false;

  @override
  Future<Map<String, dynamic>?> readPreferences() async =>
      failPreferences ? throw const AuthError(AuthFailure.offline) : preferences;

  @override
  Future<void> writePreferences(Map<String, dynamic> value) async =>
      failPreferences ? throw const AuthError(AuthFailure.offline) : preferences = Map.of(value);

  @override
  Future<bool> needsFirstAccount() async => firstAccount;

  /// Code d'installation attendu par le faux serveur.
  String setupCode = 'ABCD2345';

  @override
  Future<void> createFirstAccount(String email, String password, {required String setupCode}) async {
    if (setupCode.trim().toUpperCase() != this.setupCode) throw const AuthError(AuthFailure.wrongSetupCode);
  }

  @override
  ServerAccounts? get accounts => this;

  @override
  Future<void> dispose() async {}

  @override
  Future<List<ServerAccount>> list() async => List.of(people);

  @override
  Future<void> create(String email, String password) async {
    if (people.any((a) => a.email == email)) throw const AuthError(AuthFailure.emailTaken);
    people.add(ServerAccount(id: 'user-${people.length + 1}', email: email, isOwner: false));
  }

  @override
  Future<void> resetPassword(String accountId, String newPassword) async {}

  @override
  Future<void> delete(String accountId) async => people.removeWhere((a) => a.id == accountId);
}

/// Date du jour figée pour les tests d'écran.
final testToday = calendarDate(2026, 10, 8);

/// Environnement complet en mémoire : base, photos, faux serveur, date figée.
class TestEnv {
  final AppDatabase db = AppDatabase.inMemory();
  final FakeServer server = FakeServer();
  late final FakeBackend backend = FakeBackend(server);
  late final ProviderContainer container = ProviderContainer(
    overrides: [
      backendProvider.overrideWithValue(backend),
      userIdProvider.overrideWithValue('user-1'),
      databaseProvider.overrideWithValue(db),
      mediaStoreProvider.overrideWithValue(MediaStore(Directory.systemTemp.createTempSync('elan_ui'), 'user-1')),
      remoteGatewayProvider.overrideWithValue(server),
      todayProvider.overrideWith((ref) => Stream.value(testToday)),
      serverChoiceProvider.overrideWithValue(testServerChoice),
    ],
  );

  static Future<void> init() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await initializeDateFormatting('fr');
  }

  /// Écritures directes en base, hors de la fausse horloge des tests d'écran.
  Future<void> seed(WidgetTester tester, List<Course> courses) => tester.runAsync(() async {
    final repo = container.read(courseRepositoryProvider);
    for (final c in courses) {
      await repo.save(c);
    }
  });

  Future<List<Course>> stored(WidgetTester tester) async =>
      (await tester.runAsync(() => container.read(courseRepositoryProvider).watchCourses().first))!;

  /// Affiche [location] avec les routes de la section Courses.
  Future<void> pump(WidgetTester tester, {String location = '/courses', Widget? home}) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/courses',
          builder: (_, _) => home ?? const CoursesScreen(),
          routes: [
            GoRoute(path: 'nouvelle', builder: (_, _) => const CourseFormScreen()),
            GoRoute(
              path: ':id',
              builder: (_, s) => CourseDetailScreen(courseId: s.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'modifier',
                  builder: (_, s) => CourseFormScreen(courseId: s.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await settle(tester);
  }

  /// Laisse passer les requêtes Drift (vraie horloge) puis redessine.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
  }

  /// Fin de test : vide la synchro différée (minuteur de 2 s) et démonte l'écran.
  /// Le conteneur et la base sont libérés après le test, hors de l'horloge simulée
  /// (sinon la fermeture des flux Drift y laisserait des minuteurs en attente).
  Future<void> dispose(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    await tester.pumpWidget(const SizedBox());
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  }
}

/// Texte affiché, espaces insécables du format français normalisés.
Finder findText(String text) => find.byWidgetPredicate(
  (w) => w is Text && (w.data ?? w.textSpan?.toPlainText())?.replaceAll(RegExp('[\u00a0\u202f]'), ' ') == text,
  description: 'texte "$text"',
);
