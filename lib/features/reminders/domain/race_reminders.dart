import '../../courses/domain/course.dart';

/// Un rappel « saisis ton temps », le soir du jour de la course.
class RaceReminder {
  /// Identifiant de notification (stable pour une même course).
  final int id;
  final String courseId;
  final String courseTitle;

  /// Instant du rappel, en heure locale.
  final DateTime at;

  const RaceReminder({required this.id, required this.courseId, required this.courseTitle, required this.at});
}

/// Nombre maximal de rappels programmés à la fois (les plus proches d'abord).
const kMaxReminders = 50;

/// Rappels à programmer : un par course à venir (résultat non saisi), le jour J à
/// [hour]:[minute] heure locale, s'il n'est pas déjà passé.
List<RaceReminder> raceReminders(
  Iterable<Course> courses, {
  required DateTime now,
  required int hour,
  required int minute,
}) {
  final list = <RaceReminder>[
    for (final c in courses)
      if (c.isPlanned && c.deletedAt == null)
        RaceReminder(
          id: reminderId(c.id),
          courseId: c.id,
          courseTitle: c.title,
          // Date calendaire (minuit UTC) → même jour, heure choisie, fuseau local.
          at: DateTime(c.raceDate.year, c.raceDate.month, c.raceDate.day, hour, minute),
        ),
  ]..removeWhere((r) => !r.at.isAfter(now));
  list.sort((a, b) => a.at.compareTo(b.at));
  return list.take(kMaxReminders).toList();
}

/// Identifiant entier positif dérivé de l'identifiant de course (FNV-1a 31 bits),
/// identique d'un lancement à l'autre.
int reminderId(String courseId) {
  var hash = 0x811c9dc5;
  for (final unit in courseId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
