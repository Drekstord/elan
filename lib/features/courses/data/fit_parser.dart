import 'dart:typed_data';

import '../domain/multisport.dart';

/// Une séance d'un fichier FIT : une activité simple en contient une ; un triathlon enregistré
/// en mode multisport en contient une par discipline et une par transition.
class FitSession {
  /// Discipline, ou null pour une transition.
  final Sport? sport;
  final bool isTransition;
  final DateTime? startTime;
  final int distanceM;

  /// Temps écoulé (pauses comprises), comme un chrono officiel.
  final int durationS;
  final int elevationGainM;

  const FitSession({
    required this.sport,
    required this.isTransition,
    required this.startTime,
    required this.distanceM,
    required this.durationS,
    required this.elevationGainM,
  });
}

/// Résumé d'un fichier FIT de montre (Garmin, Coros, Suunto, Wahoo…).
class FitSummary {
  /// Disciplines et transitions, dans l'ordre chronologique.
  final List<FitSession> sessions;

  const FitSummary(this.sessions);

  DateTime? get startTime => sessions.firstOrNull?.startTime;
  int get durationS => sessions.fold(0, (sum, s) => sum + s.durationS);
  int get elevationGainM => sessions.fold(0, (sum, s) => sum + s.elevationGainM);

  List<FitSession> get legs => sessions.where((s) => s.sport != null).toList();

  /// Épreuve enchaînée reconnue, avec ses temps et ses transitions ; null pour une activité
  /// simple ou un enchaînement que l'app ne connaît pas.
  Multisport? get multisport {
    final sports = [for (final s in legs) s.sport!];
    final kind = MultisportKind.values.where((k) => _same(k.sports, sports)).firstOrNull;
    if (kind == null) return null;

    // Temps passé en transition entre deux disciplines consécutives.
    final transitions = <int>[];
    var gap = 0;
    var seenLeg = false;
    for (final s in sessions) {
      if (s.isTransition) {
        if (seenLeg) gap += s.durationS;
      } else if (s.sport != null) {
        if (seenLeg) transitions.add(gap);
        gap = 0;
        seenLeg = true;
      }
    }

    final distances = [for (final s in legs) s.distanceM];
    return Multisport(
      kind: kind,
      format: _formatOf(kind, distances),
      legs: [for (final s in legs) Leg(sport: s.sport!, distanceM: s.distanceM, durationS: s.durationS)],
      transitionsS: transitions,
    );
  }

  /// Format courant dont chaque distance est à moins de 20 % de celle mesurée par la montre.
  static String? _formatOf(MultisportKind kind, List<int> distances) {
    for (final format in MultisportFormat.of(kind)) {
      var close = true;
      for (var i = 0; i < distances.length; i++) {
        final expected = format.distancesM[i];
        if ((distances[i] - expected).abs() > expected * 0.2) close = false;
      }
      if (close) return format.name;
    }
    return null;
  }

