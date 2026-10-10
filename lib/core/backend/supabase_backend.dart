import 'package:supabase_flutter/supabase_flutter.dart';

import '../server/server_config.dart';
import '../sync/remote_gateway.dart';
import 'backend.dart';

/// Serveur ÉLAN en ligne (Supabase). Les comptes y sont créés par l'administrateur,
/// dans le tableau de bord Supabase (inscriptions fermées).
class SupabaseBackend implements Backend {
  final SupabaseClient _client;

  SupabaseBackend._(this._client);

  static Future<SupabaseBackend> connect(ServerConfig server) async {
    await Supabase.initialize(url: server.url, publishableKey: server.key);
    return SupabaseBackend._(Supabase.instance.client);
  }

  static BackendUser? _user(User? user) => user == null ? null : BackendUser(id: user.id, email: user.email ?? '');

  @override
  BackendUser? get currentUser => _user(_client.auth.currentUser);

  @override
  Stream<BackendUser?> get userChanges => _client.auth.onAuthStateChange.map((event) => _user(event.session?.user));

  @override
  late final RemoteGateway gateway = SupabaseGateway(_client);

  @override
  Future<void> signIn(String email, String password) =>
      _guard(() => _client.auth.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  bool get needsCurrentPassword => false;

  @override
  Future<void> changePassword(String newPassword, {String? current}) =>
      _guard(() => _client.auth.updateUser(UserAttributes(password: newPassword)));

  @override
  Future<bool> needsFirstAccount() async => false;

  @override
  Future<void> createFirstAccount(String email, String password) =>
      throw const AuthError(AuthFailure.unknown, 'Les comptes de ce serveur sont créés par son administrateur.');

  // Serveur en ligne : les préférences vivent dans les données du compte, sans table à créer.
  @override
  Future<Map<String, dynamic>?> readPreferences() async {
    final user = (await _client.auth.getUser()).user;
    final raw = user?.userMetadata?['elan'];
    return raw is Map ? raw.cast<String, dynamic>() : null;
  }

  @override
  Future<void> writePreferences(Map<String, dynamic> preferences) =>
      _client.auth.updateUser(UserAttributes(data: {'elan': preferences}));

  @override
  ServerAccounts? get accounts => null;

  @override
  Future<void> dispose() => Supabase.instance.dispose();

  static Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on AuthRetryableFetchException catch (e) {
      throw AuthError(AuthFailure.offline, e.message);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (e.statusCode == '429' || msg.contains('rate limit')) throw AuthError(AuthFailure.rateLimited, e.message);
      if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
        throw AuthError(AuthFailure.wrongCredentials, e.message);
      }
      if (msg.contains('password')) throw AuthError(AuthFailure.weakPassword, e.message);
      throw AuthError(AuthFailure.unknown, e.message);
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(AuthFailure.offline, e.toString());
    }
  }
}
