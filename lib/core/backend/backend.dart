import 'package:shared_preferences/shared_preferences.dart';

import '../server/server_config.dart';
import '../sync/remote_gateway.dart';
import 'elan_backend.dart';
import 'supabase_backend.dart';

enum AuthFailure { wrongCredentials, rateLimited, offline, weakPassword, emailTaken, wrongSetupCode, unknown }

class AuthError implements Exception {
  final AuthFailure reason;
  final String? detail;
  const AuthError(this.reason, [this.detail]);

  @override
  String toString() => 'AuthError($reason${detail == null ? '' : ', $detail'})';
}

/// Compte connecté.
class BackendUser {
  final String id;
  final String email;

  /// Propriétaire d'un serveur personnel : peut gérer les comptes des proches.
  final bool isOwner;

  const BackendUser({required this.id, required this.email, this.isOwner = false});

  @override
  bool operator ==(Object other) =>
      other is BackendUser && other.id == id && other.email == email && other.isOwner == isOwner;

  @override
  int get hashCode => Object.hash(id, email, isOwner);
}

/// Compte d'un serveur personnel, vu par son propriétaire.
class ServerAccount {
  final String id;
  final String email;
  final bool isOwner;

  const ServerAccount({required this.id, required this.email, required this.isOwner});
}

/// Gestion des comptes d'un serveur personnel, réservée à son propriétaire.
abstract class ServerAccounts {
  Future<List<ServerAccount>> list();
  Future<void> create(String email, String password);
  Future<void> resetPassword(String accountId, String newPassword);

  /// Supprime le compte, ses courses et ses fichiers.
  Future<void> delete(String accountId);
}

/// Le serveur auquel l'app est reliée : comptes, synchronisation, fichiers.
/// Deux réalisations : le serveur ÉLAN en ligne (Supabase) et un serveur personnel (serveur ÉLAN).
/// Le reste de l'app ne connaît que cette interface.
abstract class Backend {
  BackendUser? get currentUser;

  /// Compte connecté, à chaque changement (connexion, déconnexion, session expirée).
  Stream<BackendUser?> get userChanges;

  RemoteGateway get gateway;

  Future<void> signIn(String email, String password);
  Future<void> signOut();

  /// Ferme les sessions du compte sur tous les autres appareils ; celui-ci reste connecté.
  Future<void> signOutOtherDevices();

  /// Vrai si le changement de mot de passe demande l'actuel.
  bool get needsCurrentPassword;
  Future<void> changePassword(String newPassword, {String? current});

  /// Serveur personnel tout neuf : le premier compte se crée depuis l'app, avec le code
  /// d'installation du serveur (fichier code-premier-compte.txt de son dossier de données).
  Future<bool> needsFirstAccount();
  Future<void> createFirstAccount(String email, String password, {required String setupCode});

  /// Préférences du compte gardées par le serveur, pour qu'elles suivent d'un appareil à l'autre
  /// (objectif annuel…). Null si le serveur n'en a pas, ou s'il est trop ancien pour les garder.
  Future<Map<String, dynamic>?> readPreferences();
  Future<void> writePreferences(Map<String, dynamic> preferences);

  /// Gestion des comptes, ou null si ce serveur ne la propose pas dans l'app.
  ServerAccounts? get accounts;

  Future<void> dispose();

  /// Ouvre la connexion au serveur choisi (la session enregistrée sur l'appareil est reprise).
  static Future<Backend> connect(ServerConfig server, SharedPreferences prefs) => switch (server.kind) {
    ServerKind.supabase => SupabaseBackend.connect(server),
    ServerKind.elan => ElanBackend.connect(server, prefs),
  };
}
