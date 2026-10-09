import '../../courses/domain/course.dart';
import '../../courses/domain/course_stats.dart';
import '../../impact/domain/impact_summary.dart';

/// Raccourcis de période proposés à l'écran.
enum ReportPreset { schoolYear, calendarYear, last12Months, custom }

/// Bornes (incluses) d'un raccourci, par rapport à [today].
(DateTime, DateTime) presetRange(ReportPreset preset, DateTime today, {(DateTime, DateTime)? custom}) =>
    switch (preset) {
      // Année scolaire : du 1er septembre au 31 août.
      ReportPreset.schoolYear => () {
        final start = today.month >= 9 ? today.year : today.year - 1;
        return (calendarDate(start, 9, 1), calendarDate(start + 1, 8, 31));
      }(),
      ReportPreset.calendarYear => (calendarDate(today.year, 1, 1), calendarDate(today.year, 12, 31)),
      ReportPreset.last12Months => (calendarDate(today.year - 1, today.month, today.day + 1), today),
      ReportPreset.custom => custom ?? (calendarDate(today.year, 1, 1), today),
    };

/// Bilan d'une période : courses terminées entre [from] et [to] (bornes incluses).
class EngagementReport {
  final DateTime from;
  final DateTime to;
  final bool charityOnly;

  /// Courses retenues, de la plus ancienne à la plus récente.
  final List<Course> courses;

  EngagementReport._(this.from, this.to, this.charityOnly, this.courses);

  factory EngagementReport.of(
    Iterable<Course> all, {
    required DateTime from,
    required DateTime to,
    bool charityOnly = false,
  }) {
    final list =
        all
            .where(
              (c) =>
                  c.isCompleted &&
                  !c.raceDate.isBefore(from) &&
                  !c.raceDate.isAfter(to) &&
                  (!charityOnly || c.isCharity),
            )
            .toList()
          ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
    return EngagementReport._(from, to, charityOnly, list);
  }

  bool get isEmpty => courses.isEmpty;

  late final CourseStats stats = CourseStats.of(courses);

  /// Bilan solidaire de la période (les courses non solidaires n'y comptent pas).
  late final ImpactSummary impact = ImpactSummary.of(courses);
}
