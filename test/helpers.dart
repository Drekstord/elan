import 'dart:io';

import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/core/database/database.dart';
import 'package:app_course/core/media/media_store.dart';
import 'package:app_course/core/providers.dart';
import 'package:app_course/core/server/server_config.dart';
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
  current: const ServerConfig(url: 'http://192.168.1.20:8000', key: 'cle-publique-de-test-assez-longue'),
  builtIn: const ServerConfig(url: 'https://exemple.supabase.co', key: 'cle-integree-de-test-assez-longue', builtIn: true),
  switchTo: (_) async {},
);

/// Date du jour figée pour les tests d'écran.
final testToday = calendarDate(2026, 10, 8);

/// Environnement complet en mémoire : base, photos, faux serveur, date figée.
class TestEnv {
  final AppDatabase db = AppDatabase.inMemory();
  final FakeServer server = FakeServer();
  late final ProviderContainer container = ProviderContainer(
    overrides: [
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
