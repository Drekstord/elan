import 'dart:io';
import 'dart:typed_data';

import 'package:app_course/core/database/database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:app_course/core/media/media_store.dart';
import 'package:app_course/core/sync/remote_gateway.dart';
import 'package:app_course/core/sync/sync_engine.dart';
import 'package:app_course/features/courses/data/course_repository.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Serveur en mémoire qui reproduit le déclencheur `courses_before_write` :
/// une version plus ancienne n'écrase jamais la version stockée.
class FakeServer implements RemoteGateway {
  final Map<String, Map<String, dynamic>> rows = {};
  final Map<String, DateTime> stamps = {};
  final Map<String, Uint8List> objects = {};
  bool offline = false;
  var _clock = 0;

  void _online() {
    if (offline) throw const SocketException('Network is unreachable');
  }

  @override
  Future<void> upsertCourses(List<Course> courses) async {
    _online();
    for (final c in courses) {
      final existing = rows[c.id];
      if (existing != null && c.updatedAt.isBefore(DateTime.parse(existing['updated_at'] as String))) continue;
      rows[c.id] = c.toRemoteJson();
      stamps[c.id] = DateTime.utc(2030).add(Duration(seconds: ++_clock));
    }
  }

  @override
  Future<List<RemoteCourse>> pullSince(DateTime? cursor) async {
    _online();
    return [
      for (final e in rows.entries)
        if (cursor == null || stamps[e.key]!.isAfter(cursor))
          RemoteCourse(Course.fromRemoteJson(e.value), stamps[e.key]!),
    ]..sort((a, b) => a.serverUpdatedAt.compareTo(b.serverUpdatedAt));
  }

  @override
  Future<void> uploadPhoto(String key, File file) async {
    _online();
    objects[key] = await file.readAsBytes();
  }

  @override
  Future<Uint8List> downloadPhoto(String key) async {
    _online();
    return objects[key] ?? (throw const FileSystemException('Object not found'));
  }

  @override
  Future<void> deletePhotos(List<String> keys) async {
    _online();
    keys.forEach(objects.remove);
  }
}

class Device {
  final AppDatabase db;
  final CourseRepository repo;
  final SyncEngine sync;
  final MediaStore media;

  Device._(this.db, this.repo, this.sync, this.media);

  factory Device(FakeServer server, Directory dir) {
    final db = AppDatabase.inMemory();
    final media = MediaStore(dir, 'user-1');
    return Device._(db, CourseRepository(db, media: media), SyncEngine(db, server, media: media), media);
  }

  Future<List<Course>> courses() => repo.watchCourses().first;
  Future<int> pending() => repo.watchPendingCount().first;
}

Course course(String id, {String title = 'Course', int distanceM = 10000}) =>
    Course(id: id, title: title, raceDate: calendarDate(2026, 10, 1), distanceM: distanceM, durationS: 3000);

