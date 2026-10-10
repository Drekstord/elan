// Captures d'écran pour relire le design (pas un test de non-régression).
//   flutter test test/screenshots --update-goldens --tags screenshots --run-skipped
// Images produites dans test/screenshots/out/ (ignoré par git).
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:app_course/features/auth/data/auth_repository.dart';
import 'package:app_course/features/auth/presentation/server_screen.dart';
import 'package:app_course/features/auth/presentation/sign_in_screen.dart';
import 'package:app_course/features/settings/presentation/server_accounts_screen.dart';
import 'package:app_course/app/shell.dart';
import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/presentation/course_detail_screen.dart';
import 'package:app_course/features/courses/presentation/course_form_screen.dart';
import 'package:app_course/features/courses/presentation/courses_screen.dart';
import 'package:app_course/features/documents/presentation/documents_screen.dart';
import 'package:app_course/features/evolution/presentation/evolution_screen.dart';
import 'package:app_course/features/impact/presentation/association_screen.dart';
import 'package:app_course/features/impact/presentation/impact_screen.dart';
import 'package:app_course/features/records/presentation/records_screen.dart';
import 'package:app_course/features/report/presentation/report_screen.dart';
import 'package:app_course/features/settings/presentation/settings_screen.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/sync_engine_test.dart' show FakeServer;
import '../helpers.dart';

Future<void> loadTestFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
    }
    await loader.load();
  }

  final fonts = Directory('assets/fonts').listSync().whereType<File>().map((f) => f.path);
  await load('BarlowCondensed', fonts.where((p) => p.contains('BarlowCondensed') && p.endsWith('.ttf')).toList());
  await load('PlusJakartaSans', fonts.where((p) => p.contains('PlusJakartaSans') && p.endsWith('.ttf')).toList());
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  await load('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf']);
}

