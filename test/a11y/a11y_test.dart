// Accessibilité (RGAA / EN 301 549 appliqués à l'app) : contrôles automatiques sur chaque écran.
//   - zones cliquables nommées pour les lecteurs d'écran (labeledTapTargetGuideline) ;
//   - cibles tactiles d'au moins 48 × 48 (androidTapTargetGuideline) ;
//   Le contraste n'est pas mesuré ici : le contrôle par capture d'écran se trompe sur les
//   grands chiffres réduits (FittedBox), il échantillonne le bord lissé des lettres.
//   Les vraies couleurs sont vérifiées par le calcul dans test/design/contrast_test.dart.
//   - textes agrandis à 200 % sans débordement ni erreur de mise en page.
import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/app/widgets/count_up.dart';
import 'package:app_course/features/auth/data/auth_repository.dart';
import 'package:app_course/features/auth/presentation/server_screen.dart';
import 'package:app_course/features/auth/presentation/sign_in_screen.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/presentation/course_detail_screen.dart';
import 'package:app_course/features/courses/presentation/course_form_screen.dart';
import 'package:app_course/features/courses/presentation/courses_screen.dart';
import 'package:app_course/features/documents/presentation/documents_screen.dart';
import 'package:app_course/features/evolution/presentation/evolution_screen.dart';
import 'package:app_course/features/impact/presentation/association_screen.dart';
import 'package:app_course/features/impact/presentation/impact_screen.dart';
import 'package:app_course/features/records/presentation/gallery_screen.dart';
import 'package:app_course/features/records/presentation/records_screen.dart';
import 'package:app_course/features/report/presentation/report_screen.dart';
import 'package:app_course/features/settings/presentation/server_accounts_screen.dart';
import 'package:app_course/features/settings/presentation/settings_screen.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/sync_engine_test.dart' show FakeServer;
import '../helpers.dart';

final _courses = [
  Course(
    id: 'semi',
    title: 'Semi-marathon de Démoville',
    raceDate: calendarDate(2026, 3, 8),
    distanceM: 21180,
    durationS: 6130,
    elevationGainM: 90,
  ),
  Course(
    id: 'nantes',
    title: '10 km de Valfleuri',
    raceDate: calendarDate(2026, 5, 17),
    distanceM: 10040,
    durationS: 2892,
  ),
  Course(
    id: 'restos',
    title: 'La Course du Cœur',
    raceDate: calendarDate(2026, 9, 20),
    distanceM: 10000,
    durationS: 3150,
    isCharity: true,
    associationName: 'Les Restos du Cœur',
    associationCause: CauseType.precarite,
    registrationDonationCents: 1500,
    documents: [
      CourseDocument(
        key: 'user-1/docs/a.pdf',
        name: 'facture.pdf',
        sizeBytes: 1000,
        addedAt: DateTime.utc(2026, 9, 2),
        kind: DocumentKind.invoice,
      ),
    ],
  ),
  Course(
    id: 'tc',
    title: 'The Conqueror Grand Défi',
    type: CourseType.theConqueror,
    raceDate: calendarDate(2026, 8, 30),
    distanceM: 72500,
    isCharity: true,
    associationName: 'The Conqueror',
    associationCause: CauseType.environnement,
    registrationDonationCents: 3500,
    impactMetric: ImpactMetric.trees,
    impactQuantity: 4,
  ),
  Course(
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
  ),
  Course(
    id: 'lyon',
    title: 'Marathon de Mont-Fictif',
    isPlanned: true,
    raceDate: calendarDate(2026, 10, 5),
    distanceM: 42195,
  ),
];

final _screens = <String, String>{
  'Courses': '/courses',
  'Fiche': '/courses/restos',
  'Formulaire': '/courses/nouvelle',
  'Fiche triathlon': '/courses/tri',
  'Formulaire triathlon': '/courses/tri/modifier',
  'Évolution': '/evolution',
  'Impact': '/impact',
  'Association': '/impact/association/${Uri.encodeComponent('Les Restos du Cœur')}',
  'Bilan': '/impact/bilan',
  'Justificatifs': '/impact/justificatifs',
  'Records': '/records',
  'Galerie': '/records/galerie',
  'Réglages': '/reglages',
  'Connexion': '/connexion',
  'Premier compte': '/premier-compte',
  'Serveur': '/serveur',
  'Comptes du serveur': '/comptes',
};

