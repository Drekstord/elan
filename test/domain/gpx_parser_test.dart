import 'package:app_course/features/courses/data/gpx_parser.dart';
import 'package:flutter_test/flutter_test.dart';

String gpx(String segments, {String name = 'Sortie Forêt'}) =>
    '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Garmin Connect">
  <metadata><time>2026-10-07T07:59:00Z</time></metadata>
  <trk><name>$name</name>$segments</trk>
</gpx>''';

String pt(double lat, double lon, double ele, String time) =>
    '<trkpt lat="$lat" lon="$lon"><ele>$ele</ele><time>$time</time></trkpt>';

void main() {
  test('distance, durée, dénivelé et nom', () {
    final summary = GpxParser.parse(
      gpx(
        '<trkseg>'
        '${pt(48.8566, 2.3522, 35, '2026-10-07T08:00:00Z')}'
        '${pt(48.8600, 2.3550, 45, '2026-10-07T08:02:30Z')}'
        '${pt(48.8650, 2.3600, 60, '2026-10-07T08:06:00Z')}'
        '</trkseg>',
      ),
    );
    expect(summary.name, 'Sortie Forêt');
    expect(summary.pointCount, 3);
    expect(summary.distanceM, inInclusiveRange(1050, 1150));
    expect(summary.durationS, 360);
    expect(summary.elevationGainM, 25);
    expect(summary.startTime, DateTime.utc(2026, 10, 7, 8));
  });

  test('le bruit d\'altitude sous 3 m n\'ajoute pas de dénivelé', () {
    final points = [
      for (var i = 0; i < 20; i++)
        pt(48.85 + i * 0.0001, 2.35, i.isEven ? 100 : 101.5, '2026-10-07T08:${i.toString().padLeft(2, '0')}:00Z'),
    ];
    final summary = GpxParser.parse(gpx('<trkseg>${points.join()}</trkseg>'));
    expect(summary.elevationGainM, 0);
  });

  test('l\'écart entre deux segments (pause) n\'est pas compté', () {
    final oneSegment = GpxParser.parse(
      gpx(
        '<trkseg>'
        '${pt(48.85, 2.35, 0, '2026-10-07T08:00:00Z')}${pt(48.86, 2.35, 0, '2026-10-07T08:05:00Z')}'
        '</trkseg>',
      ),
    );
    final twoSegments = GpxParser.parse(
      gpx(
        '<trkseg>'
        '${pt(48.85, 2.35, 0, '2026-10-07T08:00:00Z')}${pt(48.86, 2.35, 0, '2026-10-07T08:05:00Z')}'
        '</trkseg><trkseg>'
        '${pt(48.95, 2.35, 0, '2026-10-07T09:00:00Z')}${pt(48.96, 2.35, 0, '2026-10-07T09:05:00Z')}'
        '</trkseg>',
      ),
    );
    expect(twoSegments.distanceM, closeTo(oneSegment.distanceM * 2, 2));
  });

  test('fichiers invalides', () {
    expect(() => GpxParser.parse('pas du xml'), throwsA(isA<GpxFormatException>()));
    expect(() => GpxParser.parse(gpx('<trkseg></trkseg>')), throwsA(isA<GpxFormatException>()));
  });
}