final _sample = [
  Course(
    id: 'semi',
    title: 'Semi-marathon de Démoville',
    raceDate: calendarDate(2026, 3, 8),
    distanceM: 21180,
    durationS: 6130,
    elevationGainM: 90,
    bibPhotoKey: null,
  ),
  Course(
    id: 'nantes',
    title: '10 km de Valfleuri',
    raceDate: calendarDate(2026, 5, 17),
    distanceM: 10040,
    durationS: 2892,
  ),
  Course(
    id: 'rennes',
    title: '10 km de Bois-Joli',
    raceDate: calendarDate(2025, 10, 12),
    distanceM: 10000,
    durationS: 3010,
  ),
  Course(
    id: 'trail',
    title: 'Trail des Monts Imaginaires',
    raceDate: calendarDate(2026, 6, 14),
    distanceM: 23400,
    durationS: 9420,
    elevationGainM: 640,
    notes: 'Boueux mais magnifique, montée finale très dure.',
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
    associationDescription: 'Aider les personnes démunies, notamment par l\'accès à des repas gratuits.',
    sponsorCentsPerKm: 150,
    registrationDonationCents: 1500,
    fundraisingCents: 12000,
    documents: [
      CourseDocument(
        key: 'user-1/docs/a.pdf',
        name: 'Facture inscription.pdf',
        sizeBytes: 184320,
        addedAt: DateTime.utc(2026, 9, 2),
        kind: DocumentKind.invoice,
      ),
      CourseDocument(
        key: 'user-1/docs/b.jpg',
        name: 'Reçu de don.jpg',
        sizeBytes: 1258291,
        addedAt: DateTime.utc(2026, 9, 21),
      ),
    ],
  ),
  Course(
    id: 'rett',
    title: 'Octobre Solidaire',
    raceDate: calendarDate(2026, 10, 4),
    distanceM: 7300,
    durationS: 3013,
    isCharity: true,
    associationName: 'Association Exemple Handicap (AEH)',
    associationCause: CauseType.handicap,
    registrationDonationCents: 1000,
    fundraisingCents: 34000,
  ),
  Course(
    id: 'tc',
    title: 'The Conqueror · Grand Défi',
    type: CourseType.theConqueror,
    raceDate: calendarDate(2026, 8, 30),
    distanceM: 72500,
    teamSize: 2,
    challengeDistanceM: 145000,
    isCharity: true,
    associationName: 'The Conqueror (Eden Reforestation & Plastic Bank)',
    associationCause: CauseType.environnement,
    registrationDonationCents: 3500,
    impactMetric: ImpactMetric.trees,
    impactQuantity: 4,
  ),
  Course(
    id: 'tc2',
    title: "The Conqueror · Petit Défi",
    type: CourseType.theConqueror,
    raceDate: calendarDate(2026, 2, 10),
    distanceM: 56500,
    isCharity: true,
    associationName: 'The Conqueror (Plastic Bank)',
    associationCause: CauseType.environnement,
    registrationDonationCents: 5000,
    impactMetric: ImpactMetric.oceanBottles,
    impactQuantity: 40,
  ),
  Course(
    id: 'lyon',
    title: 'Marathon de Mont-Fictif',
    isPlanned: true,
    raceDate: calendarDate(2026, 10, 5),
    distanceM: 42195,
  ),
  Course(
    id: 'paris',
    title: 'Marathon de Port-Imaginaire',
    isPlanned: true,
    raceDate: calendarDate(2027, 4, 11),
    distanceM: 42195,
    isCharity: true,
    associationName: 'AFM-Téléthon',
    associationCause: CauseType.sante,
  ),
  Course(
    id: 'tri',
    title: 'Triathlon de Bois-Joli',
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
];

const _phone = Size(390, 844);
const _desktop = Size(1280, 860);
const _wide = Size(1600, 900);

void main() {
  setUpAll(() async {
    await TestEnv.init();
    await loadTestFonts();
    SharedPreferences.setMockInitialValues({'legacy_v1_imported_to': 'user-1'});
  });

  Future<void> capture(
    WidgetTester tester,
    String name, {
    required String location,
    Size size = _phone,
    bool dark = false,
    Color? wallpaper,
  }) async {
    final env = TestEnv();
    await env.seed(tester, _sample);
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(
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
              ],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/evolution', builder: (_, _) => const EvolutionScreen())],
            ),
            StatefulShellBranch(
              routes: [
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
              ],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/records', builder: (_, _) => const RecordsScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/reglages', builder: (_, _) => const SettingsScreen())],
            ),
          ],
        ),
        // Serveur personnel : connexion, premier compte, choix du serveur, comptes des proches.
        GoRoute(path: '/connexion', builder: (_, _) => const SignInScreen()),
        GoRoute(
          path: '/premier-compte',
          builder: (_, _) => ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(AuthRepository(FakeBackend(FakeServer(), firstAccount: true))),
            ],
            child: const SignInScreen(),
          ),
        ),
        GoRoute(
          path: '/serveur',
          builder: (_, _) => ServerScreen(
            current: testServerChoice.current,
            builtIn: testServerChoice.builtIn,
            onSave: testServerChoice.switchTo,
          ),
        ),
        GoRoute(path: '/comptes', builder: (_, _) => const ServerAccountsScreen()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: env.container,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: wallpaper == null
              ? AppTheme.light()
              : AppTheme.fromWallpaper(ColorScheme.fromSeed(seedColor: wallpaper)),
          darkTheme: wallpaper == null
              ? AppTheme.dark()
              : AppTheme.fromWallpaper(ColorScheme.fromSeed(seedColor: wallpaper, brightness: Brightness.dark)),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await env.settle(tester);
    }
    await tester.pump(const Duration(seconds: 2)); // fin du défilement des chiffres
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
    await env.dispose(tester);
  }

  testWidgets('accueil', (t) => capture(t, 'accueil_clair', location: '/courses'));
  testWidgets('accueil sombre', (t) => capture(t, 'accueil_sombre', location: '/courses', dark: true));
  testWidgets('accueil ordinateur', (t) => capture(t, 'accueil_ordinateur', location: '/courses', size: _desktop));
  testWidgets('fiche', (t) => capture(t, 'fiche_solidaire', location: '/courses/restos'));
  testWidgets('fiche à saisir', (t) => capture(t, 'fiche_a_saisir', location: '/courses/lyon', dark: true));
  testWidgets('formulaire', (t) => capture(t, 'formulaire', location: '/courses/nouvelle'));
  testWidgets('impact', (t) => capture(t, 'impact', location: '/impact'));
  testWidgets('records', (t) => capture(t, 'records', location: '/records', dark: true));
  testWidgets('réglages', (t) => capture(t, 'reglages', location: '/reglages'));
  testWidgets('fiche triathlon', (t) => capture(t, 'fiche_triathlon', location: '/courses/tri'));
  testWidgets(
    'formulaire triathlon',
    (t) => capture(t, 'formulaire_triathlon', location: '/courses/tri/modifier', size: const Size(390, 1500)),
  );
  testWidgets('connexion', (t) => capture(t, 'connexion', location: '/connexion'));
  testWidgets('premier compte', (t) => capture(t, 'premier_compte', location: '/premier-compte'));
  testWidgets('serveur', (t) => capture(t, 'serveur', location: '/serveur'));
  testWidgets('comptes du serveur', (t) => capture(t, 'comptes_serveur', location: '/comptes', dark: true));

  testWidgets(
    'large accueil sombre',
    (t) => capture(t, 'large_accueil_sombre', location: '/courses', size: _wide, dark: true),
  );
  testWidgets('large accueil clair', (t) => capture(t, 'large_accueil_clair', location: '/courses', size: _wide));
  testWidgets('large fiche', (t) => capture(t, 'large_fiche', location: '/courses/restos', size: _wide, dark: true));
  testWidgets('large records', (t) => capture(t, 'large_records', location: '/records', size: _wide));
  testWidgets('large impact', (t) => capture(t, 'large_impact', location: '/impact', size: _wide));
  testWidgets(
    'large impact sombre',
    (t) => capture(t, 'large_impact_sombre', location: '/impact', size: _wide, dark: true),
  );

  testWidgets('evolution', (t) => capture(t, 'evolution', location: '/evolution'));
  testWidgets('large evolution', (t) => capture(t, 'large_evolution', location: '/evolution', size: _wide));
  testWidgets(
    'large evolution sombre',
    (t) => capture(t, 'large_evolution_sombre', location: '/evolution', size: _wide, dark: true),
  );

  // Material You : fonds d'écran fictifs bleu et rose.
  testWidgets(
    'you accueil',
    (t) => capture(t, 'you_accueil_bleu', location: '/courses', wallpaper: const Color(0xFF3A6EA5)),
  );
  testWidgets(
    'you accueil sombre',
    (t) => capture(t, 'you_accueil_rose_sombre', location: '/courses', dark: true, wallpaper: const Color(0xFFC2185B)),
  );
  testWidgets(
    'you impact',
    (t) => capture(t, 'you_impact_bleu', location: '/impact', wallpaper: const Color(0xFF3A6EA5)),
  );
  testWidgets(
    'you evolution',
    (t) => capture(t, 'you_evolution_rose', location: '/evolution', wallpaper: const Color(0xFFC2185B)),
  );

  testWidgets('bilan', (t) => capture(t, 'bilan', location: '/impact/bilan'));
  testWidgets('large bilan', (t) => capture(t, 'large_bilan', location: '/impact/bilan', size: _wide));

  testWidgets('justificatifs', (t) => capture(t, 'justificatifs', location: '/impact/justificatifs'));
  testWidgets(
    'fiche justificatifs',
    (t) => capture(t, 'large_fiche_justificatifs', location: '/courses/restos', size: _wide),
  );

  testWidgets(
    'association',
    (t) => capture(t, 'association', location: '/impact/association/${Uri.encodeComponent('Les Restos du Cœur')}'),
  );
  testWidgets(
    'large association',
    (t) => capture(
      t,
      'large_association',
      location: '/impact/association/${Uri.encodeComponent('Les Restos du Cœur')}',
      size: _wide,
    ),
  );

  test('pas de photo factice', () => expect(_sample.every((c) => c.photoKeys.isEmpty), isTrue));
}
