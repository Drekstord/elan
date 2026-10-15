import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/domain/course.dart';
import '../server/server_config.dart';
import '../sync/remote_gateway.dart';
import 'backend.dart';

/// Serveur personnel (« serveur ÉLAN », dossier serveur du dépôt) : un PocketBase réglé pour l'app.
///
/// - connexion et comptes : routes standard de PocketBase (collection `users`) ;
/// - courses : routes /api/elan/courses (envoi groupé, la plus récente gagne, repère de synchro) ;
/// - photos et justificatifs : collection `fichiers`, un enregistrement par fichier.
class ElanBackend implements Backend {
  final PocketBase pb;
  final http.Client _http;

  ElanBackend(String url, {AuthStore? authStore, http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      pb = PocketBase(url, lang: 'fr-FR', authStore: authStore, httpClientFactory: () => httpClient ?? http.Client());

  /// Reprend la session gardée sur l'appareil, puis la renouvelle en arrière-plan.
  static Future<ElanBackend> connect(ServerConfig server, SharedPreferences prefs) async {
    final key = server.sessionStorageKey;
    final backend = ElanBackend(
      server.url,
      authStore: AsyncAuthStore(
        initial: prefs.getString(key),
        save: (data) => prefs.setString(key, data),
        clear: () => prefs.remove(key),
      ),
    );
    unawaited(backend.refreshSession());
    return backend;
  }

  RecordService get _users => pb.collection('users');

  /// Prolonge la session. Compte supprimé ou mot de passe changé ailleurs : déconnexion.
  /// Sans réseau, la session en cours est gardée (l'app fonctionne hors ligne).
  Future<void> refreshSession() async {
    if (pb.authStore.token.isEmpty) return;
    if (!pb.authStore.isValid) return pb.authStore.clear();
    try {
      await _users.authRefresh();
    } on ClientException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) pb.authStore.clear();
    }
  }

  static BackendUser? _user(RecordModel? record) => record == null
      ? null
      : BackendUser(id: record.id, email: record.getStringValue('email'), isOwner: record.getBoolValue('proprietaire'));

  @override
  BackendUser? get currentUser => pb.authStore.isValid ? _user(pb.authStore.record) : null;

  @override
  Stream<BackendUser?> get userChanges => pb.authStore.onChange.map((_) => currentUser).distinct();

  @override
  late final RemoteGateway gateway = ElanGateway(pb, _http);

  @override
  Future<void> signIn(String email, String password) =>
      _guard(() => _users.authWithPassword(email.trim(), password), onRefused: AuthFailure.wrongCredentials);

  @override
  Future<void> signOut() async => pb.authStore.clear();

  /// Le serveur change la clé des sessions du compte, puis renvoie une session neuve pour cet
  /// appareil : toutes les autres deviennent invalides.
  @override
  Future<void> signOutOtherDevices() => _guard(() async {
    final response = await pb.send<Map<String, dynamic>>('/api/elan/deconnecter-partout', method: 'POST');
    pb.authStore.save(
      response['token'] as String,
      RecordModel.fromJson((response['record'] as Map).cast<String, dynamic>()),
    );
    return null;
  });

  @override
  bool get needsCurrentPassword => true;

  @override
  Future<void> changePassword(String newPassword, {String? current}) async {
    final user = currentUser ?? (throw const AuthError(AuthFailure.unknown, 'Session expirée.'));
    await _guard(
      () => _users.update(
        user.id,
        body: {'oldPassword': current ?? '', 'password': newPassword, 'passwordConfirm': newPassword},
      ),
    );
    // Le serveur ferme les sessions ouvertes avec l'ancien mot de passe : on rouvre celle-ci.
    await signIn(user.email, newPassword);
  }

  @override
  Future<bool> needsFirstAccount() async =>
      (await fetchElanStatus(pb.baseURL, client: _http))?.needsFirstAccount ?? false;

  @override
  Future<void> createFirstAccount(String email, String password, {required String setupCode}) async {
    await _guard(
      () => pb.send<dynamic>(
        '/api/elan/premier-compte',
        method: 'POST',
        body: {'email': email.trim(), 'password': password, 'code': setupCode.trim().toUpperCase()},
      ),
      // 401 : code d'installation absent ou faux.
      onUnauthorized: AuthFailure.wrongSetupCode,
    );
    await signIn(email, password);
  }

  // Serveur personnel : champ « preferences » du compte (ajouté par la mise à jour 1.1 du serveur).
  // Un serveur plus ancien ignore ce champ : rien n'est gardé, et rien ne casse.
  @override
  Future<Map<String, dynamic>?> readPreferences() async {
    final user = currentUser;
    if (user == null) return null;
    final raw = (await _users.getOne(user.id)).data['preferences'];
    return raw is Map && raw.isNotEmpty ? raw.cast<String, dynamic>() : null;
  }

  @override
  Future<void> writePreferences(Map<String, dynamic> preferences) async {
    final user = currentUser;
    if (user != null) await _users.update(user.id, body: {'preferences': preferences});
  }

  @override
  ServerAccounts? get accounts => (currentUser?.isOwner ?? false) ? _ElanAccounts(this) : null;

  @override
  Future<void> dispose() async {
    pb.close();
    _http.close();
  }

