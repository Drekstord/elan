import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/courses/domain/course.dart';
import '../config.dart';

/// Ligne reçue du serveur : la course et son horodatage serveur (curseur de synchro).
class RemoteCourse {
  final Course course;
  final DateTime serverUpdatedAt;

  const RemoteCourse(this.course, this.serverUpdatedAt);
}

/// Accès au backend, isolé pour tester la synchronisation sans réseau.
abstract class RemoteGateway {
  Future<void> upsertCourses(List<Course> courses);
  Future<List<RemoteCourse>> pullSince(DateTime? cursor);
  Future<void> uploadPhoto(String key, File file);
  Future<Uint8List> downloadPhoto(String key);
  Future<void> deletePhotos(List<String> keys);
}

class SupabaseGateway implements RemoteGateway {
  static const int _pageSize = 500;

  final SupabaseClient client;

  SupabaseGateway(this.client);

  String get _userId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Session expirée.');
    return id;
  }

  @override
  Future<void> upsertCourses(List<Course> courses) async {
    if (courses.isEmpty) return;
    final uid = _userId;
    await client.from('courses').upsert([
      for (final c in courses) {...c.toRemoteJson(), 'user_id': uid},
    ], onConflict: 'user_id,id');
  }

  @override
  Future<List<RemoteCourse>> pullSince(DateTime? cursor) async {
    final result = <RemoteCourse>[];
    for (var offset = 0; ; offset += _pageSize) {
      var query = client.from('courses').select();
      if (cursor != null) query = query.gt('server_updated_at', cursor.toUtc().toIso8601String());
      final page = await query
          .order('server_updated_at', ascending: true)
          .order('id', ascending: true)
          .range(offset, offset + _pageSize - 1);
      for (final row in page) {
        result.add(
          RemoteCourse(Course.fromRemoteJson(row), DateTime.parse(row['server_updated_at'] as String).toUtc()),
        );
      }
      if (page.length < _pageSize) return result;
    }
  }

  @override
  Future<void> uploadPhoto(String key, File file) => client.storage
      .from(AppConfig.mediaBucket)
      .upload(key, file, fileOptions: FileOptions(upsert: true, contentType: _contentType(key)));

  @override
  Future<Uint8List> downloadPhoto(String key) => client.storage.from(AppConfig.mediaBucket).download(key);

  @override
  Future<void> deletePhotos(List<String> keys) async {
    if (keys.isNotEmpty) await client.storage.from(AppConfig.mediaBucket).remove(keys);
  }

  static String _contentType(String key) => switch (key.split('.').last.toLowerCase()) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'pdf' => 'application/pdf',
    _ => 'image/jpeg',
  };
}
