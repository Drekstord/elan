import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Nature du serveur : elle décide de la façon de lui parler (voir core/backend).
enum ServerKind {
  /// Serveur en ligne (Supabase) : intégré à la compilation, ou saisi dans l'app (adresse et
  /// clé publique du projet).
  supabase,

  /// Serveur personnel : le « serveur ÉLAN » du dossier serveur, par exemple sur un NAS.
  elan,
}

/// Serveur utilisé par l'app : un serveur en ligne (Supabase : adresse et clé publique),
/// intégré à la compilation ou saisi dans l'app, ou un serveur personnel, désigné par sa seule adresse.
class ServerConfig {
  final String url;

  /// Clé publique du serveur en ligne ; vide pour un serveur personnel.
  final String key;
  final ServerKind kind;

  /// Serveur personnel.
  const ServerConfig.personal(this.url) : key = '', kind = ServerKind.elan;

  /// Serveur en ligne (projet Supabase) : adresse et clé publique.
  const ServerConfig.online({required this.url, required this.key}) : kind = ServerKind.supabase;

  /// Serveur fourni à la compilation (config/supabase.json), s'il y en a un. L'app publiée n'en a
  /// pas : chacun saisit le sien.
  static ServerConfig? get compiled => AppConfig.isSupabaseConfigured
      ? const ServerConfig.online(url: AppConfig.supabaseUrl, key: AppConfig.supabaseKey)
      : null;

  /// Serveur en ligne factice, pour les tests d'écrans.
  const ServerConfig.onlineForTest(this.url) : key = 'cle-publique-de-test', kind = ServerKind.supabase;

  /// Serveur en ligne (Supabase), intégré ou saisi.
  bool get isOnline => kind == ServerKind.supabase;

  /// Adresse courte pour l'affichage : « 192.168.1.20:8000 ».
  String get displayAddress {
    final uri = Uri.parse(url);
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  /// Clé sous laquelle la session d'un serveur personnel est gardée sur l'appareil : une par serveur.
  String get sessionStorageKey {
    final uri = Uri.parse(url);
    return 'elan-session-${uri.host}-${uri.port}';
  }

  @override
  bool operator ==(Object other) => other is ServerConfig && other.url == url && other.key == key && other.kind == kind;

  @override
  int get hashCode => Object.hash(url, key, kind);
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

enum OnlineKeyError { invalid, secret }

/// Clé d'un projet Supabase : seule la clé publique est acceptée. La clé secrète (« sb_secret_ »,
/// ou l'ancienne « service_role ») contourne toutes les règles d'accès : elle ne doit jamais
/// être enregistrée dans une app.
OnlineKeyError? validateOnlineKey(String input) {
  final key = input.trim();
  if (key.startsWith('sb_secret_')) return OnlineKeyError.secret;
  if (key.startsWith('sb_publishable_')) return key.length > 20 ? null : OnlineKeyError.invalid;
  final parts = key.split('.');
  if (parts.length != 3) return OnlineKeyError.invalid;
  try {
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final role = payload is Map ? payload['role'] : null;
    if (role == 'service_role') return OnlineKeyError.secret;
    return role == 'anon' ? null : OnlineKeyError.invalid;
  } on FormatException {
    return OnlineKeyError.invalid;
  }
}

// ---------------------------------------------------------------------
// Vérification avant d'enregistrer
// ---------------------------------------------------------------------

/// Ce qu'un serveur ÉLAN dit de lui (GET /api/elan/etat).
class ElanStatus {
  /// Version du protocole entre l'app et le serveur.
  final int version;

  /// Serveur tout neuf : le premier compte, propriétaire, se crée depuis l'app.
  final bool needsFirstAccount;

  const ElanStatus({required this.version, required this.needsFirstAccount});
}

/// Version du protocole que cette app sait parler.
const elanProtocolVersion = 1;

/// État du serveur ÉLAN à cette adresse ; null si ce qui répond n'en est pas un.
/// Lève une exception réseau si rien ne répond.
Future<ElanStatus?> fetchElanStatus(
  String url, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final c = client ?? http.Client();
  try {
    final response = await c.get(Uri.parse('$url/api/elan/etat')).timeout(timeout);
    if (response.statusCode != 200) return null;
    final Object? data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is! Map || data['serveur'] != 'elan') return null;
    return ElanStatus(
      version: (data['version'] as num?)?.toInt() ?? 0,
      needsFirstAccount: data['premierCompte'] == true,
    );
  } on FormatException {
    return null;
  } finally {
    if (client == null) c.close();
  }
}

enum ServerCheck {
  ok,

