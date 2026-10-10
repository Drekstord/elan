import 'dart:convert';
import 'dart:typed_data';

import '../domain/course.dart';

/// Fichier d'agenda (.ics, format iCalendar) : une course par événement, sur la journée entière.
/// Tous les agendas le lisent (Google, Proton, Outlook, Apple…). Réimporter le même fichier met
/// les événements à jour au lieu de les dupliquer, grâce à leur identifiant.
Uint8List coursesToIcs(
  Iterable<Course> courses, {
  required DateTime now,
  required String Function(Course) description,
}) {
  String day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  String two(int v) => v.toString().padLeft(2, '0');
  final utc = now.toUtc();
  final stamp = '${day(utc)}T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';

  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//ELAN//Courses//FR',
    'CALSCALE:GREGORIAN',
    for (final c in courses) ...[
      'BEGIN:VEVENT',
      'UID:${c.id}@elan',
      'DTSTAMP:$stamp',
      'DTSTART;VALUE=DATE:${day(c.raceDate)}',
      // La fin d'un événement d'une journée est le lendemain (exclu).
      'DTEND;VALUE=DATE:${day(c.raceDate.add(const Duration(days: 1)))}',
      'SUMMARY:${_escape(c.title)}',
      if (description(c).isNotEmpty) 'DESCRIPTION:${_escape(description(c))}',
      'TRANSP:TRANSPARENT',
      'END:VEVENT',
    ],
    'END:VCALENDAR',
  ];
  return Uint8List.fromList(utf8.encode('${lines.map(_fold).join('\r\n')}\r\n'));
}

/// Caractères réservés du format : antislash, point-virgule, virgule, saut de ligne.
String _escape(String text) =>
    text.replaceAll('\\', r'\\').replaceAll(';', r'\;').replaceAll(',', r'\,').replaceAll(RegExp(r'\r?\n'), r'\n');

/// Une ligne ne dépasse pas 75 octets : la suite continue à la ligne, précédée d'une espace.
String _fold(String line) {
  final out = StringBuffer();
  var size = 0;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final bytes = utf8.encode(char).length;
    if (size + bytes > 75) {
      out.write('\r\n ');
      size = 1;
    }
    out.write(char);
    size += bytes;
  }
  return out.toString();
}
