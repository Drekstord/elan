import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';

enum AuthFailure { wrongCredentials, rateLimited, offline, weakPassword, unknown }

class AuthError implements Exception {
  final AuthFailure reason;
  final String? detail;
  const AuthError(this.reason, [this.detail]);
}

/// Connexion par e-mail et mot de passe. Les comptes sont créés par
/// l'administrateur dans le tableau de bord Supabase (inscriptions fermées).
class AuthRepository {
  final GoTrueClient _auth;

  AuthRepository(this._auth);

  Future<void> signIn(String email, String password) =>
      _guard(() => _auth.signInWithPassword(email: email.trim(), password: password));

  Future<void> changePassword(String newPassword) =>
      _guard(() => _auth.updateUser(UserAttributes(password: newPassword)));

  Future<void> signOut() => _auth.signOut();

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

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(supabaseProvider).auth));
