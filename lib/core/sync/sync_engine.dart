import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';

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

/// Message lisible pour l'utilisateur à partir d'une erreur de synchro, dans la langue de l'app.
String describeSyncError(Object error) {
  final english = (Intl.defaultLocale ?? 'fr').startsWith('en');
  String say(String fr, String en) => english ? en : fr;
  final offlineMessage = say(
    'Pas de connexion. Les modifications partiront au retour du réseau.',
    'No connection. Your changes will be sent when the network is back.',
  );
  final expired = say('Session expirée. Reconnecte-toi.', 'Session expired. Sign in again.');
  String outdated(String what, String whatEn, String script) => say(
    '$what : base du serveur pas à jour (supabase/$script).',
    '$whatEn: server database not up to date (supabase/$script).',
  );

  // Serveur personnel (serveur ÉLAN).
  if (error is pb.ClientException) {
    if (error.statusCode == 0) return offlineMessage;
    if (error.statusCode == 401 || error.statusCode == 403) return expired;
    if (error.statusCode == 429) {
      return say(
        'Le serveur est très sollicité. Nouvel essai dans un instant.',
        'The server is very busy. Trying again in a moment.',
      );
    }
    if (error.statusCode == 404) {
      return say(
        'Serveur pas à jour : mets à jour le serveur ÉLAN, puis réessaie.',
        'Server not up to date: update the ÉLAN server, then try again.',
      );
    }
    final detail = error.response['message'] ?? say('réessaie plus tard', 'try again later');
    return say('Erreur du serveur (${error.statusCode}) : $detail', 'Server error (${error.statusCode}): $detail');
  }
  bool offline(String s) =>
      s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup');
  if (error is SocketException || error is TimeoutException || offline(error.toString())) return offlineMessage;
  // Serveur ÉLAN en ligne (Supabase).
  if (error is AuthException) return expired;
  if (error is PostgrestException) {
    if (error.code == '42P01' || error.code == 'PGRST205') {
      return outdated('Table « courses » introuvable', 'Table “courses” not found', '001_schema.sql');
    }
    if (error.code == '42501') {
      return say('Accès refusé par le serveur (règles RLS).', 'Access denied by the server (RLS rules).');
    }
    if (error.code == 'PGRST204' && error.message.contains('multisport')) {
      return outdated(
        'Triathlons non enregistrés sur le serveur',
        'Triathlons not saved on the server',
        '003_multisport.sql',
      );
    }
    if (error.code == 'PGRST204' && error.message.contains('details')) {
      return outdated(
        'Objectifs et classements non enregistrés sur le serveur',
        'Targets and rankings not saved on the server',
        '004_details.sql',
      );
    }
    if (error.code == 'PGRST204' && error.message.contains('documents')) {
      return outdated('Colonne « documents » absente', 'Column “documents” missing', '002_justificatifs.sql');
    }
    return say('Erreur serveur : ${error.message}', 'Server error: ${error.message}');
  }
  if (error is StorageException) {
    if (error.message.toLowerCase().contains('mime')) {
      return outdated(
        'Type de fichier refusé par le stockage',
        'File type refused by the storage',
        '002_justificatifs.sql',
      );
    }
    return say('Envoi de fichier impossible : ${error.message}', 'File upload failed: ${error.message}');
  }
  return say('Synchronisation impossible : $error', 'Sync failed: $error');
}
