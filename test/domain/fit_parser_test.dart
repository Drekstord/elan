import 'dart:typed_data';

import 'package:app_course/features/courses/data/fit_parser.dart';
import 'package:app_course/features/courses/domain/multisport.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fabrique un fichier FIT minimal, octet par octet, d'après la spécification du format.
/// Ce n'est pas un fichier sorti d'une montre : il vérifie que la lecture suit la spécification.
class FitBuilder {
  final _body = BytesBuilder();
  final bool bigEndian;

  FitBuilder({this.bigEndian = false});

  Endian get _endian => bigEndian ? Endian.big : Endian.little;

  List<int> _u16(int v) => (ByteData(2)..setUint16(0, v, _endian)).buffer.asUint8List();
  List<int> _u32(int v) => (ByteData(4)..setUint32(0, v, _endian)).buffer.asUint8List();

  /// Définition du message « session » : début, sport, temps écoulé, temps actif, distance, D+.
  void defineSession({int local = 0, int developerBytes = 0}) {
    _body.add([developerBytes > 0 ? 0x60 | local : 0x40 | local, 0, bigEndian ? 1 : 0, ..._u16(18), 6]);
    _body.add([2, 4, 0x86, 5, 1, 0x00, 7, 4, 0x86, 8, 4, 0x86, 9, 4, 0x86, 22, 2, 0x84]);
    if (developerBytes > 0) _body.add([1, 0, developerBytes, 0]);
  }

  /// [sport] : 1 course à pied, 2 vélo, 3 transition, 5 natation.
  void session({
    int local = 0,
    required int sport,
    required int start,
    required int seconds,
    int meters = 0,
    int? ascent,
    int developerBytes = 0,
    bool compressedHeader = false,
  }) {
    _body.add([compressedHeader ? 0x80 | (local << 5) | 3 : local]);
    _body.add([
      ..._u32(start),
      sport,
      ..._u32(seconds * 1000),
      ..._u32(seconds * 1000 - 5000 < 0 ? 0 : seconds * 1000 - 5000),
      ..._u32(meters * 100),
      ..._u16(ascent ?? 0xFFFF),
      ...List.filled(developerBytes, 7),
    ]);
  }

  /// Un autre message (ici « file_id »), que la lecture doit sauter sans se perdre.
  void other({int local = 1}) {
    _body.add([0x40 | local, 0, bigEndian ? 1 : 0, ..._u16(0), 2, 0, 1, 0x00, 1, 2, 0x84]);
    _body.add([local, 4, ..._u16(1)]);
  }

  Uint8List build() {
    final body = _body.toBytes();
    final header = ByteData(14)
      ..setUint8(0, 14)
      ..setUint8(1, 0x20)
      ..setUint16(2, 2100, Endian.little)
      ..setUint32(4, body.length, Endian.little);
    final bytes = BytesBuilder()
      ..add(header.buffer.asUint8List(0, 8))
      ..add('.FIT'.codeUnits)
      ..add([0, 0])
      ..add(body)
      ..add([0, 0]);
    return bytes.toBytes();
  }
}

/// 14 juin 2026 à 8 h UTC, en secondes depuis l'origine des dates FIT (31 décembre 1989).
const _start = 1150358400;

