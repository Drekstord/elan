import 'course.dart';

/// Totaux sportifs. Seules les courses terminées comptent.
class CourseStats {
  final int count;

  /// Kilomètres courus (course à pied seulement pour une épreuve enchaînée).
  final int distanceM;

  /// Distance parcourue toutes disciplines confondues (bilans, engagement solidaire).
  final int totalDistanceM;

  /// Durée cumulée des courses chronométrées.
  final int durationS;
  final int elevationGainM;

  /// Distance des seules courses chronométrées, pour une allure moyenne juste.
  final int timedDistanceM;

  /// Durée des courses à pied chronométrées (base de l'allure moyenne).
  final int pacedDurationS;

  const CourseStats({
    required this.count,
    required this.distanceM,
    required this.totalDistanceM,
    required this.durationS,
    required this.elevationGainM,
    required this.timedDistanceM,
    required this.pacedDurationS,
  });

  static const empty = CourseStats(
    count: 0,
    distanceM: 0,
    totalDistanceM: 0,
    durationS: 0,
    elevationGainM: 0,
    timedDistanceM: 0,
    pacedDurationS: 0,
  );

  factory CourseStats.of(Iterable<Course> courses) {
    var count = 0, distance = 0, totalDistance = 0, duration = 0, elevation = 0, timedDistance = 0, pacedDuration = 0;
    for (final c in courses.where((c) => c.isCompleted)) {
      count++;
      distance += c.runDistanceM;
      totalDistance += c.distanceM;
      elevation += c.elevationGainM ?? 0;
      if (c.hasTime) {
        duration += c.durationS;
        // Une épreuve enchaînée n'a pas d'allure de course à pied : hors de la moyenne.
        if (!c.isMultisport) {
          timedDistance += c.distanceM;
          pacedDuration += c.durationS;
        }
      }
    }
    return CourseStats(
      count: count,
      distanceM: distance,
      totalDistanceM: totalDistance,
      durationS: duration,
      elevationGainM: elevation,
      timedDistanceM: timedDistance,
      pacedDurationS: pacedDuration,
    );
  }

  /// Allure moyenne pondérée par la distance, en secondes par km.
  double? get averagePaceSecondsPerKm => timedDistanceM > 0 ? pacedDurationS / (timedDistanceM / 1000) : null;
}

/// Avancement de l'objectif annuel de kilomètres courus.
class GoalProgress {
  final int goalM;
  final int doneM;

  /// Distance qu'il faudrait avoir courue aujourd'hui pour finir l'année pile sur l'objectif.
  final int expectedM;

  const GoalProgress({required this.goalM, required this.doneM, required this.expectedM});

  bool get reached => doneM >= goalM;

  /// Part accomplie, entre 0 et 1.
  double get ratio => goalM <= 0 ? 0 : (doneM / goalM).clamp(0.0, 1.0);

  /// Avance (positive) ou retard (négatif) sur le rythme de l'année.
  int get aheadM => doneM - expectedM;
}

/// Kilomètres courus cette année face à l'objectif, et où l'on devrait en être au jour [today].
GoalProgress goalProgress(Iterable<Course> courses, DateTime today, int goalM) {
  final start = DateTime.utc(today.year);
  final days = DateTime.utc(today.year + 1).difference(start).inDays;
  final elapsed = today.difference(start).inDays + 1;
  return GoalProgress(
    goalM: goalM,
    doneM: CourseStats.of(courses.where((c) => !c.isDeleted && c.raceDate.year == today.year)).distanceM,
    expectedM: (goalM * elapsed / days).round(),
  );
}

/// Cumul d'une discipline sur les épreuves enchaînées terminées.
typedef SportTotal = ({int distanceM, int durationS});

