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

/// Nombre de courses dont le résultat reste à saisir (pour un rappel).
final awaitingResultCountProvider = Provider<int>((ref) {
  final today = _today(ref);
  return (ref.watch(coursesProvider).value ?? const [])
      .where((c) => c.statusOn(today) == CourseStatus.awaitingResult)
      .length;
});