void main() {
  test('la date de référence des tests est bien le 14 juin 2026', () {
    expect(DateTime.fromMillisecondsSinceEpoch((_start + 631065600) * 1000, isUtc: true), DateTime.utc(2026, 6, 14, 8));
  });

  test('triathlon : trois disciplines, deux transitions, format reconnu', () {
    final fit = FitBuilder()
      ..other()
      ..defineSession()
      ..session(sport: 5, start: _start, seconds: 912, meters: 742)
      ..session(sport: 3, start: _start + 912, seconds: 118)
      ..session(sport: 2, start: _start + 1030, seconds: 2405, meters: 19850, ascent: 140)
      ..session(sport: 3, start: _start + 3435, seconds: 87)
      ..session(sport: 1, start: _start + 3522, seconds: 1493, meters: 5020, ascent: 25);
    final summary = FitParser.parse(fit.build());

    expect(summary.sessions, hasLength(5));
    expect(summary.startTime, DateTime.utc(2026, 6, 14, 8));
    expect(summary.durationS, 912 + 118 + 2405 + 87 + 1493);
    expect(summary.elevationGainM, 165);

    final m = summary.multisport!;
    expect(m.kind, MultisportKind.triathlon);
    expect(m.format, 'S', reason: '742 m, 19,85 km et 5,02 km : un format S');
    expect(m.legs.map((l) => l.sport), [Sport.swim, Sport.bike, Sport.run]);
    expect(m.legs.map((l) => l.distanceM), [742, 19850, 5020]);
    expect(m.legs.map((l) => l.durationS), [912, 2405, 1493]);
    expect(m.transitionsS, [118, 87]);
    expect(m.splitsTotalS, summary.durationS);
  });

  test('séances dans le désordre : remises dans l\'ordre chronologique', () {
    final fit = FitBuilder()
      ..defineSession()
      ..session(sport: 1, start: _start + 2000, seconds: 600, meters: 2500)
      ..session(sport: 5, start: _start, seconds: 700, meters: 500);
    final m = FitParser.parse(fit.build()).multisport!;
    expect(m.kind, MultisportKind.aquathlon);
    expect(m.format, 'XS');
    expect(m.transitionsS, [0], reason: 'aucune transition enregistrée');
  });

  test('duathlon sans transition enregistrée, distances hors format', () {
    final fit = FitBuilder()
      ..defineSession()
      ..session(sport: 1, start: _start, seconds: 1400, meters: 4000)
      ..session(sport: 2, start: _start + 1400, seconds: 2880, meters: 30000)
      ..session(sport: 1, start: _start + 4280, seconds: 775, meters: 2500);
    final m = FitParser.parse(fit.build()).multisport!;
    expect(m.kind, MultisportKind.duathlon);
    expect(m.format, isNull);
    expect(m.transitionsS, [0, 0]);
  });

  test('activité simple : une seule séance, pas d\'épreuve enchaînée', () {
    final fit = FitBuilder()
      ..defineSession()
      ..session(sport: 1, start: _start, seconds: 2900, meters: 10020, ascent: 60);
    final summary = FitParser.parse(fit.build());
    expect(summary.multisport, isNull);
    expect(summary.legs.single.distanceM, 10020);
    expect(summary.legs.single.durationS, 2900);
  });

  test('enchaînement inconnu (vélo puis natation) : pas d\'épreuve reconnue', () {
    final fit = FitBuilder()
      ..defineSession()
      ..session(sport: 2, start: _start, seconds: 2400, meters: 20000)
      ..session(sport: 5, start: _start + 2400, seconds: 900, meters: 750);
    expect(FitParser.parse(fit.build()).multisport, isNull);
  });

  test('variantes du format : gros-boutiste, champs développeur, en-tête compressé', () {
    final big = FitBuilder(bigEndian: true)
      ..defineSession()
      ..session(sport: 5, start: _start, seconds: 420, meters: 200)
      ..session(sport: 1, start: _start + 420, seconds: 480, meters: 1500);
    expect(FitParser.parse(big.build()).legs.map((l) => l.distanceM), [200, 1500]);

    final dev = FitBuilder()
      ..defineSession(developerBytes: 3)
      ..session(sport: 5, start: _start, seconds: 420, meters: 200, developerBytes: 3)
      ..session(sport: 1, start: _start + 420, seconds: 480, meters: 1500, developerBytes: 3);
    expect(FitParser.parse(dev.build()).legs.map((l) => l.durationS), [420, 480]);

    final compressed = FitBuilder()
      ..defineSession(local: 2)
      ..session(local: 2, sport: 1, start: _start, seconds: 600, meters: 2000, compressedHeader: true);
    expect(FitParser.parse(compressed.build()).legs.single.distanceM, 2000);
  });

  test('fichier illisible : erreur claire, jamais de plantage', () {
    expect(
      () => FitParser.parse(Uint8List.fromList('pas un fichier fit'.codeUnits)),
      throwsA(isA<FitFormatException>()),
    );
    expect(() => FitParser.parse(Uint8List(0)), throwsA(isA<FitFormatException>()));

    final empty = FitBuilder()..other();
    expect(() => FitParser.parse(empty.build()), throwsA(isA<FitFormatException>()));

    final full =
        (FitBuilder()
              ..defineSession()
              ..session(sport: 1, start: _start, seconds: 600, meters: 2000))
            .build();
    // Coupé au milieu du message, avec une taille annoncée plus grande que le fichier.
    final truncated = Uint8List.fromList(full.sublist(0, full.length - 12));
    expect(() => FitParser.parse(truncated), throwsA(isA<FitFormatException>()));
  });
}
