import 'dart:math' as math;

import 'package:xml/xml.dart';

/// Résumé d'une trace GPX (Garmin, Strava, Coros, Suunto…).
class GpxSummary {
  final String? name;
  final DateTime? startTime;
  final int distanceM;

  /// Temps écoulé entre le premier et le dernier point horodaté.
  final int durationS;
  final int elevationGainM;
  final int elevationLossM;
  final int pointCount;

  const GpxSummary({
    this.name,
    this.startTime,
    required this.distanceM,
    required this.durationS,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.pointCount,
  });
}

class GpxFormatException implements Exception {
  final String message;
  const GpxFormatException(this.message);

  @override
  String toString() => 'GpxFormatException: $message';
}

class GpxParser {
  /// Variation d'altitude ignorée : le bruit du GPS gonflerait le dénivelé.
  static const double elevationThresholdM = 3;

  static GpxSummary parse(String xml, {String? fallbackName}) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(xml);
    } on XmlException catch (e) {
      throw GpxFormatException('Fichier GPX illisible : ${e.message}');
    }

    // Segments : chaque <trkseg> (ou la route, à défaut) est mesuré séparément,
    // pour ne pas compter le trajet entre deux segments (pause de la montre).
    var segments = doc.findAllElements('trkseg').map((s) => s.findElements('trkpt').toList()).toList();
    if (segments.every((s) => s.isEmpty)) segments = [doc.findAllElements('rtept').toList()];
    final parsed = segments.map((s) => s.map(_point).whereType<_Point>().toList()).where((s) => s.isNotEmpty).toList();
    final all = [for (final s in parsed) ...s];
    if (all.isEmpty) throw const GpxFormatException('Aucun point de trace dans ce fichier.');

    var distance = 0.0;
    for (final seg in parsed) {
      for (var i = 1; i < seg.length; i++) {
        distance += _haversine(seg[i - 1], seg[i]);
      }
    }

    var gain = 0.0, loss = 0.0;
    double? reference;
    for (final p in all) {
      final ele = p.ele;
      if (ele == null) continue;
      if (reference == null) {
        reference = ele;
      } else if ((ele - reference).abs() >= elevationThresholdM) {
        if (ele > reference) {
          gain += ele - reference;
        } else {
          loss += reference - ele;
        }
        reference = ele;
      }
    }

    final times = all.map((p) => p.time).whereType<DateTime>().toList();
    final metaTime = DateTime.tryParse(
      doc.findAllElements('metadata').expand((m) => m.findElements('time')).firstOrNull?.innerText.trim() ?? '',
    );
    final start = times.isNotEmpty ? times.first : metaTime;
    final duration = times.length >= 2 ? times.last.difference(times.first).inSeconds : 0;

    final name = [
      ...doc.findAllElements('trk').expand((t) => t.findElements('name')),
      ...doc.findAllElements('metadata').expand((m) => m.findElements('name')),
    ].map((e) => e.innerText.trim()).where((n) => n.isNotEmpty).firstOrNull;

    return GpxSummary(
      name: name ?? fallbackName,
      startTime: start,
      distanceM: distance.round(),
      durationS: math.max(0, duration),
      elevationGainM: gain.round(),
      elevationLossM: loss.round(),
      pointCount: all.length,
    );
  }

  static _Point? _point(XmlElement e) {
    final lat = double.tryParse(e.getAttribute('lat') ?? '');
    final lon = double.tryParse(e.getAttribute('lon') ?? '');
    if (lat == null || lon == null) return null;
    return _Point(
      lat,
      lon,
      double.tryParse(e.findElements('ele').firstOrNull?.innerText.trim() ?? ''),
      DateTime.tryParse(e.findElements('time').firstOrNull?.innerText.trim() ?? ''),
    );
  }

  static double _haversine(_Point a, _Point b) {
    const earthRadiusM = 6371008.8;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(b.lat - a.lat);
    final dLon = rad(b.lon - a.lon);
    final h =
        math.pow(math.sin(dLat / 2), 2) + math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLon / 2), 2);
    return 2 * earthRadiusM * math.asin(math.sqrt(h));
  }
}

class _Point {
  final double lat;
  final double lon;
  final double? ele;
  final DateTime? time;
  const _Point(this.lat, this.lon, this.ele, this.time);
}
