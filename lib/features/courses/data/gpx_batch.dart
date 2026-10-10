import '../domain/course.dart';
import 'gpx_parser.dart';

/// Import de plusieurs traces GPX d'un coup (export Garmin, Strava…) : une course par trace.
class GpxBatchResult {
  /// Courses à enregistrer.
  final List<Course> created;

  /// Traces déjà présentes (même jour, même distance à 3 % près), ignorées.
  final int duplicates;

  /// Traces sans date (aucun point horodaté) : impossible de les placer, ignorées.
  final int undated;

  const GpxBatchResult({required this.created, required this.duplicates, required this.undated});
}

/// Même course : même jour et distances proches (le GPS varie d'un appareil à l'autre).
bool sameRace(DateTime dayA, int metersA, DateTime dayB, int metersB) {
  if (dayA != dayB) return false;
  final longest = metersA > metersB ? metersA : metersB;
  return (metersA - metersB).abs() <= longest * 0.03;
}

/// Courses créées à partir de [tracks], sans doublon avec [existing] ni entre elles.
/// [newId] fournit l'identifiant de chaque nouvelle course.
GpxBatchResult coursesFromGpx(
  List<GpxSummary> tracks,
  Iterable<Course> existing, {
  required String Function() newId,
  required String Function(DateTime day) defaultTitle,
}) {
  final known = [for (final c in existing.where((c) => !c.isDeleted)) (c.raceDate, c.distanceM)];
  final created = <Course>[];
  var duplicates = 0;
  var undated = 0;
  for (final track in tracks) {
    final start = track.startTime?.toLocal();
    if (start == null) {
      undated++;
      continue;
    }
    final day = calendarDate(start.year, start.month, start.day);
    if (known.any((k) => sameRace(k.$1, k.$2, day, track.distanceM))) {
      duplicates++;
      continue;
    }
    known.add((day, track.distanceM));
    final name = track.name?.trim();
    created.add(
      Course(
        id: newId(),
        title: name == null || name.isEmpty ? defaultTitle(day) : name,
        raceDate: day,
        distanceM: track.distanceM,
        durationS: track.durationS,
        elevationGainM: track.elevationGainM > 0 ? track.elevationGainM : null,
      ),
    );
  }
  created.sort((a, b) => a.raceDate.compareTo(b.raceDate));
  return GpxBatchResult(created: created, duplicates: duplicates, undated: undated);
}
