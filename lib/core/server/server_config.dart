import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Serveur Supabase utilisé par l'app : celui intégré à la compilation (par défaut)
/// ou un serveur personnel, par exemple auto-hébergé sur un NAS (dossier serveur du dépôt).
class ServerConfig {
  final String url;
  final String key;
  final bool builtIn;

  const ServerConfig({required this.url, required this.key, this.builtIn = false});

  /// Serveur fourni à la compilation (config/supabase.json), s'il y en a un.
  static ServerConfig? get compiled => AppConfig.isSupabaseConfigured
      ? const ServerConfig(url: AppConfig.supabaseUrl, key: AppConfig.supabaseKey, builtIn: true)
      : null;

  /// Adresse courte pour l'affichage : « 192.168.1.20:8000 ».
  String get displayAddress {
    final uri = Uri.parse(url);
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  /// Clé sous laquelle la session est gardée sur l'appareil : une par serveur personnel.
  /// Null pour le serveur intégré, qui garde la clé par défaut (sessions existantes conservées).
  String? get sessionStorageKey {
    if (builtIn) return null;
    final uri = Uri.parse(url);
    return 'sb-elan-${uri.host}-${uri.port}-auth-token';
  }

  @override
  bool operator ==(Object other) => other is ServerConfig && other.url == url && other.key == key;

  @override
  int get hashCode => Object.hash(url, key);
}

// ---------------------------------------------------------------------
// Saisie de l'adresse
// ---------------------------------------------------------------------

enum ServerAddressError { invalid, httpOnInternet }

/// Adresse saisie, nettoyée : espaces et « / » final retirés, http:// ajouté si absent.
String normalizeServerAddress(String input) {
  var s = input.trim();
  while (s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  if (s.isNotEmpty && !s.contains('://')) s = 'http://$s';
  return s;
}

/// http n'est accepté que sur un réseau privé (maison, VPN) : sur Internet, le mot de passe
/// circulerait en clair. Une adresse publique doit être en https.
ServerAddressError? validateServerAddress(String normalized) {
  final uri = Uri.tryParse(normalized);
  if (uri == null || !uri.hasAuthority || uri.host.isEmpty || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return ServerAddressError.invalid;
  }
  if (uri.path.isNotEmpty || uri.hasQuery || uri.hasFragment) return ServerAddressError.invalid;
  if (uri.isScheme('http') && !isPrivateHost(uri.host)) return ServerAddressError.httpOnInternet;
  return null;
}

/// Adresse joignable seulement depuis un réseau privé : réseau local, VPN, Tailscale.
bool isPrivateHost(String host) {
  final h = host.toLowerCase();
  if (!h.contains('.') && !h.contains(':')) return true; // « nas », « localhost »
  for (final suffix in const ['.local', '.lan', '.home', '.internal', '.home.arpa', '.ts.net']) {
    if (h.endsWith(suffix)) return true;
  }
  final ip = InternetAddress.tryParse(h.replaceAll(RegExp(r'^\[|\]$'), ''));
  if (ip == null) return false;
  final b = ip.rawAddress;
  if (ip.type == InternetAddressType.IPv4) {
    return b[0] == 10 ||
        b[0] == 127 ||
        (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
        (b[0] == 192 && b[1] == 168) ||
        (b[0] == 100 && b[1] >= 64 && b[1] <= 127) || // VPN de type Tailscale (CGNAT)
        (b[0] == 169 && b[1] == 254);
  }
  return ip.isLoopback || ip.isLinkLocal || (b[0] & 0xfe) == 0xfc; // fc00::/7 : adresses privées
}

/// Clé saisie, nettoyée (retours à la ligne et espaces d'un copier-coller retirés).
String normalizeServerKey(String input) => input.replaceAll(RegExp(r'\s'), '');

bool isPlausibleServerKey(String key) => key.length > 20;

// ---------------------------------------------------------------------
// Vérification avant d'enregistrer
// ---------------------------------------------------------------------

enum ServerCheck {
  ok,

  /// Le serveur répond mais refuse la clé.
  wrongKey,

  /// Serveur joint, mais la table des courses manque (migrations non appliquées).
  notReady,

  /// Quelque chose répond, mais ce n'est pas un serveur Supabase.
  notSupabase,

  /// Rien ne répond (adresse, VPN, serveur arrêté).
  unreachable,
}

/// Interroge le serveur comme le fera l'app : comptes (auth) puis table des courses.
Future<ServerCheck> checkServer(
  ServerConfig server, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final c = client ?? http.Client();
  // Clé seule, comme l'app avant connexion.
  final headers = {'apikey': server.key};
  try {
    final health = await c.get(Uri.parse('${server.url}/auth/v1/health'), headers: headers).timeout(timeout);
    if (health.statusCode == 401 || health.statusCode == 403) return ServerCheck.wrongKey;
    if (health.statusCode != 200) return ServerCheck.notSupabase;

    final table = await c.get(Uri.parse('${server.url}/rest/v1/courses?select=id&limit=0'), headers: headers).timeout(timeout);
    if (table.statusCode == 401 || table.statusCode == 403) return ServerCheck.wrongKey;
    if (table.statusCode == 404) return ServerCheck.notReady;
    return table.statusCode == 200 ? ServerCheck.ok : ServerCheck.notSupabase;
  } on TimeoutException {
    return ServerCheck.unreachable;
  } on SocketException {
    return ServerCheck.unreachable;
  } on http.ClientException {
    return ServerCheck.unreachable;
  } on HandshakeException {
    return ServerCheck.unreachable;
  } on FormatException {
    return ServerCheck.notSupabase;
  } finally {
    if (client == null) c.close();
  }
}

// ---------------------------------------------------------------------
// Choix enregistré sur l'appareil
// ---------------------------------------------------------------------

class ServerStore {
  static const _url = 'server.url';
  static const _key = 'server.key';

  final SharedPreferences prefs;

  const ServerStore(this.prefs);

  /// Serveur personnel enregistré, ou null (serveur intégré).
  ServerConfig? get custom {
    final url = prefs.getString(_url);
    final key = prefs.getString(_key);
    return url == null || key == null ? null : ServerConfig(url: url, key: key);
  }

  /// Serveur à utiliser : le personnel s'il y en a un, sinon l'intégré, sinon aucun.
  ServerConfig? get active => custom ?? ServerConfig.compiled;

  Future<void> save(ServerConfig? custom) async {
    if (custom == null) {
      await prefs.remove(_url);
      await prefs.remove(_key);
    } else {
      await prefs.setString(_url, custom.url);
      await prefs.setString(_key, custom.key);
    }
  }
}

/// Serveur en cours et moyen d'en changer (fourni par la racine de l'app, voir app/server_root.dart).
class ServerChoice {
  final ServerConfig current;
  final ServerConfig? builtIn;
  final Future<void> Function(ServerConfig? custom) switchTo;

  const ServerChoice({required this.current, required this.builtIn, required this.switchTo});
}

/// Null quand l'app tourne sans racine serveur (tests d'écrans).
final serverChoiceProvider = Provider<ServerChoice?>((ref) => null);
