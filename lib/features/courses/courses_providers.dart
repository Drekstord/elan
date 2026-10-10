import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend/backend.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import 'domain/course.dart';
import 'domain/course_query.dart';
import 'domain/course_stats.dart';

/// Date du jour (sans heure), mise à jour à minuit : une course « à venir »
/// passe d'elle-même en « résultat à saisir ».
final todayProvider = StreamProvider<DateTime>((ref) async* {
  while (true) {
    final now = DateTime.now();
    yield calendarDate(now.year, now.month, now.day);
    final midnight = DateTime(now.year, now.month, now.day + 1);
    await Future<void>.delayed(midnight.difference(now) + const Duration(seconds: 1));
  }
});

DateTime _today(Ref ref) {
  final now = DateTime.now();
  return ref.watch(todayProvider).value ?? calendarDate(now.year, now.month, now.day);
}

class CourseQueryController extends Notifier<CourseQuery> {
  @override
  CourseQuery build() => const CourseQuery();

  void setKind(CourseKind kind) => state = state.copyWith(kind: kind);

  /// Décocher « Solidaires » retire aussi la cause choisie.
  void setCharityOnly(bool value) => state = state.copyWith(charityOnly: value, cause: value ? state.cause : null);
  void setCause(CauseType? cause, {bool? charityOnly}) =>
      state = state.copyWith(cause: cause, charityOnly: charityOnly);
  void reset() => state = CourseQuery(sort: state.sort, descending: state.descending);
  void setSearch(String search) => state = state.copyWith(search: search);
  void setSort(CourseSort sort) => state = state.copyWith(sort: sort);
  void toggleDirection() => state = state.copyWith(descending: !state.descending);
}

final courseQueryProvider = NotifierProvider<CourseQueryController, CourseQuery>(CourseQueryController.new);

/// Liste affichée : filtrée, recherchée, triée.
final visibleCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final query = ref.watch(courseQueryProvider);
  final today = _today(ref);
  return ref.watch(coursesProvider).whenData((list) => query.apply(list, today));
});

final courseStatsProvider = Provider<CourseStats>(
  (ref) => CourseStats.of(ref.watch(coursesProvider).value ?? const []),
);

/// Objectif annuel de kilomètres courus, en mètres ; null si aucun n'est fixé.
/// Enregistré sur l'appareil, avec les données du compte.
///
/// L'appareil garde sa copie (l'app marche hors ligne) ; le serveur garde la dernière version
/// connue, pour qu'un objectif fixé sur le téléphone se retrouve sur l'ordinateur. Entre les
/// deux, le changement le plus récent l'emporte.
class YearGoalController extends AsyncNotifier<int?> {
  static const _key = 'goal.year_m';
  static const _stampKey = 'goal.updated_ms';

  @override
  Future<int?> build() async {
    final db = ref.watch(databaseProvider);
    final backend = ref.watch(backendProvider);
    final local = int.tryParse(await db.readMeta(_key) ?? '') ?? 0;
    final stamp = int.tryParse(await db.readMeta(_stampKey) ?? '') ?? 0;
    unawaited(_reconcile(db, backend, local, stamp));
    return local > 0 ? local : null;
  }

  Future<void> _reconcile(AppDatabase db, Backend backend, int local, int stamp) async {
    try {
      final remote = await backend.readPreferences();
      final remoteStamp = (remote?['goal_updated_ms'] as num?)?.toInt() ?? 0;
      if (remoteStamp > stamp) {
        final value = (remote?['goal_year_m'] as num?)?.toInt() ?? 0;
        await db.writeMeta(_key, '$value');
        await db.writeMeta(_stampKey, '$remoteStamp');
        if (ref.mounted) state = AsyncData(value > 0 ? value : null);
      } else if (stamp > remoteStamp) {
        await backend.writePreferences({...?remote, 'goal_year_m': local, 'goal_updated_ms': stamp});
      }
    } catch (_) {
      // Hors ligne ou serveur indisponible : l'objectif de l'appareil reste, nouvel essai plus tard.
    }
  }

  Future<void> set(int? meters) async {
    final value = meters != null && meters > 0 ? meters : 0;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final db = ref.read(databaseProvider);
    await db.writeMeta(_key, '$value');
    await db.writeMeta(_stampKey, '$stamp');
    state = AsyncData(value > 0 ? value : null);
    try {
      final backend = ref.read(backendProvider);
      final remote = await backend.readPreferences();
      await backend.writePreferences({...?remote, 'goal_year_m': value, 'goal_updated_ms': stamp});
    } catch (_) {
      // Envoyé à la prochaine ouverture de l'app.
    }
  }
}

final yearGoalProvider = AsyncNotifierProvider<YearGoalController, int?>(YearGoalController.new);

/// Dernière année dont l'annonce « ton bilan est prêt » a été fermée (0 : aucune).
class RecapDismissedController extends AsyncNotifier<int> {
  static const _key = 'recap.dismissed_year';

  @override
  Future<int> build() async => int.tryParse(await ref.watch(databaseProvider).readMeta(_key) ?? '') ?? 0;

  Future<void> dismiss(int year) async {
    await ref.read(databaseProvider).writeMeta(_key, '$year');
    state = AsyncData(year);
  }
}

final recapDismissedProvider = AsyncNotifierProvider<RecapDismissedController, int>(RecapDismissedController.new);

/// Nombre de courses dont le résultat reste à saisir (pour un rappel).
final awaitingResultCountProvider = Provider<int>((ref) {
  final today = _today(ref);
  return (ref.watch(coursesProvider).value ?? const [])
      .where((c) => c.statusOn(today) == CourseStatus.awaitingResult)
      .length;
});
