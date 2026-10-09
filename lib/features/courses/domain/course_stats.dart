import 'course.dart';

/// Totaux sportifs. Seules les courses terminées comptent.
class CourseStats {
  final int count;
  final int distanceM;

  /// Durée cumulée des courses chronométrées.
  final int durationS;
  final int elevationGainM;

  /// Distance des seules courses chronométrées, pour une allure moyenne juste.
  final int timedDistanceM;

  const CourseStats({
    required this.count,
    required this.distanceM,
    required this.durationS,
    required this.elevationGainM,
    required this.timedDistanceM,
  });

  static const empty = CourseStats(count: 0, distanceM: 0, durationS: 0, elevationGainM: 0, timedDistanceM: 0);

  factory CourseStats.of(Iterable<Course> courses) {
    var count = 0, distance = 0, duration = 0, elevation = 0, timedDistance = 0;
    for (final c in courses.where((c) => c.isCompleted)) {
      count++;
      distance += c.distanceM;
      elevation += c.elevationGainM ?? 0;
      if (c.hasTime) {
        duration += c.durationS;
        timedDistance += c.distanceM;
      }
    }
    return CourseStats(
      count: count,
      distanceM: distance,
      durationS: duration,
      elevationGainM: elevation,
      timedDistanceM: timedDistance,
    );
  }

  /// Allure moyenne pondérée par la distance, en secondes par km.
  double? get averagePaceSecondsPerKm => timedDistanceM > 0 ? durationS / (timedDistanceM / 1000) : null;
}

/// Un point de série temporelle (mois ou année) et les courses terminées qui le composent.
class PeriodTotal {
  /// Premier jour de la période (UTC).
  final DateTime start;
  final List<Course> courses;

  const PeriodTotal(this.start, [this.courses = const []]);

  int get count => courses.length;
  int get distanceM => courses.fold(0, (sum, c) => sum + c.distanceM);
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
  return [(0, 0), for (final c in ofYear) (c.raceDate.difference(DateTime.utc(year)).inDays + 1, total += c.distanceM)];
}

/// Allure des courses officielles terminées et chronométrées, dans l'ordre chronologique.
List<Course> pacedRaces(Iterable<Course> courses) =>
    courses.where((c) => c.isCompleted && c.type == CourseType.officialRace && c.hasTime).toList()
      ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