  static bool _same(List<Sport> a, List<Sport> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class FitFormatException implements Exception {
  final String message;
  const FitFormatException(this.message);

  @override
  String toString() => 'FitFormatException: $message';
}

class _Field {
  final int number;
  final int size;
  const _Field(this.number, this.size);
}

class _Definition {
  final int globalNumber;
  final bool bigEndian;
  final List<_Field> fields;

  /// Octets des champs « développeur », placés après les champs ordinaires.
  final int developerSize;

  const _Definition(this.globalNumber, this.bigEndian, this.fields, this.developerSize);
}

/// Lecture du format FIT (Flexible and Interoperable Data Transfer), réduite à ce dont l'app
/// a besoin : les messages « session », qui résument chaque discipline.
class FitParser {
  static const int _sessionMessage = 18;

  /// Secondes entre le 1er janvier 1970 et l'origine des dates FIT (31 décembre 1989, UTC).
  static const int _fitEpoch = 631065600;

  static FitSummary parse(Uint8List bytes) {
    if (bytes.length < 14 || String.fromCharCodes(bytes.sublist(8, 12)) != '.FIT') {
      throw const FitFormatException('en-tête FIT absent');
    }
    final data = ByteData.sublistView(bytes);
    final headerSize = bytes[0];
    final dataSize = data.getUint32(4, Endian.little);
    final end = (headerSize + dataSize).clamp(0, bytes.length);

    final definitions = <int, _Definition>{};
    final sessions = <FitSession>[];
    var offset = headerSize;
    try {
      while (offset < end) {
        final header = bytes[offset++];
        final compressed = header & 0x80 != 0;
        if (!compressed && header & 0x40 != 0) {
          // Message de définition : décrit les champs des messages de données qui suivent.
          final bigEndian = bytes[offset + 1] == 1;
          final global = data.getUint16(offset + 2, bigEndian ? Endian.big : Endian.little);
          final count = bytes[offset + 4];
          offset += 5;
          final fields = [for (var i = 0; i < count; i++) _Field(bytes[offset + i * 3], bytes[offset + i * 3 + 1])];
          offset += count * 3;
          var developerSize = 0;
          if (header & 0x20 != 0) {
            final developerCount = bytes[offset++];
            for (var i = 0; i < developerCount; i++) {
              developerSize += bytes[offset + i * 3 + 1];
            }
            offset += developerCount * 3;
          }
          definitions[header & 0x0F] = _Definition(global, bigEndian, fields, developerSize);
          continue;
        }

        final local = compressed ? (header >> 5) & 0x03 : header & 0x0F;
        final definition = definitions[local];
        if (definition == null) throw const FitFormatException('message sans définition');
        if (definition.globalNumber == _sessionMessage) sessions.add(_session(data, offset, definition));
        offset += definition.fields.fold(0, (sum, f) => sum + f.size) + definition.developerSize;
      }
    } on RangeError {
      throw const FitFormatException('fichier tronqué');
    }

    if (sessions.isEmpty) throw const FitFormatException('aucune séance dans le fichier');
    sessions.sort((a, b) => (a.startTime ?? DateTime(0)).compareTo(b.startTime ?? DateTime(0)));
    return FitSummary(sessions);
  }

  static FitSession _session(ByteData data, int offset, _Definition definition) {
    final endian = definition.bigEndian ? Endian.big : Endian.little;
    int? sport, start, elapsed, timer, distance, ascent;
    var at = offset;
    for (final field in definition.fields) {
      // Une valeur « tout à 1 » signifie « non renseigné ».
      int? u32() => field.size == 4 && data.getUint32(at, endian) != 0xFFFFFFFF ? data.getUint32(at, endian) : null;
      int? u16() => field.size == 2 && data.getUint16(at, endian) != 0xFFFF ? data.getUint16(at, endian) : null;
      switch (field.number) {
        case 2:
          start = u32();
        case 5:
          sport = field.size == 1 && data.getUint8(at) != 0xFF ? data.getUint8(at) : null;
        case 7:
          elapsed = u32();
        case 8:
          timer = u32();
        case 9:
          distance = u32();
        case 22:
          ascent = u16();
      }
      at += field.size;
    }
    return FitSession(
      // Numéros de sport du profil FIT : 1 course à pied, 2 vélo, 3 transition, 5 natation.
      sport: switch (sport) {
        1 => Sport.run,
        2 => Sport.bike,
        5 => Sport.swim,
        _ => null,
      },
      isTransition: sport == 3,
      startTime: start == null ? null : DateTime.fromMillisecondsSinceEpoch((start + _fitEpoch) * 1000, isUtc: true),
      // Distances en centimètres, durées en millisecondes.
      distanceM: ((distance ?? 0) / 100).round(),
      durationS: ((elapsed ?? timer ?? 0) / 1000).round(),
      elevationGainM: ascent ?? 0,
    );
  }
}
