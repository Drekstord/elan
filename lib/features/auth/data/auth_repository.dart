import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/backend.dart';
import '../../../core/providers.dart';

export '../../../core/backend/backend.dart' show AuthError, AuthFailure;

/// Connexion par e-mail et mot de passe, quel que soit le serveur (voir core/backend).
class AuthRepository {
  final Backend _backend;

  AuthRepository(this._backend);

  Future<void> signIn(String email, String password) => _backend.signIn(email, password);

  /// Serveur personnel tout neuf : le premier compte se crée depuis l'app.
  Future<bool> needsFirstAccount() => _backend.needsFirstAccount();
  Future<void> createFirstAccount(String email, String password) => _backend.createFirstAccount(email, password);

  bool get needsCurrentPassword => _backend.needsCurrentPassword;
  Future<void> changePassword(String newPassword, {String? current}) =>
      _backend.changePassword(newPassword, current: current);

  Future<void> signOut() => _backend.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(backendProvider)));
