import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nouvelle version d'ÉLAN publiée sur GitHub (dépôt public, sans compte) : au lancement, une
/// fois par jour au plus, l'app compare la dernière version publiée à la sienne.
const latestReleaseApi = 'https://api.github.com/repos/Drekstord/elan/releases/latest';

class AvailableUpdate {
  final String version;

  /// Page de la version (notes, tous les fichiers).
  final String pageUrl;

  /// Fichier pour cet appareil (APK ou installateur Windows), sinon la page.
  final String downloadUrl;

  const AvailableUpdate({required this.version, required this.pageUrl, required this.downloadUrl});
}

/// Compare deux numéros « 2.8.10 » / « v2.9.0 » : négatif si [a] est plus ancien.
int compareVersions(String a, String b) {
  List<int> parts(String v) =>
      v.replaceFirst(RegExp('^v'), '').split('+').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d;
  }
  return 0;
}

/// Dernière version publiée si elle est plus récente que [current] ; null sinon, ou sans réseau.
/// [assetSuffix] choisit le fichier de cet appareil : « .apk », « .exe ».
Future<AvailableUpdate?> fetchUpdate({
  required String current,
  String? assetSuffix,
  http.Client? client,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final c = client ?? http.Client();
  try {
    final response = await c
        .get(Uri.parse(latestReleaseApi), headers: {'Accept': 'application/vnd.github+json'})
        .timeout(timeout);
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = json['tag_name'] as String?;
    final page = json['html_url'] as String?;
    if (tag == null || page == null || compareVersions(tag, current) <= 0) return null;
    final assets = (json['assets'] as List? ?? const []).cast<Map<String, dynamic>>();
    final asset = assetSuffix == null
        ? null
        : assets.where((a) => (a['name'] as String? ?? '').endsWith(assetSuffix)).firstOrNull;
    // Seulement des liens https vers GitHub : une réponse altérée n'enverrait pas ailleurs.
    final download = asset?['browser_download_url'] as String?;
    if (!isGitHubUrl(page)) return null;
    return AvailableUpdate(
      version: tag.replaceFirst(RegExp('^v'), ''),
      pageUrl: page,
      downloadUrl: download != null && isGitHubUrl(download) ? download : page,
    );
  } catch (_) {
    return null; // pas de réseau, réponse inattendue : on réessaiera plus tard
  } finally {
    if (client == null) c.close();
  }
}

/// Adresse https de GitHub (pages et fichiers des versions).
bool isGitHubUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.isScheme('https') &&
      (uri.host == 'github.com' || uri.host.endsWith('.githubusercontent.com'));
}

String? get _assetSuffix {
  if (kIsWeb) return null;
  if (Platform.isAndroid) return '.apk';
  if (Platform.isWindows) return '.exe';
  return null;
}

/// Version installée (« 2.9.0 »).
final appVersionProvider = FutureProvider<String>((ref) async => (await PackageInfo.fromPlatform()).version);

class UpdateController extends Notifier<AvailableUpdate?> {
  static const _lastCheck = 'update.lastCheck';
  static const _dismissed = 'update.dismissed';
  static const interval = Duration(days: 1);

  @override
  AvailableUpdate? build() => null;

  /// Au lancement : au plus une fois par jour, sauf [force] (bouton des Réglages).
  /// Une version que l'utilisateur a écartée n'est plus proposée d'elle-même.
  Future<AvailableUpdate?> check({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final last = DateTime.tryParse(prefs.getString(_lastCheck) ?? '');
    if (!force && last != null && DateTime.now().difference(last) < interval) return null;
    final update = await fetchUpdate(current: await ref.read(appVersionProvider.future), assetSuffix: _assetSuffix);
    await prefs.setString(_lastCheck, DateTime.now().toIso8601String());
    if (update != null && !force && prefs.getString(_dismissed) == update.version) return null;
    if (ref.mounted) state = update;
    return update;
  }

  /// « Plus tard » : cette version ne sera plus proposée au lancement.
  Future<void> dismiss() async {
    final version = state?.version;
    if (version != null) await (await SharedPreferences.getInstance()).setString(_dismissed, version);
    state = null;
  }
}

final updateProvider = NotifierProvider<UpdateController, AvailableUpdate?>(UpdateController.new);
