import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart' as pb;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';
import '../media/media_store.dart';
import 'remote_gateway.dart';

/// Une version distante remplace la version locale, sauf si la locale est
/// en attente d'envoi et au moins aussi récente (dernière écriture gagnante,
/// comme le déclencheur SQL côté serveur).
bool shouldApplyRemote({
  required DateTime? localUpdatedAt,
  required bool localPending,
  required DateTime remoteUpdatedAt,
}) {
  if (localUpdatedAt == null || !localPending) return true;
  return remoteUpdatedAt.isAfter(localUpdatedAt);
}

/// Échange avec le serveur, dans cet ordre :
/// 1. envoi des photos ; 2. envoi des courses en attente ;
/// 3. suppression des photos remplacées ; 4. récupération des changements distants.
class SyncEngine {
  static const String cursorKey = 'sync.cursor';
  static const String lastSyncKey = 'sync.last_success';

  /// Une transaction validée tardivement côté serveur ne doit pas être manquée.
  static const Duration pullOverlap = Duration(minutes: 2);

  final AppDatabase db;
  final RemoteGateway remote;
  final MediaStore? media;

  SyncEngine(this.db, this.remote, {this.media});

  Future<void> run() async {
    await _pushPhotos();
    await _pushCourses();
    await _pushPhotoDeletes();
    await _pull();
    await db.writeMeta(lastSyncKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<DateTime?> lastSuccess() async {
    final raw = await db.readMeta(lastSyncKey);
    return raw == null ? null : DateTime.parse(raw);
  }

  Future<void> _pushPhotos() async {
    final ops = await (db.select(db.photoOps)..where((o) => o.kind.equalsValue(PhotoOpKind.upload))).get();
    for (final op in ops) {
      final store = media;
      if (store != null) {
        for (final key in {op.photoKey, MediaStore.thumbKeyOf(op.photoKey)}) {
          final file = store.fileFor(key);
          if (await file.exists()) await remote.uploadPhoto(key, file);
        }
      }
      await (db.delete(db.photoOps)..where((o) => o.photoKey.equals(op.photoKey))).go();
    }
  }

  Future<void> _pushCourses() async {
    final rows = await (db.select(db.courses)..where((c) => c.pending.equals(true))).get();
    if (rows.isEmpty) return;
    await remote.upsertCourses(rows.map(AppDatabase.toCourse).toList());
    for (final sent in rows) {
      // Une modification faite pendant l'envoi reste en attente.
      await (db.update(db.courses)..where((c) => c.id.equals(sent.id) & c.updatedAt.equals(sent.updatedAt))).write(
        const CoursesCompanion(pending: Value(false)),
      );
    }
  }

  Future<void> _pushPhotoDeletes() async {
    final ops = await (db.select(db.photoOps)..where((o) => o.kind.equalsValue(PhotoOpKind.delete))).get();
    if (ops.isEmpty) return;
    final keys = ops.map((o) => o.photoKey).toList();
    await remote.deletePhotos([
      for (final k in keys) ...{k, MediaStore.thumbKeyOf(k)},
    ]);
    await (db.delete(db.photoOps)..where((o) => o.photoKey.isIn(keys))).go();
  }

  Future<void> _pull() async {
    final rawCursor = await db.readMeta(cursorKey);
    final cursor = rawCursor == null ? null : DateTime.parse(rawCursor).subtract(pullOverlap);
    final rows = await remote.pullSince(cursor);
    if (rows.isEmpty) return;

    final staleKeys = <String>[];
    await db.transaction(() async {
      var newest = rawCursor == null ? null : DateTime.parse(rawCursor);
      for (final row in rows) {
        final incoming = row.course;
        final local = await (db.select(db.courses)..where((c) => c.id.equals(incoming.id))).getSingleOrNull();
        if (shouldApplyRemote(
          localUpdatedAt: local?.updatedAt,
          localPending: local?.pending ?? false,
          remoteUpdatedAt: incoming.updatedAt,
        )) {
          if (local != null) {
            // Photos et justificatifs retirés sur un autre appareil : nettoyage du cache.
            for (final key in AppDatabase.toCourse(local).fileKeys) {
              if (!incoming.fileKeys.contains(key)) staleKeys.add(key);
            }
          }
          await db.into(db.courses).insertOnConflictUpdate(AppDatabase.toRow(incoming, pending: false));
        }
        if (newest == null || row.serverUpdatedAt.isAfter(newest)) newest = row.serverUpdatedAt;
      }
      if (staleKeys.isNotEmpty) {
        await (db.delete(db.photoOps)..where((o) => o.photoKey.isIn(staleKeys))).go();
      }
      if (newest != null) await db.writeMeta(cursorKey, newest.toIso8601String());
    });
    for (final key in staleKeys) {
      await media?.deleteLocal(key);
    }
  }

  /// Fichier local d'une photo, téléchargé depuis le bucket si absent du cache.
  Future<File?> photoFile(String key) async {
    final store = media;
    if (store == null) return null;
    final file = store.fileFor(key);
    if (await file.exists()) return file;
    try {
      await store.writeDownloaded(key, await remote.downloadPhoto(key));
      return file;
    } catch (_) {
      return null;
    }
  }
}

/// Message lisible pour l'utilisateur à partir d'une erreur de synchro.
String describeSyncError(Object error) {
  // Serveur personnel (serveur ÉLAN).
  if (error is pb.ClientException) {
    if (error.statusCode == 0) return 'Pas de connexion. Les modifications partiront au retour du réseau.';
    if (error.statusCode == 401 || error.statusCode == 403) return 'Session expirée. Reconnecte-toi.';
    if (error.statusCode == 429) return 'Le serveur est très sollicité. Nouvel essai dans un instant.';
    if (error.statusCode == 404) return 'Serveur pas à jour : mets à jour le serveur ÉLAN, puis réessaie.';
    return 'Erreur du serveur (${error.statusCode}) : ${error.response['message'] ?? 'réessaie plus tard'}';
  }
  bool offline(String s) =>
      s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup');
  if (error is SocketException || error is TimeoutException || offline(error.toString())) {
    return 'Pas de connexion. Les modifications partiront au retour du réseau.';
  }
  // Serveur ÉLAN en ligne (Supabase).
  if (error is AuthException) return 'Session expirée. Reconnecte-toi.';
  if (error is PostgrestException) {
    if (error.code == '42P01' || error.code == 'PGRST205') {
      return 'Table « courses » introuvable : base du serveur pas à jour (supabase/001_schema.sql).';
    }
    if (error.code == '42501') return 'Accès refusé par le serveur (règles RLS).';
    if (error.code == 'PGRST204' && error.message.contains('multisport')) {
      return 'Triathlons non enregistrés sur le serveur : base pas à jour (supabase/003_multisport.sql).';
    }
    if (error.code == 'PGRST204' && error.message.contains('details')) {
      return 'Objectifs et classements non enregistrés sur le serveur : base pas à jour (supabase/004_details.sql).';
    }
    if (error.code == 'PGRST204' && error.message.contains('documents')) {
      return 'Colonne « documents » absente : base du serveur pas à jour (supabase/002_justificatifs.sql).';
    }
    return 'Erreur serveur : ${error.message}';
  }
  if (error is StorageException) {
    if (error.message.toLowerCase().contains('mime')) {
      return 'Type de fichier refusé par le stockage : base du serveur pas à jour (supabase/002_justificatifs.sql).';
    }
    return 'Envoi de fichier impossible : ${error.message}';
  }
  return 'Synchronisation impossible : $error';
}
