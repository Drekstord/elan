import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/media/media_store.dart';
import '../domain/course.dart';

/// Lecture et écriture des courses dans la base locale.
///
/// Hors-ligne d'abord : chaque écriture est immédiate en local et marquée
/// « en attente » ; [onLocalChange] prévient la synchronisation.
class CourseRepository {
  final AppDatabase db;
  final MediaStore? media;
  void Function()? onLocalChange;

  CourseRepository(this.db, {this.media, this.onLocalChange});

  Stream<List<Course>> watchCourses() {
    final query = db.select(db.courses)
      ..where((c) => c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.desc(c.raceDate), (c) => OrderingTerm.desc(c.createdAt)]);
    return query.watch().map((rows) => rows.map(AppDatabase.toCourse).toList());
  }

  Future<Course?> find(String id) async {
    final row = await (db.select(db.courses)..where((c) => c.id.equals(id))).getSingleOrNull();
    return row == null || row.deletedAt != null ? null : AppDatabase.toCourse(row);
  }

  /// Nombre d'éléments pas encore envoyés (courses + opérations photo).
  Stream<int> watchPendingCount() => db
      .customSelect(
        'SELECT (SELECT COUNT(*) FROM courses WHERE pending = 1) + (SELECT COUNT(*) FROM photo_ops) AS n',
        readsFrom: {db.courses, db.photoOps},
      )
      .watchSingle()
      .map((row) => row.read<int>('n'));

  Future<void> save(Course course) async {
    await db.transaction(() async {
      final previous = await _row(course.id);
      final stamped = course.copyWith(updatedAt: _nextTimestamp(previous?.updatedAt), deletedAt: null);
      await _trackFiles(_keysOf(previous), stamped.fileKeys);
      await db.into(db.courses).insertOnConflictUpdate(AppDatabase.toRow(stamped, pending: true));
    });
    onLocalChange?.call();
  }

  Future<void> delete(String id) async {
    await db.transaction(() async {
      final previous = await _row(id);
      if (previous == null || previous.deletedAt != null) return;
      final now = _nextTimestamp(previous.updatedAt);
      await _trackFiles(_keysOf(previous), const []);
      final tombstone = AppDatabase.toCourse(previous)
          .copyWith(updatedAt: now, deletedAt: now, bibPhotoKey: null, medalPhotoKey: null, documents: const []);
      await db.into(db.courses).insertOnConflictUpdate(AppDatabase.toRow(tombstone, pending: true));
    });
    onLocalChange?.call();
  }

  /// Import ponctuel : n'écrase jamais une course déjà connue. Retourne le nombre importé.
  Future<int> importCourses(List<Course> courses) async {
    var count = 0;
    await db.transaction(() async {
      for (final course in courses) {
        if (await _row(course.id) != null) continue;
        await db.into(db.courses).insert(AppDatabase.toRow(course, pending: true));
        for (final key in course.fileKeys) {
          await _setPhotoOp(key, PhotoOpKind.upload);
        }
        count++;
      }
    });
    if (count > 0) onLocalChange?.call();
    return count;
  }

  Future<CourseRow?> _row(String id) => (db.select(db.courses)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Fichiers (photos et justificatifs) d'une course enregistrée.
  static List<String> _keysOf(CourseRow? row) => row == null ? const [] : AppDatabase.toCourse(row).fileKeys;

  /// Horodatage strictement croissant pour une même course, même si l'horloge recule.
  static DateTime _nextTimestamp(DateTime? previous) {
    final now = DateTime.now().toUtc();
    if (previous != null && !now.isAfter(previous)) return previous.toUtc().add(const Duration(milliseconds: 1));
    return now;
  }

  /// Envois et suppressions de fichiers (photos, justificatifs) à faire au prochain échange.
  Future<void> _trackFiles(List<String> before, List<String> after) async {
    for (final key in after) {
      if (!before.contains(key)) await _setPhotoOp(key, PhotoOpKind.upload);
    }
    for (final key in before) {
      if (after.contains(key)) continue;
      final existing = await (db.select(db.photoOps)..where((o) => o.photoKey.equals(key))).getSingleOrNull();
      if (existing?.kind == PhotoOpKind.upload) {
        // Jamais envoyée : il suffit d'annuler l'envoi.
        await (db.delete(db.photoOps)..where((o) => o.photoKey.equals(key))).go();
      } else {
        await _setPhotoOp(key, PhotoOpKind.delete);
      }
      await media?.deleteLocal(key);
    }
  }

  Future<void> _setPhotoOp(String key, PhotoOpKind kind) =>
      db.into(db.photoOps).insertOnConflictUpdate(PhotoOpsCompanion.insert(photoKey: key, kind: kind));
}