  /// Traduit les erreurs du serveur en erreurs lisibles par les écrans.
  static Future<void> _guard(
    Future<Object?> Function() action, {
    AuthFailure onRefused = AuthFailure.unknown,
    AuthFailure? onUnauthorized,
  }) async {
    try {
      await action();
    } on ClientException catch (e) {
      final fields = (e.response['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      String? code(String field) => (fields[field] as Map?)?['code'] as String?;
      final message = e.response['message'] as String?;
      if (e.statusCode == 0) throw AuthError(AuthFailure.offline, e.originalError?.toString());
      if (e.statusCode == 429) throw AuthError(AuthFailure.rateLimited, message);
      if (e.statusCode == 401 && onUnauthorized != null) throw AuthError(onUnauthorized, message);
      if (code('oldPassword') != null) throw AuthError(AuthFailure.wrongCredentials, message);
      if (code('email') == 'validation_not_unique') throw AuthError(AuthFailure.emailTaken, message);
      if (code('password') != null || code('passwordConfirm') != null) {
        throw AuthError(AuthFailure.weakPassword, message);
      }
      throw AuthError(e.statusCode == 400 ? onRefused : AuthFailure.unknown, message);
    }
  }
}

class _ElanAccounts implements ServerAccounts {
  final ElanBackend _backend;

  _ElanAccounts(this._backend);

  RecordService get _users => _backend.pb.collection('users');

  @override
  Future<List<ServerAccount>> list() async {
    final records = await _users.getFullList(sort: 'created');
    return [
      for (final r in records)
        ServerAccount(id: r.id, email: r.getStringValue('email'), isOwner: r.getBoolValue('proprietaire')),
    ];
  }

  @override
  Future<void> create(String email, String password) => ElanBackend._guard(
    () => _users.create(
      body: {'email': email.trim(), 'password': password, 'passwordConfirm': password, 'verified': true},
    ),
  );

  @override
  Future<void> resetPassword(String accountId, String newPassword) => ElanBackend._guard(
    () => _users.update(accountId, body: {'password': newPassword, 'passwordConfirm': newPassword}),
  );

  @override
  Future<void> delete(String accountId) => ElanBackend._guard(() => _users.delete(accountId));
}

/// Synchronisation avec un serveur ÉLAN.
class ElanGateway implements RemoteGateway {
  static const int _pageSize = 500;
  static const int _batchSize = 200;

  final PocketBase pb;
  final http.Client _http;

  ElanGateway(this.pb, this._http);

  RecordService get _files => pb.collection('fichiers');

  String get _userId => pb.authStore.record?.id ?? (throw ClientException(statusCode: 401));

  @override
  Future<void> upsertCourses(List<Course> courses) async {
    for (var start = 0; start < courses.length; start += _batchSize) {
      await pb.send<dynamic>(
        '/api/elan/courses',
        method: 'POST',
        body: {
          'courses': [
            for (final c in courses.skip(start).take(_batchSize))
              {'id': c.id, 'modifie_ms': c.updatedAt.millisecondsSinceEpoch, 'donnees': c.toRemoteJson()},
          ],
        },
      );
    }
  }

  @override
  Future<List<RemoteCourse>> pullSince(DateTime? cursor) async {
    final result = <RemoteCourse>[];
    var since = cursor?.millisecondsSinceEpoch ?? 0;
    while (true) {
      final response = await pb.send<Map<String, dynamic>>(
        '/api/elan/courses',
        query: {'depuis': '$since', 'limite': '$_pageSize'},
      );
      final rows = (response['courses'] as List).cast<Map<String, dynamic>>();
      for (final row in rows) {
        since = (row['serveur_ms'] as num).toInt();
        result.add(
          RemoteCourse(
            Course.fromRemoteJson((row['donnees'] as Map).cast<String, dynamic>()),
            DateTime.fromMillisecondsSinceEpoch(since, isUtc: true),
          ),
        );
      }
      if (rows.length < _pageSize) return result;
    }
  }

  Future<RecordModel?> _find(String key) async {
    try {
      return await _files.getFirstListItem(pb.filter('cle = {:cle}', {'cle': key}));
    } on ClientException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> uploadPhoto(String key, File file) async {
    final existing = await _find(key);
    final files = [await http.MultipartFile.fromPath('fichier', file.path, filename: p.basename(key))];
    if (existing == null) {
      await _files.create(body: {'proprietaire': _userId, 'cle': key}, files: files);
    } else {
      await _files.update(existing.id, files: files);
    }
  }

  @override
  Future<Uint8List> downloadPhoto(String key) async {
    final record = await _find(key) ?? (throw ClientException(statusCode: 404));
    // Fichiers protégés : lisibles avec un jeton de courte durée demandé par leur propriétaire.
    final token = await pb.files.getToken();
    final url = pb.files.getURL(record, record.getStringValue('fichier'), token: token);
    final response = await _http.get(url);
    if (response.statusCode != 200) throw ClientException(url: url, statusCode: response.statusCode);
    return response.bodyBytes;
  }

  @override
  Future<void> deletePhotos(List<String> keys) async {
    for (final key in keys) {
      final record = await _find(key);
      if (record != null) await _files.delete(record.id);
    }
  }
}