  /// Serveur ÉLAN plus récent que cette app : il faut mettre l'app à jour.
  tooRecent,

  /// Quelque chose répond, mais ce n'est pas un serveur ÉLAN.
  notElan,

  /// Rien ne répond (adresse, VPN, serveur arrêté).
  unreachable,

  /// Serveur en ligne : le projet répond, mais refuse la clé.
  badKey,
}

/// Vérifie qu'un serveur ÉLAN répond à cette adresse.
Future<ServerCheck> checkServer(
  ServerConfig server, {
  http.Client? client,
  Duration timeout = const Duration(seconds: 8),
}) async {
  if (server.isOnline) return _checkOnline(server, client: client, timeout: timeout);
  try {
    final status = await fetchElanStatus(server.url, client: client, timeout: timeout);
    if (status == null) return ServerCheck.notElan;
    return status.version > elanProtocolVersion ? ServerCheck.tooRecent : ServerCheck.ok;
  } on TimeoutException {
    return ServerCheck.unreachable;
  } on SocketException {
    return ServerCheck.unreachable;
  } on http.ClientException {
    return ServerCheck.unreachable;
  } on HandshakeException {
    return ServerCheck.unreachable;
  }
}

/// Projet Supabase : la page publique des réglages de connexion répond avec la clé publique.
Future<ServerCheck> _checkOnline(ServerConfig server, {http.Client? client, required Duration timeout}) async {
  final c = client ?? http.Client();
  try {
    final response = await c
        .get(Uri.parse('${server.url}/auth/v1/settings'), headers: {'apikey': server.key})
        .timeout(timeout);
    if (response.statusCode == 401 || response.statusCode == 403) return ServerCheck.badKey;
    if (response.statusCode != 200) return ServerCheck.notElan;
    final Object? data = jsonDecode(utf8.decode(response.bodyBytes));
    return data is Map && data.containsKey('external') ? ServerCheck.ok : ServerCheck.notElan;
  } on FormatException {
    return ServerCheck.notElan;
  } on TimeoutException {
    return ServerCheck.unreachable;
  } on SocketException {
    return ServerCheck.unreachable;
  } on http.ClientException {
    return ServerCheck.unreachable;
  } on HandshakeException {
    return ServerCheck.unreachable;
  } finally {
    if (client == null) c.close();
  }
}

// ---------------------------------------------------------------------
// Choix enregistré sur l'appareil
// ---------------------------------------------------------------------

class ServerStore {
  static const _url = 'server.url';
  static const _kind = 'server.kind';
  static const _key = 'server.key';

  final SharedPreferences prefs;

  const ServerStore(this.prefs);

  /// Serveur choisi dans l'app (personnel ou en ligne), ou null (serveur intégré).
  ServerConfig? get custom {
    final url = prefs.getString(_url);
    if (url == null) return null;
    if (prefs.getString(_kind) != ServerKind.supabase.name) return ServerConfig.personal(url);
    final key = prefs.getString(_key) ?? '';
    return validateOnlineKey(key) == null ? ServerConfig.online(url: url, key: key) : null;
  }

  /// Serveur à utiliser : celui choisi dans l'app s'il y en a un, sinon l'intégré, sinon aucun.
  ServerConfig? get active => custom ?? ServerConfig.compiled;

  Future<void> save(ServerConfig? custom) async {
    if (custom == null) {
      await prefs.remove(_url);
      await prefs.remove(_kind);
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_url, custom.url);
    await prefs.setString(_kind, custom.kind.name);
    if (custom.isOnline) {
      await prefs.setString(_key, custom.key);
    } else {
      await prefs.remove(_key);
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
