import 'dart:convert';
import 'dart:io';

import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/settings/backup.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:xml/xml.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));
  final t = AppLocalizationsFr();
  final today = calendarDate(2026, 10, 9);

  final courses = [
    Course(
      id: 'a',
      title: 'Semi; de "Paris"',
      raceDate: calendarDate(2026, 3, 8),
      distanceM: 21097,
      durationS: 6130,
      elevationGainM: 90,
      notes: 'Ligne 1\nLigne 2',
    ),
    Course(
      id: 'b',
      title: 'Course du Cœur',
      raceDate: calendarDate(2026, 9, 20),
      distanceM: 10000,
      durationS: 3150,
      isCharity: true,
      associationName: 'Les Restos du Cœur',
      associationCause: CauseType.precarite,
      sponsorCentsPerKm: 150,
      registrationDonationCents: 1500,
      documents: [CourseDocument(key: 'k', name: 'facture.pdf', sizeBytes: 1, addedAt: DateTime.utc(2026))],
    ),
    Course(id: 'c', title: 'Marathon', raceDate: calendarDate(2027, 4, 11), distanceM: 42195, isPlanned: true),
    Course(id: 'x', title: 'Effacée', raceDate: calendarDate(2026, 1, 1), distanceM: 1, deletedAt: DateTime.utc(2026)),
  ];

  /// Lecteur CSV minimal (guillemets, « ; », retours à la ligne entre guillemets).
  List<List<String>> parse(String csv) {
    final rows = <List<String>>[];
    var row = <String>[], field = StringBuffer(), quoted = false;
    for (var i = 0; i < csv.length; i++) {
      final ch = csv[i];
      if (quoted) {
        if (ch == '"' && i + 1 < csv.length && csv[i + 1] == '"') {
          field.write('"');
          i++;
        } else if (ch == '"') {
          quoted = false;
        } else {
          field.write(ch);
        }
      } else if (ch == '"') {
        quoted = true;
      } else if (ch == ';') {
        row.add('$field');
        field = StringBuffer();
      } else if (ch == '\r') {
        continue;
      } else if (ch == '\n') {
        row.add('$field');
        rows.add(row);
        row = <String>[];
        field = StringBuffer();
      } else {
        field.write(ch);
      }
    }
    return rows;
  }

  test('CSV : BOM, 26 colonnes, toutes les courses non supprimées, format français', () {
    final bytes = backupCsv(courses, t, today: today);
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    final rows = parse(utf8.decode(bytes.skip(3).toList()));
    expect(rows, hasLength(4)); // en-tête + 3 courses
    expect(rows.every((r) => r.length == 26), isTrue);
    expect(rows[0].take(5), ['Date', 'Course', 'Type', 'Statut', 'Distance (km)']);
    // Plus récente d'abord : la course à venir, puis les terminées.
    expect(rows[1][1], 'Marathon');
    expect(rows[1][3], 'À venir');
    final restos = rows[2];
    expect(restos[0], '20/09/2026');
    expect(restos[4], '10');
    expect(restos[11], 'Les Restos du Cœur');
    expect(restos[13], '1,50');
    expect(restos[16], '30,00');
    expect(restos[19], 'facture.pdf');
    final semi = rows[3];
    expect(semi[1], 'Semi; de "Paris"');
    expect(semi[4], '21,1');
    expect(semi[5], '1:42:10');
    expect(semi[20], 'Ligne 1\nLigne 2');
  });

  test('Excel : classeur valide, une ligne par course, 26 colonnes', () {
    final zip = ZipDecoder().decodeBytes(backupWorkbook(courses, t, today: today));
    for (final f in zip.files) {
      XmlDocument.parse(String.fromCharCodes(f.content));
    }
    final sheet = XmlDocument.parse(
      utf8.decode(zip.files.firstWhere((f) => f.name == 'xl/worksheets/sheet1.xml').content),
    );
    final rows = sheet.findAllElements('row').toList();
    expect(rows, hasLength(2 + 1 + 3)); // titre, sous-titre, en-tête, 3 courses
    expect(rows[2].findElements('c'), hasLength(26));
    expect(rows.last.findElements('c').last.getAttribute('r'), 'Z7');
  });

  test('écriture des fichiers d\'exemple pour vérification manuelle', () {
    final dir = Platform.environment['ELAN_BACKUP_OUT'];
    if (dir == null) return;
    File('$dir/sauvegarde.csv').writeAsBytesSync(backupCsv(courses, t, today: today));
    File('$dir/sauvegarde.xlsx').writeAsBytesSync(backupWorkbook(courses, t, today: today));
  });
}
