import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/courses/presentation/course_detail_screen.dart';
import '../features/courses/presentation/course_form_screen.dart';
import '../features/courses/presentation/courses_screen.dart';
import '../features/documents/presentation/documents_screen.dart';
import '../features/evolution/presentation/evolution_screen.dart';
import '../features/impact/presentation/association_screen.dart';
import '../features/impact/presentation/impact_screen.dart';
import '../features/records/presentation/gallery_screen.dart';
import '../features/records/presentation/records_screen.dart';
import '../features/report/presentation/report_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'shell.dart';

class Routes {
  static const signIn = '/connexion';
  static const courses = '/courses';
  static const newCourse = '/courses/nouvelle';
  static String course(String id) => '/courses/$id';
  static String editCourse(String id) => '/courses/$id/modifier';
  static const evolution = '/evolution';
  static const impact = '/impact';
  static const report = '/impact/bilan';
  static const documents = '/impact/justificatifs';
  static String association(String name) => '/impact/association/${Uri.encodeComponent(name)}';
  static const records = '/records';
  static const gallery = '/records/galerie';
  static const settings = '/reglages';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Réévalue la redirection à chaque connexion / déconnexion.
  final authChanges = ValueNotifier(0);
  ref.listen(currentUserProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  final router = GoRouter(
    initialLocation: Routes.courses,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      if (user.isLoading) return null;
      final signedIn = user.value != null;
      final onSignIn = state.matchedLocation == Routes.signIn;
      if (!signedIn) return onSignIn ? null : Routes.signIn;
      return onSignIn ? Routes.courses : null;
    },
    routes: [
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.courses,
                builder: (_, _) => const CoursesScreen(),
                routes: [
                  GoRoute(path: 'nouvelle', builder: (_, _) => const CourseFormScreen()),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => CourseDetailScreen(courseId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'modifier',
                        builder: (_, state) => CourseFormScreen(courseId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.evolution, builder: (_, _) => const EvolutionScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.impact,
                builder: (_, _) => const ImpactScreen(),
                routes: [
                  GoRoute(path: 'bilan', builder: (_, _) => const ReportScreen()),
                  GoRoute(path: 'justificatifs', builder: (_, _) => const DocumentsScreen()),
                  GoRoute(
                    path: 'association/:name',
                    builder: (_, state) => AssociationScreen(name: state.pathParameters['name']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.records,
                builder: (_, _) => const RecordsScreen(),
                routes: [GoRoute(path: 'galerie', builder: (_, _) => const GalleryScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
