import '../../courses/domain/course.dart';
import '../../courses/domain/course_stats.dart';
import '../../records/domain/personal_records.dart';

/// Bilan d'une année, pour la carte à partager : ce qui a été couru, et ce que ça a permis.
class YearRecap {
  final int year;
  final CourseStats stats;

  /// Records personnels de tous les temps détenus par une course de cette année.
  final int records;

  /// Course à pied la plus longue de l'année (hors défis virtuels et épreuves enchaînées).
  final Course? longest;

  /// Triathlons, duathlons et aquathlons terminés.
  final int multisportCount;
  final int donationCents;

  /// Associations différentes soutenues dans l'année.
  final int associations;

  const YearRecap({
    required this.year,
    required this.stats,
    required this.records,
    required this.longest,
    required this.multisportCount,
    required this.donationCents,
    required this.associations,
  });

  bool get isEmpty => stats.count == 0;

  factory YearRecap.of(Iterable<Course> courses, int year) {
    final live = courses.where((c) => !c.isDeleted).toList();
    final ofYear = live.where((c) => c.isCompleted && c.raceDate.year == year).toList();
    final allTime = PersonalRecords.compute(live);
    final races = ofYear.where((c) => c.type == CourseType.officialRace && c.distanceM > 0).toList()
      ..sort((a, b) => b.distanceM.compareTo(a.distanceM));
    final charity = ofYear.where((c) => c.isCharity);
    return YearRecap(
      year: year,
      stats: CourseStats.of(ofYear),
      records: ofYear.fold(0, (sum, c) => sum + allTime.heldBy(c).length),
      longest: races.firstOrNull,
      multisportCount: ofYear.where((c) => c.isMultisport).length,
      donationCents: charity.fold(0, (sum, c) => sum + c.donationCents),
      associations: {
        for (final c in charity)
          if (c.associationName != null) c.associationName!.trim().toLowerCase(),
      }.length,
    );
  }

  /// Années ayant au moins une course terminée, de la plus récente à la plus ancienne.
  static List<int> years(Iterable<Course> courses) => {
    for (final c in courses)
      if (c.isCompleted && !c.isDeleted) c.raceDate.year,
  }.toList()..sort((a, b) => b.compareTo(a));

  /// Année dont le bilan est mis en avant à la date [today] : l'année en cours en décembre,
  /// l'année écoulée en janvier, aucune le reste du temps.
  static int? featuredYear(DateTime today) => switch (today.month) {
    12 => today.year,
    1 => today.year - 1,
    _ => null,
  };
}
