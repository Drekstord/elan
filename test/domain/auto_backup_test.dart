import 'dart:io';

import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/settings/auto_backup.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  final t = AppLocalizationsFr();
  final courses = [
    Course(
      id: 'a',
      title: 'Foulée de Démoville',
      raceDate: calendarDate(2026, 10, 4),
      distanceM: 10000,
      durationS: 3000,
      medalPhotoKey: 'u/medaille.jpg',
      bibPhotoKey: 'u/dossard.png',
      documents: [
        CourseDocument(
          key: 'u/docs/f.pdf',
          name: 'scan.pdf',
          sizeBytes: 10,
          addedAt: DateTime.utc(2026, 9, 1),
          kind: DocumentKind.invoice,
        ),
      ],
    ),
    Course(
      id: 'b',
      title: 'Trail : des Monts/Imaginaires',
      raceDate: calendarDate(2025, 5, 1),
      distanceM: 20000,
      medalPhotoKey: 'u/absente.jpg',
    ),
    Course(
      id: 'c',
      title: 'Supprimée',
      raceDate: calendarDate(2025, 1, 1),
      distanceM: 1,
      deletedAt: DateTime.utc(2026),
      medalPhotoKey: 'u/x.jpg',
    ),
  ];

  test('noms lisibles, rangés par année, caractères interdits retirés, supprimées ignorées', () {
    expect(backupMediaFiles(courses, t), {
      '2026/2026-10-04 Foulée de Démoville - Dossard.png': 'u/dossard.png',
      '2026/2026-10-04 Foulée de Démoville - Médaille.jpg': 'u/medaille.jpg',
      '2026/2026-10-04 Foulée de Démoville - Facture.pdf': 'u/docs/f.pdf',
      '2025/2025-05-01 Trail des Monts Imaginaires - Médaille.jpg': 'u/absente.jpg',
    });
  });

  test('classeur du jour, fichiers copiés une seule fois, introuvables comptés, anciens classeurs retirés', () async {
    final source = Directory.systemTemp.createTempSync('elan_src');
    final target = Directory.systemTemp.createTempSync('elan_backup');
    addTearDown(() {
      source.deleteSync(recursive: true);
      target.deleteSync(recursive: true);
    });
    Future<File?> fileOf(String key) async {
      if (key == 'u/absente.jpg') return null;
      return File(p.join(source.path, key.replaceAll('/', '_')))..writeAsStringSync(key);
    }

    final root = Directory(p.join(target.path, autoBackupRoot))..createSync();
    for (var d = 1; d <= 9; d++) {
      File(p.join(root.path, 'ELAN-sauvegarde-2026-09-0$d.xlsx')).writeAsStringSync('ancien');
    }
    File(p.join(root.path, 'mes notes.txt')).writeAsStringSync('à garder');

    final first = await writeBackup(
      folder: target,
      courses: courses,
      t: t,
      today: calendarDate(2026, 10, 10),
      fileOf: fileOf,
    );
    expect(first.workbook, 'ELAN-sauvegarde-2026-10-10.xlsx');
    expect(first.copied, 3);
    expect(first.missing, 1);
    final medal = File(p.join(root.path, autoBackupMediaDir, '2026', '2026-10-04 Foulée de Démoville - Médaille.jpg'));
    expect(medal.readAsStringSync(), 'u/medaille.jpg');

    final names = root.listSync().whereType<File>().map((f) => p.basename(f.path)).toList()..sort();
    expect(names.where((n) => n.endsWith('.xlsx')), hasLength(autoBackupKeep));
    expect(names, contains('ELAN-sauvegarde-2026-10-10.xlsx'));
    expect(names, isNot(contains('ELAN-sauvegarde-2026-09-01.xlsx')));
    expect(names, contains('mes notes.txt'));

    // Semaine suivante : rien de neuf à copier, la photo manquante est réessayée.
    final second = await writeBackup(
      folder: target,
      courses: courses,
      t: t,
      today: calendarDate(2026, 10, 17),
      fileOf: fileOf,
    );
    expect(second.copied, 0);
    expect(second.missing, 1);
  });

  test("échéance : désactivée, sans dossier, récente ou passée d'une semaine", () {
    final old = DateTime.now().subtract(const Duration(days: 8));
    expect(const AutoBackupState(enabled: false, folder: 'x').isDue, isFalse);
    expect(const AutoBackupState(enabled: true).isDue, isFalse);
    expect(const AutoBackupState(enabled: true, folder: 'x').isDue, isTrue);
    expect(AutoBackupState(enabled: true, folder: 'x', last: DateTime.now()).isDue, isFalse);
    expect(AutoBackupState(enabled: true, folder: 'x', last: old).isDue, isTrue);
  });
}
