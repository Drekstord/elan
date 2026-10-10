import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class YearGoalController extends AsyncNotifier<int?> {
  static const _key = 'goal.year_m';

  @override
  Future<int?> build() async {
    final value = int.tryParse(await ref.watch(databaseProvider).readMeta(_key) ?? '');
    return value != null && value > 0 ? value : null;
  }

  Future<void> set(int? meters) async {
    final value = meters != null && meters > 0 ? meters : null;
    await ref.read(databaseProvider).writeMeta(_key, '${value ?? 0}');
    state = AsyncData(value);
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
