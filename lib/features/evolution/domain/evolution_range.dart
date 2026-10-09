import '../../courses/domain/course.dart';
import '../../courses/domain/course_stats.dart';

enum RangeKind {
  /// Les 12 derniers mois glissants, mois en cours inclus.
  last12Months,

  /// Une année civile, de janvier à décembre.
  year,

  /// Toutes les années, une barre par année.
  allYears,
}

/// Comparaison avec la période précédente équivalente.
enum CompareKind {
  /// Les 12 mois précédant la plage.
  previous12Months,

  /// L'année précédente entière.
  previousYear,

  /// L'année précédente, du 1er janvier au même jour qu'aujourd'hui (année en cours).
  previousYearToDate,
}

/// Plage de temps affichée par l'écran Évolution.
class EvolutionRange {
  final RangeKind kind;

  /// Année affichée pour [RangeKind.year].
  final int year;

  const EvolutionRange(this.kind, {required this.year});

  /// Bornes [début, fin[ de la plage ; null pour toutes les années.
  (DateTime, DateTime)? window(DateTime today) => switch (kind) {
    RangeKind.last12Months => (DateTime.utc(today.year, today.month - 11), DateTime.utc(today.year, today.month + 1)),
    RangeKind.year => (DateTime.utc(year), DateTime.utc(year + 1)),
    RangeKind.allYears => null,
  };

  /// Période de comparaison, de même durée et arrêtée au même point de l'année.
  (DateTime, DateTime, CompareKind)? previousWindow(DateTime today) => switch (kind) {
    RangeKind.last12Months => (
      DateTime.utc(today.year, today.month - 23),
      DateTime.utc(today.year, today.month - 11),
      CompareKind.previous12Months,
    ),
    RangeKind.year when year == today.year => (
      DateTime.utc(year - 1),
      DateTime.utc(year - 1, today.month, today.day + 1),
      CompareKind.previousYearToDate,
    ),
    RangeKind.year => (DateTime.utc(year - 1), DateTime.utc(year), CompareKind.previousYear),
    RangeKind.allYears => null,
  };

  /// Courses terminées de la plage.
  List<Course> coursesIn(Iterable<Course> courses, DateTime today) {
    final w = window(today);
    return w == null ? courses.where((c) => c.isCompleted).toList() : completedBetween(courses, w.$1, w.$2);
  }

  /// Barres du graphique : 12 mois, ou une par année (jusqu'à l'année en cours).
  List<PeriodTotal> totals(Iterable<Course> courses, DateTime today) {
    final w = window(today);
    if (w != null) return monthlyTotals(courses, w.$1, 12);
    final years = totalsByPeriod(courses, Period.year);
    if (years.isEmpty) return years;
    return [...years, for (var y = years.last.start.year + 1; y <= today.year; y++) PeriodTotal(DateTime.utc(y))];
  }

  /// Années proposées au sélecteur : de la première course à l'année en cours.
  static List<int> availableYears(Iterable<Course> courses, DateTime today) {
    final done = courses.where((c) => c.isCompleted);
    final first = done.isEmpty ? today.year : done.map((c) => c.raceDate.year).reduce((a, b) => a < b ? a : b);
    return [for (var y = first; y <= today.year; y++) y];
  }
}

/// Variation relative en pour cent (null si la base est nulle).
int? percentChange(int current, int previous) => previous == 0 ? null : ((current - previous) * 100 / previous).round();