GoRouter _router(String location) => GoRouter(
  initialLocation: location,
  routes: [
    GoRoute(
      path: '/courses',
      builder: (_, _) => const CoursesScreen(),
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
    GoRoute(path: '/evolution', builder: (_, _) => const EvolutionScreen()),
    GoRoute(
      path: '/impact',
      builder: (_, _) => const ImpactScreen(),
      routes: [
        GoRoute(path: 'bilan', builder: (_, _) => const ReportScreen()),
        GoRoute(path: 'justificatifs', builder: (_, _) => const DocumentsScreen()),
        GoRoute(
          path: 'association/:name',
          builder: (_, s) => AssociationScreen(name: s.pathParameters['name']!),
        ),
      ],
    ),
    GoRoute(
      path: '/records',
      builder: (_, _) => const RecordsScreen(),
      routes: [GoRoute(path: 'galerie', builder: (_, _) => const GalleryScreen())],
    ),
    GoRoute(path: '/reglages', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/connexion', builder: (_, _) => const SignInScreen()),
    // Serveur personnel tout neuf : création du premier compte, propriétaire.
    GoRoute(
      path: '/premier-compte',
      builder: (_, _) => ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(FakeBackend(FakeServer(), firstAccount: true))),
        ],
        child: const SignInScreen(),
      ),
    ),
    GoRoute(path: '/comptes', builder: (_, _) => const ServerAccountsScreen()),
    GoRoute(
      path: '/serveur',
      builder: (_, _) => ServerScreen(
        current: testServerChoice.current,
        builtIn: testServerChoice.builtIn,
        onSave: testServerChoice.switchTo,
      ),
    ),
  ],
);

Future<TestEnv> _show(WidgetTester tester, String location, {double textScale = 1, bool dark = false}) async {
  final env = TestEnv();
  await env.seed(tester, _courses);
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = _router(location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: env.container,
      child: MaterialApp.router(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  await env.settle(tester);
  await tester.pump(const Duration(seconds: 2));
  return env;
}

void main() {
  setUpAll(() async {
    await TestEnv.init();
    SharedPreferences.setMockInitialValues({});
  });
  setUp(CountUp.resetForTest);

  for (final MapEntry(key: name, value: location) in _screens.entries) {
    testWidgets('accessibilité : $name', (tester) async {
      final problems = <String>[];

      // Erreurs de mise en page recueillies avec le widget en cause (au lieu d'interrompre le test).
      Future<void> collectLayoutErrors(String tag, Future<void> Function() body) async {
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final where = details.toString().split('\n').where((l) => l.contains('lib/')).map((l) => l.trim());
          problems.add('[$tag] ${details.exceptionAsString().split('\n').first} ${where.take(1).join()}');
        };
        try {
          await body();
        } finally {
          FlutterError.onError = previous;
        }
      }

      // Taille normale : lecteurs d'écran, cibles tactiles, contraste.
      await collectLayoutErrors('100 %', () async {
        final handle = tester.ensureSemantics();
        final env = await _show(tester, location);
        for (final (label, guideline) in [
          ('nom', labeledTapTargetGuideline),
          ('cible 48', androidTapTargetGuideline),
        ]) {
          final result = await guideline.evaluate(tester);
          if (!result.passed) problems.add('[$label] ${result.reason}');
        }
        await env.dispose(tester);
        handle.dispose();
      });

      // Textes agrandis à 200 % : aucune erreur de mise en page.
      await collectLayoutErrors('200 %', () async {
        final env = await _show(tester, location, textScale: 2);
        await env.dispose(tester);
      });

      // ignore: avoid_print
      if (problems.isNotEmpty) print('=== $name\n${problems.join('\n')}');
      expect(problems, isEmpty, reason: name);
    });
  }

  testWidgets("lecteur d'écran : titres en casse normale, titres déclarés, graphiques décrits", (tester) async {
    final handle = tester.ensureSemantics();
    var env = await _show(tester, '/courses/restos');
    // Affiché en capitales, lu tel que saisi ; déclaré comme titre.
    final title = tester.getSemantics(find.bySemanticsLabel('La Course du Cœur'));
    expect(title.flagsCollection.isHeader, isTrue);
    await env.dispose(tester);

    env = await _show(tester, '/evolution');
    // Courbe du cumul : valeurs finales lisibles (dessin sans texte sinon).
    expect(find.bySemanticsLabel(RegExp(r'^2026 : [0-9]+ km au .* ; 2025 : ')), findsOneWidget);
    // Titres de section déclarés comme titres.
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.header == true), findsWidgets);
    await env.dispose(tester);
    handle.dispose();
  });
}
