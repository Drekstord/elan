import 'dart:convert';

import 'package:app_course/app/labels.dart';
import 'package:app_course/features/courses/data/calendar_export.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/domain/editions.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';

Course race(String id, String title, int year, {int distanceM = 10000, int durationS = 3000, bool planned = false}) =>
    Course(
      id: id,
      title: title,
      raceDate: calendarDate(year, 5, 17),
      distanceM: distanceM,
      durationS: planned ? 0 : durationS,
      isPlanned: planned,
    );

void main() {
  final t = AppLocalizationsFr();

  group('éditions d\'une même course', () {
    test('le nom est comparé sans millésime, numéro d\'édition ni accents', () {
      final key = editionKey('10 km de Valfleuri');
      expect(editionKey('10 km de Valfleuri 2026'), key);
      expect(editionKey('10 KM de Valfleuri (12e édition)'), key);
      expect(editionKey('10 km de Valfleuri, 12ème édition'), key);
      expect(editionKey('10 km de Valfleuri #12'), key);
      expect(editionKey('Semi de Démoville'), editionKey('semi de demoville'));
      expect(editionKey('10 km de Bois-Joli'), isNot(key));
      expect(editionKey('2026'), isEmpty);
    });

    test('éditions précédentes : même nom, distance voisine, déjà courues, plus anciennes', () {
      final current = race('2026', '10 km de Valfleuri 2026', 2026);
      final all = [
        current,
        race('2025', '10 km de Valfleuri 2025', 2025, durationS: 3130),
        race('2024', '10 km de Valfleuri', 2024, distanceM: 10150, durationS: 3200),
        race('2027', '10 km de Valfleuri 2027', 2027),
        race('semi', 'Semi de Valfleuri', 2025, distanceM: 21100),
        race('autre-distance', '10 km de Valfleuri', 2023, distanceM: 5000),
        race('a-venir', '10 km de Valfleuri', 2022, planned: true),
        race('supprimee', '10 km de Valfleuri 2021', 2021).copyWith(deletedAt: DateTime.utc(2026)),
      ];
      expect(previousEditions(current, all).map((c) => c.id), ['2025', '2024']);
      expect(previousEditions(race('seule', 'Trail des Monts Imaginaires', 2026), all), isEmpty);
    });

    test('un triathlon ne se compare qu\'à un triathlon', () {
      Course tri(String id, int year, MultisportKind kind) => Course(
        id: id,
        title: 'Triathlon de Démoville $year',
        raceDate: calendarDate(year, 4, 12),
        type: CourseType.multisport,
        distanceM: 6700,
        durationS: 1680,
        multisport: Multisport(
          kind: kind,
          legs: [for (final sport in kind.sports) Leg(sport: sport, distanceM: 6700 ~/ kind.sports.length)],
        ),
      );
      final current = tri('2026', 2026, MultisportKind.triathlon);
      final all = [
        current,
        tri('2025', 2025, MultisportKind.triathlon),
        tri('duathlon', 2024, MultisportKind.duathlon),
        race('course', 'Triathlon de Démoville 2023', 2023, distanceM: 6700),
      ];
      expect(previousEditions(current, all).map((c) => c.id), ['2025']);
    });
  });

  group('agenda', () {
    final semi = Course(
      id: 'abc-123',
      title: 'Semi de Démoville; édition, spéciale',
      raceDate: calendarDate(2026, 12, 31),
      distanceM: 21100,
      isPlanned: true,
      targetDurationS: 6300,
    );

    test('un événement d\'une journée par course, au format iCalendar', () {
      final ics = utf8.decode(
        coursesToIcs([semi], now: DateTime.utc(2026, 10, 8, 9, 5, 3), description: (c) => calendarDescription(c, t)),
      );
      final lines = ics.split('\r\n');
      expect(lines.first, 'BEGIN:VCALENDAR');
      expect(lines[lines.length - 2], 'END:VCALENDAR');
      expect(ics.endsWith('\r\n'), isTrue);
      expect(lines, contains('UID:abc-123@elan'));
      expect(lines, contains('DTSTAMP:20261008T090503Z'));
      expect(lines, contains('DTSTART;VALUE=DATE:20261231'));
      expect(lines, contains('DTEND;VALUE=DATE:20270101'), reason: 'la fin est le lendemain');
      // Point-virgule et virgule du titre protégés.
      expect(lines, contains(r'SUMMARY:Semi de Démoville\; édition\, spéciale'));
      expect(ics.replaceAll('\r\n ', ''), contains(r'DESCRIPTION:Course officielle · 21\,1 km · Temps visé : 1:45:00'));
    });

    test('lignes longues repliées à 75 octets, sans couper un caractère accentué', () {
      final long = semi.copyWith(title: 'É' * 60);
      final ics = utf8.decode(coursesToIcs([long], now: DateTime.utc(2026), description: (_) => ''));
      for (final line in ics.split('\r\n')) {
        expect(utf8.encode(line).length, lessThanOrEqualTo(75));
      }
      expect(ics.replaceAll('\r\n ', ''), contains('SUMMARY:${'É' * 60}'));
      expect(ics, isNot(contains('DESCRIPTION')));
    });

    test('plusieurs courses : autant d\'événements', () {
      final ics = utf8.decode(
        coursesToIcs([semi, race('b', '10 km', 2027, planned: true)], now: DateTime.utc(2026), description: (_) => ''),
      );
      expect('BEGIN:VEVENT'.allMatches(ics), hasLength(2));
    });
  });
}
