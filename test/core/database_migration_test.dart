import 'package:app_course/core/database/database.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base créée par la version 1 du schéma (taux d'impact au km, pas de course à venir).
const _v1Courses = '''
CREATE TABLE courses (
  id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, race_date TEXT NOT NULL, course_type TEXT NOT NULL,
  distance_m INTEGER NOT NULL, duration_s INTEGER NOT NULL, elevation_gain_m INTEGER, team_size INTEGER,
  challenge_distance_m INTEGER, is_charity INTEGER NOT NULL, association_id TEXT, association_name TEXT,
  association_cause TEXT, association_description TEXT, sponsor_cents_per_km INTEGER NOT NULL,
  registration_donation_cents INTEGER NOT NULL, impact_metric TEXT NOT NULL, impact_rate_per_km REAL NOT NULL,
  impact_quantity REAL, bib_photo_key TEXT, medal_photo_key TEXT, notes TEXT, created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL, deleted_at TEXT, pending INTEGER NOT NULL DEFAULT 0
)''';

void main() {
  test('migration v1 -> v2 : données conservées, nouvelles colonnes par défaut', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(_v1Courses);
          raw.execute('CREATE TABLE photo_ops (photo_key TEXT NOT NULL PRIMARY KEY, kind TEXT NOT NULL)');
          raw.execute('CREATE TABLE meta (name TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
          raw.execute('''INSERT INTO courses VALUES ('a', 'Semi', '2026-04-12', 'officialRace', 21097, 5400, NULL, NULL,
        NULL, 1, NULL, 'AFM', 'sante', NULL, 0, 2000, 'researchHours', 0.1, NULL, NULL, NULL, NULL,
        '2026-04-13T10:00:00.000Z', '2026-04-13T10:00:00.000Z', NULL, 1)''');
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(db.close);

    final course = AppDatabase.toCourse(await db.select(db.courses).getSingle());
    expect(course.title, 'Semi');
    expect(course.registrationDonationCents, 2000);
    expect(course.isPlanned, isFalse);
    expect(course.fundraisingCents, 0);
    final row = await db.select(db.courses).getSingle();
    expect(row.pending, isTrue);
  });

  test('migration v2 -> v3 : données conservées, aucun justificatif', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(_v2Courses);
          raw.execute('CREATE TABLE photo_ops (photo_key TEXT NOT NULL PRIMARY KEY, kind TEXT NOT NULL)');
          raw.execute('CREATE TABLE meta (name TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');
          raw.execute('''INSERT INTO courses VALUES ('b', 'Octobre Solidaire', '2026-10-05', 'officialRace', 0, 7300, 3013,
        NULL, NULL, NULL, 1, NULL, 'AEH', 'handicap', NULL, 0, 1000, 0, 'euroDirect', NULL, NULL, NULL, NULL,
        '2026-10-05T10:00:00.000Z', '2026-10-05T10:00:00.000Z', NULL, 0)''');
          raw.execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(db.close);

    final course = AppDatabase.toCourse(await db.select(db.courses).getSingle());
    expect(course.title, 'Octobre Solidaire');
    expect(course.registrationDonationCents, 1000);
    expect(course.documents, isEmpty);

    // Un justificatif s'enregistre et se relit.
    final doc = CourseDocument(key: 'u/docs/x.pdf', name: 'facture.pdf', sizeBytes: 1234, addedAt: DateTime.utc(2026));
    await db
        .into(db.courses)
        .insertOnConflictUpdate(AppDatabase.toRow(course.copyWith(documents: [doc]), pending: true));
    final reread = AppDatabase.toCourse(await db.select(db.courses).getSingle());
    expect(reread.documents.single.name, 'facture.pdf');
    expect(reread.fileKeys, ['u/docs/x.pdf']);
  });
}

/// Base créée par la version 2 du schéma (avant les justificatifs).
const _v2Courses = '''
CREATE TABLE courses (
  id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, race_date TEXT NOT NULL, course_type TEXT NOT NULL,
  is_planned INTEGER NOT NULL DEFAULT 0, distance_m INTEGER NOT NULL, duration_s INTEGER NOT NULL,
  elevation_gain_m INTEGER, team_size INTEGER, challenge_distance_m INTEGER, is_charity INTEGER NOT NULL,
  association_id TEXT, association_name TEXT, association_cause TEXT, association_description TEXT,
  sponsor_cents_per_km INTEGER NOT NULL, registration_donation_cents INTEGER NOT NULL,
  fundraising_cents INTEGER NOT NULL DEFAULT 0, impact_metric TEXT NOT NULL, impact_quantity REAL,
  bib_photo_key TEXT, medal_photo_key TEXT, notes TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
  deleted_at TEXT, pending INTEGER NOT NULL DEFAULT 0
)''';