/// Distance et temps de chaque discipline, sur les épreuves enchaînées terminées.
/// Une discipline absente de toutes les épreuves n'apparaît pas.
Map<Sport, SportTotal> sportTotals(Iterable<Course> courses) {
  final totals = <Sport, SportTotal>{};
  for (final c in courses.where((c) => c.isCompleted)) {
    final m = c.multisport;
    if (m == null) continue;
    for (final leg in m.legs) {
      final t = totals[leg.sport] ?? (distanceM: 0, durationS: 0);
      totals[leg.sport] = (distanceM: t.distanceM + leg.distanceM, durationS: t.durationS + leg.durationS);
    }
  }
  return totals;
}

/// Épreuves enchaînées terminées dont [sport] est chronométré, dans l'ordre chronologique.
List<Course> splitRaces(Iterable<Course> courses, Sport sport) =>
    courses.where((c) => c.isCompleted && (c.multisport?.split(sport)?.hasTime ?? false)).toList()
      ..sort((a, b) => a.raceDate.compareTo(b.raceDate));

/// Un point de série temporelle (mois ou année) et les courses terminées qui le composent.
class PeriodTotal {
  /// Premier jour de la période (UTC).
  final DateTime start;
  final List<Course> courses;

  const PeriodTotal(this.start, [this.courses = const []]);

  int get count => courses.length;
  int get distanceM => courses.fold(0, (sum, c) => sum + c.runDistanceM);
  int get donationCents => courses.fold(0, (sum, c) => sum + c.donationCents);
  CourseStats get stats => CourseStats.of(courses);
}

enum Period { month, year }

DateTime _startOf(DateTime d, Period period) =>
    period == Period.month ? DateTime.utc(d.year, d.month) : DateTime.utc(d.year);

DateTime _next(DateTime d, Period period) =>
    period == Period.month ? DateTime.utc(d.year, d.month + 1) : DateTime.utc(d.year + 1);

Map<DateTime, List<Course>> _buckets(Iterable<Course> courses, Period period) {
  final buckets = <DateTime, List<Course>>{};
  for (final c in courses.where((c) => c.isCompleted)) {
    (buckets[_startOf(c.raceDate, period)] ??= []).add(c);
  }
  return buckets;
}

/// Totaux par mois ou par année, de la première à la dernière course,
/// périodes vides incluses (pour des graphiques continus).
List<PeriodTotal> totalsByPeriod(Iterable<Course> courses, Period period) {
  final buckets = _buckets(courses, period);
  if (buckets.isEmpty) return const [];
  final keys = buckets.keys.toList()..sort();
  return [for (var d = keys.first; !d.isAfter(keys.last); d = _next(d, period)) PeriodTotal(d, buckets[d] ?? const [])];
}

/// [count] mois consécutifs à partir de [firstMonth], mois vides inclus.
List<PeriodTotal> monthlyTotals(Iterable<Course> courses, DateTime firstMonth, int count) {
  final buckets = _buckets(courses, Period.month);
  return [
    for (var i = 0; i < count; i++)
      PeriodTotal(
        DateTime.utc(firstMonth.year, firstMonth.month + i),
        buckets[DateTime.utc(firstMonth.year, firstMonth.month + i)] ?? const [],
      ),
  ];
}

/// Courses terminées dont la date est dans [from, to[.
List<Course> completedBetween(Iterable<Course> courses, DateTime from, DateTime to) =>
    courses.where((c) => c.isCompleted && !c.raceDate.isBefore(from) && c.raceDate.isBefore(to)).toList();

/// Distance cumulée au fil d'une année : un point par course terminée,
/// (jour de l'année, mètres cumulés), précédé de (0, 0).
List<(int day, int meters)> cumulativeDistance(Iterable<Course> courses, int year) {
  final ofYear = courses.where((c) => c.isCompleted && c.raceDate.year == year).toList()
    ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
  var total = 0;
  return [
    (0, 0),
    for (final c in ofYear) (c.raceDate.difference(DateTime.utc(year)).inDays + 1, total += c.runDistanceM),
  ];
}

/// Allure des courses officielles terminées et chronométrées, dans l'ordre chronologique.
List<Course> pacedRaces(Iterable<Course> courses) =>
    courses.where((c) => c.isCompleted && c.type == CourseType.officialRace && c.hasTime).toList()
      ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
