import 'package:app_course/features/courses/data/gpx_batch.dart';
import 'package:app_course/features/courses/data/gpx_parser.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:flutter_test/flutter_test.dart';

GpxSummary track(String? name, DateTime? start, int m, {int time = 3000, int gain = 50}) => GpxSummary(
  name: name,
  startTime: start,
  distanceM: m,
  durationS: time,
  elevationGainM: gain,
  elevationLossM: gain,
  pointCount: 100,
);

void main() {
  test('même course : même jour, distance à 3 % près', () {
    final d = calendarDate(2026, 5, 1);
    expect(sameRace(d, 10000, d, 10250), isTrue);
    expect(sameRace(d, 10000, d, 10400), isFalse);
    expect(sameRace(d, 10000, calendarDate(2026, 5, 2), 10000), isFalse);
  });

  test('une course par trace, doublons (déjà là ou dans le lot) et traces sans date ignorés', () {
    var n = 0;
    final result = coursesFromGpx(
      [
        track('Sortie longue', DateTime(2026, 6, 14, 9), 21300, time: 7200, gain: 0),
        track(null, DateTime(2026, 5, 1, 10), 10020),
        track('Copie', DateTime(2026, 5, 1, 10), 10100), // même trace dans le lot
        track('Déjà là', DateTime(2026, 3, 8, 9), 21150), // déjà dans l'app
        track('Sans heure', null, 5000),
      ],
      [Course(id: 'x', title: 'Semi', raceDate: calendarDate(2026, 3, 8), distanceM: 21097)],
      newId: () => 'id${n++}',
      defaultTitle: (day) => 'Course du ${day.day}/${day.month}',
    );
    expect(result.created.map((c) => c.title), ['Course du 1/5', 'Sortie longue']);
    expect(result.duplicates, 2);
    expect(result.undated, 1);
    final long = result.created.last;
    expect(long.raceDate, calendarDate(2026, 6, 14));
    expect(long.durationS, 7200);
    expect(long.elevationGainM, isNull);
    expect(long.isPlanned, isFalse);
    expect(result.created.first.elevationGainM, 50);
  });
}