void main() {
  late FakeServer server;
  late Directory tmp;
  late Device pc;
  late Device phone;

  // Deux « appareils » simulés dans le même processus : avertissement attendu.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    server = FakeServer();
    tmp = await Directory.systemTemp.createTemp('elan_sync');
    pc = Device(server, Directory('${tmp.path}/pc'));
    phone = Device(server, Directory('${tmp.path}/phone'));
  });

  tearDown(() async {
    await pc.db.close();
    await phone.db.close();
    await tmp.delete(recursive: true);
  });

  test('une course créée sur un appareil apparaît sur l\'autre', () async {
    await pc.repo.save(course('a', title: 'Semi de Paris'));
    expect(await pc.pending(), 1);

    await pc.sync.run();
    expect(await pc.pending(), 0);

    await phone.sync.run();
    expect((await phone.courses()).single.title, 'Semi de Paris');
  });

  test('une modification se propage', () async {
    await pc.repo.save(course('a', title: 'Avant'));
    await pc.sync.run();
    await phone.sync.run();

    await phone.repo.save((await phone.courses()).single.copyWith(title: 'Après'));
    await phone.sync.run();
    await pc.sync.run();

    expect((await pc.courses()).single.title, 'Après');
  });

  test('une suppression se propage et la course ne ressuscite pas', () async {
    await pc.repo.save(course('a'));
    await pc.sync.run();
    await phone.sync.run();

    await phone.repo.delete('a');
    await phone.sync.run();
    await pc.sync.run();
    await pc.sync.run();
    await phone.sync.run();

    expect(await pc.courses(), isEmpty);
    expect(await phone.courses(), isEmpty);
    expect(server.rows['a']!['deleted_at'], isNotNull);
  });

  test('conflit : la dernière modification gagne sur les deux appareils', () async {
    await pc.repo.save(course('a', title: 'Origine'));
    await pc.sync.run();
    await phone.sync.run();

    await pc.repo.save((await pc.courses()).single.copyWith(title: 'Version PC'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await phone.repo.save((await phone.courses()).single.copyWith(title: 'Version téléphone'));

    await pc.sync.run(); // envoie en premier, mais sa version est plus ancienne
    await phone.sync.run();
    await pc.sync.run();

    expect((await pc.courses()).single.title, 'Version téléphone');
    expect((await phone.courses()).single.title, 'Version téléphone');
  });

  test('hors ligne : les modifications restent en attente puis partent', () async {
    server.offline = true;
    await pc.repo.save(course('a'));
    await pc.repo.delete('a');
    await pc.repo.save(course('b'));

    await expectLater(pc.sync.run(), throwsA(isA<SocketException>()));
    expect(describeSyncError(const SocketException('x')), contains('Pas de connexion'));
    expect(await pc.pending(), 2);

    server.offline = false;
    await pc.sync.run();
    expect(await pc.pending(), 0);
    expect(server.rows['a']!['deleted_at'], isNotNull);
    expect(server.rows['b']!['deleted_at'], isNull);
  });

  test('photos : redimensionnement, miniature, envoi, récupération et nettoyage', () async {
    final big = img.Image(width: 3000, height: 1500);
    final source = File('${tmp.path}/medaille.png')..writeAsBytesSync(img.encodePng(big));

    final firstKey = await pc.media.importPhoto(source);
    expect(firstKey, startsWith('user-1/'));
    final stored = img.decodeJpg(await pc.media.fileFor(firstKey).readAsBytes())!;
    expect(stored.width, MediaStore.maxSide);
    expect(pc.media.fileFor(MediaStore.thumbKeyOf(firstKey)).existsSync(), isTrue);

    await pc.repo.save(course('a').copyWith(medalPhotoKey: firstKey));
    await pc.sync.run();
    expect(server.objects.keys, containsAll([firstKey, MediaStore.thumbKeyOf(firstKey)]));
    expect(server.rows['a']!['medal_photo_key'], firstKey);

    await phone.sync.run();
    expect(await phone.sync.photoFile(firstKey), isNotNull);

    final secondKey = await pc.media.importPhoto(source);
    await pc.repo.save((await pc.courses()).single.copyWith(medalPhotoKey: secondKey));
    await pc.sync.run();
    expect(server.objects.keys.toSet(), {secondKey, MediaStore.thumbKeyOf(secondKey)});
    expect(pc.media.fileFor(firstKey).existsSync(), isFalse);
  });

  test("justificatifs : PDF envoyé tel quel, récupéré sur l'autre appareil, retiré partout", () async {
    final pdf = File('${tmp.path}/facture.pdf')..writeAsBytesSync([0x25, 0x50, 0x44, 0x46, 1, 2, 3]);
    final key = (await pc.media.importDocument(pdf))!;
    expect(key, startsWith('user-1/docs/'));
    expect(key, endsWith('.pdf'));

    final doc = CourseDocument(key: key, name: 'facture.pdf', sizeBytes: 7, addedAt: DateTime.utc(2026, 10, 1));
    await pc.repo.save(course('a').copyWith(documents: [doc]));
    await pc.sync.run();
    expect(server.objects[key], [0x25, 0x50, 0x44, 0x46, 1, 2, 3]);
    expect((server.rows['a']!['documents'] as List).single['name'], 'facture.pdf');

    await phone.sync.run();
    final onPhone = (await phone.courses()).single;
    expect(onPhone.documents.single.name, 'facture.pdf');
    expect(await (await phone.sync.photoFile(key))!.readAsBytes(), [0x25, 0x50, 0x44, 0x46, 1, 2, 3]);

    await pc.repo.save((await pc.courses()).single.copyWith(documents: const []));
    await pc.sync.run();
    expect(server.objects.containsKey(key), isFalse);
    await phone.sync.run();
    expect((await phone.courses()).single.documents, isEmpty);
    expect(phone.media.fileFor(key).existsSync(), isFalse);
  });

  test('justificatif trop lourd refusé', () async {
    final big = File('${tmp.path}/gros.pdf')..writeAsBytesSync(List.filled(MediaStore.maxDocumentBytes + 1, 0));
    expect(await pc.media.importDocument(big), isNull);
  });

  test('shouldApplyRemote', () {
    final older = DateTime.utc(2026, 1, 1);
    final newer = DateTime.utc(2026, 1, 2);
    expect(shouldApplyRemote(localUpdatedAt: newer, localPending: true, remoteUpdatedAt: older), isFalse);
    expect(shouldApplyRemote(localUpdatedAt: older, localPending: true, remoteUpdatedAt: newer), isTrue);
    expect(shouldApplyRemote(localUpdatedAt: newer, localPending: false, remoteUpdatedAt: older), isTrue);
    expect(shouldApplyRemote(localUpdatedAt: null, localPending: false, remoteUpdatedAt: older), isTrue);
  });
}
