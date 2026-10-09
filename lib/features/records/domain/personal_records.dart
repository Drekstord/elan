import '../../courses/domain/course.dart';

/// Distances de référence, avec une tolérance : une course officielle mesurée
/// par une montre dépasse souvent légèrement la distance annoncée.
enum StandardDistance {
  fiveK(5000, 4850, 5300),
  tenK(10000, 9700, 10500),
  halfMarathon(21097, 20700, 21700),
  marathon(42195, 41500, 43200);

  final int meters;
  final int minM;
  final int maxM;
  const StandardDistance(this.meters, this.minM, this.maxM);

  static StandardDistance? of(int distanceM) {
    for (final d in values) {
      if (distanceM >= d.minM && distanceM <= d.maxM) return d;
    }
    return null;
  }
}

/// Records personnels, calculés uniquement sur les courses terminées et
/// chronométrées. Les défis virtuels (cumul sur plusieurs semaines) sont exclus.
class PersonalRecords {
  /// Pour chaque distance de référence, les courses du meilleur au moins bon temps.
  final Map<StandardDistance, List<Course>> byDistance;

  /// Plus longues distances, de la plus longue à la plus courte.
  final List<Course> longest;

  /// Plus gros dénivelés positifs, du plus fort au plus faible.
  final List<Course> highestElevation;

  const PersonalRecords({required this.byDistance, required this.longest, required this.highestElevation});

  factory PersonalRecords.compute(Iterable<Course> courses) {
    final eligible = courses.where((c) => c.isCompleted && c.type == CourseType.officialRace).toList();

    final byDistance = <StandardDistance, List<Course>>{};
    for (final c in eligible.where((c) => c.hasTime)) {
      final d = StandardDistance.of(c.distanceM);
      if (d != null) byDistance.putIfAbsent(d, () => []).add(c);
    }
    for (final list in byDistance.values) {
      list.sort(_byTimeThenDate((c) => c.durationS));
    }

    final longest = eligible.where((c) => c.distanceM > 0).toList()..sort(_byTimeThenDate((c) => -c.distanceM));
    final climbing = eligible.where((c) => (c.elevationGainM ?? 0) > 0).toList()
      ..sort(_byTimeThenDate((c) => -(c.elevationGainM ?? 0)));

    return PersonalRecords(byDistance: byDistance, longest: longest, highestElevation: climbing);
  }

  /// Records d'une seule année (meilleurs temps de 2026…).
  factory PersonalRecords.forYear(Iterable<Course> courses, int year) =>
      PersonalRecords.compute(courses.where((c) => c.raceDate.year == year));

  /// Années ayant au moins une course comptée dans les records, de la plus récente à la plus ancienne.
  static List<int> years(Iterable<Course> courses) => {
    for (final c in courses)
      if (c.isCompleted && c.type == CourseType.officialRace && !c.isDeleted) c.raceDate.year,
  }.toList()..sort((a, b) => b.compareTo(a));

  /// En cas d'égalité, la plus ancienne garde le record.
  static int Function(Course, Course) _byTimeThenDate(int Function(Course) key) =>
      (a, b) => key(a) != key(b) ? key(a).compareTo(key(b)) : a.raceDate.compareTo(b.raceDate);

  /// Records détenus par cette course (pour un badge « record »).
  /// Un record n'a de sens qu'à partir de deux courses comparables.
  Set<RecordKind> heldBy(Course course) => {
    for (final MapEntry(:key, :value) in byDistance.entries)
      if (value.length >= 2 && value.first.id == course.id) DistanceRecord(key),
    if (longest.length >= 2 && longest.first.id == course.id) const LongestRecord(),
    if (highestElevation.length >= 2 && highestElevation.first.id == course.id) const ElevationRecord(),
  };
}

sealed class RecordKind {
  const RecordKind();
}

class DistanceRecord extends RecordKind {
  final StandardDistance distance;
  const DistanceRecord(this.distance);

  @override
  bool operator ==(Object other) => other is DistanceRecord && other.distance == distance;

  @override
  int get hashCode => distance.hashCode;
}

class LongestRecord extends RecordKind {
  const LongestRecord();

  @override
  bool operator ==(Object other) => other is LongestRecord;

  @override
  int get hashCode => 1;
}

class ElevationRecord extends RecordKind {
  const ElevationRecord();

  @override
  bool operator ==(Object other) => other is ElevationRecord;

  @override
  int get hashCode => 2;
}
