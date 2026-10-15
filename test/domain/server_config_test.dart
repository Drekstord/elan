import 'dart:async';
import 'dart:io';

import 'package:app_course/core/server/server_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = ServerConfig.personal('http://192.168.1.20:8000');

// Clés de test (jamais de vraies clés ici : publier.sh bloquerait la publication).
const _publishable = 'sb_publishable_cle-de-test-publique';
const _anonJwt = 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYW5vbiJ9.signature';
const _serviceJwt = 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.signature';
const _online = ServerConfig.online(url: 'https://projet-test.exemple.fr', key: _publishable);

/// Faux serveur : réponse de GET /api/elan/etat.
MockClient _respond(int status, String body) => MockClient((request) async {
  expect(request.url.path, '/api/elan/etat');
  return http.Response(body, status, headers: {'content-type': 'application/json; charset=utf-8'});
});

void main() {
  group('adresse saisie', () {
    test('nettoyée : espaces, / final, http:// ajouté', () {
      expect(normalizeServerAddress('  http://nas.local:8000/ '), 'http://nas.local:8000');
      expect(normalizeServerAddress('192.168.1.20:8000'), 'http://192.168.1.20:8000');
      expect(normalizeServerAddress('https://elan.exemple.fr//'), 'https://elan.exemple.fr');
    });

    test('http accepté sur le réseau local ou le VPN, https partout', () {
      for (final ok in [
        'http://192.168.1.20:8000',
        'http://10.8.0.1:8000',
        'http://172.20.0.5',
        'http://100.101.102.103:8000', // Tailscale
        'http://nas:8000',
        'http://nas.local:8000',
        'http://nas.home.arpa',
        'http://monnas.tail1234.ts.net:8000',
        'http://localhost:8000',
        'http://[fd12::1]:8000',
        'https://elan.exemple.fr',
      ]) {
        expect(validateServerAddress(ok), isNull, reason: ok);
      }
    });

    test('http refusé sur Internet (mot de passe en clair)', () {
      for (final bad in ['http://elan.exemple.fr', 'http://8.8.8.8:8000', 'http://172.32.0.1']) {
        expect(validateServerAddress(bad), ServerAddressError.httpOnInternet, reason: bad);
      }
    });

    test('adresses invalides', () {
      for (final bad in ['', 'http://', 'ftp://nas.local', 'http://nas.local/api', 'http://nas.local?x=1']) {
        expect(validateServerAddress(bad), ServerAddressError.invalid, reason: bad);
      }
    });

    test('serveur personnel : adresse seule, session propre à chaque serveur', () {
      expect(_server.kind, ServerKind.elan);
      expect(_server.isOnline, isFalse);
      expect(_server.key, isEmpty);
      expect(_server.displayAddress, '192.168.1.20:8000');
      expect(const ServerConfig.personal('https://elan.exemple.fr').displayAddress, 'elan.exemple.fr');
      expect(_server.sessionStorageKey, 'elan-session-192.168.1.20-8000');
      expect(
        const ServerConfig.personal('http://192.168.1.21:8000').sessionStorageKey,
        isNot(_server.sessionStorageKey),
      );
    });
  });

  group('vérification du serveur', () {
    test('serveur ÉLAN prêt, avec ou sans premier compte à créer', () async {
      final neuf = _respond(200, '{"serveur":"elan","version":1,"premierCompte":true}');
      expect(await checkServer(_server, client: neuf), ServerCheck.ok);
      expect((await fetchElanStatus(_server.url, client: neuf))!.needsFirstAccount, isTrue);

      final installe = _respond(200, '{"serveur":"elan","version":1,"premierCompte":false}');
      expect((await fetchElanStatus(_server.url, client: installe))!.needsFirstAccount, isFalse);
    });

    test("serveur plus récent que l'app : mise à jour de l'app demandée", () async {
      final futur = _respond(200, '{"serveur":"elan","version":${elanProtocolVersion + 1},"premierCompte":false}');
      expect(await checkServer(_server, client: futur), ServerCheck.tooRecent);
    });

    test("autre chose qu'un serveur ÉLAN : page web, autre service, mauvais port", () async {
      expect(await checkServer(_server, client: _respond(404, 'Not found')), ServerCheck.notElan);
      expect(await checkServer(_server, client: _respond(200, '<html>Mon NAS</html>')), ServerCheck.notElan);
      expect(await checkServer(_server, client: _respond(200, '{"serveur":"autre"}')), ServerCheck.notElan);
      expect(await checkServer(_server, client: _respond(200, '[1,2]')), ServerCheck.notElan);
    });

    test('injoignable : réseau, délai dépassé', () async {
      final down = MockClient((_) => throw const SocketException('Connection refused'));
      expect(await checkServer(_server, client: down), ServerCheck.unreachable);
      final slow = MockClient((_) => Completer<http.Response>().future);
      expect(
        await checkServer(_server, client: slow, timeout: const Duration(milliseconds: 10)),
        ServerCheck.unreachable,
      );
    });
  });

  group('serveur en ligne (Supabase) saisi dans l\'app', () {
    test('seule la clé publique est acceptée, jamais la clé secrète', () {
      expect(validateOnlineKey(_publishable), isNull);
      expect(validateOnlineKey(' $_anonJwt '), isNull);
      expect(validateOnlineKey('sb_secret_cle-de-test'), OnlineKeyError.secret);
      expect(validateOnlineKey(_serviceJwt), OnlineKeyError.secret);
      expect(validateOnlineKey(''), OnlineKeyError.invalid);
      expect(validateOnlineKey('sb_publishable_'), OnlineKeyError.invalid);
      expect(validateOnlineKey('n-importe-quoi'), OnlineKeyError.invalid);
      expect(validateOnlineKey('a.b.c'), OnlineKeyError.invalid);
    });

    test('vérification : le projet répond avec la clé, la refuse, ou n\'est pas Supabase', () async {
      MockClient answer(int status, String body) => MockClient((request) async {
        expect(request.url.toString(), 'https://projet-test.exemple.fr/auth/v1/settings');
        expect(request.headers['apikey'], _publishable);
        return http.Response(body, status);
      });
      expect(await checkServer(_online, client: answer(200, '{"external":{"email":true}}')), ServerCheck.ok);
      expect(await checkServer(_online, client: answer(401, '{"message":"Invalid API key"}')), ServerCheck.badKey);
      expect(await checkServer(_online, client: answer(404, 'introuvable')), ServerCheck.notElan);
      expect(await checkServer(_online, client: answer(200, '<html>')), ServerCheck.notElan);
      final offline = MockClient((_) => throw const SocketException('hors ligne'));
      expect(await checkServer(_online, client: offline), ServerCheck.unreachable);
    });

    test('gardé sur l\'appareil avec sa clé ; une clé secrète enregistrée n\'est jamais relue', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = ServerStore(prefs);
      await store.save(_online);
      expect(store.custom, _online);
      expect(store.custom!.isOnline, isTrue);

      // Retour à un serveur personnel : la clé est effacée.
      await store.save(_server);
      expect(store.custom, _server);
      expect(prefs.getString('server.key'), isNull);

      await prefs.setString('server.url', 'https://projet-test.exemple.fr');
      await prefs.setString('server.kind', 'supabase');
      await prefs.setString('server.key', _serviceJwt);
      expect(store.custom, isNull);
    });
  });

  group('choix enregistré', () {
    test('serveur personnel gardé, puis retour au serveur intégré', () async {
      // Une clé restée d'un ancien serveur personnel (versions 2.8) est effacée au passage.
      SharedPreferences.setMockInitialValues({'server.key': 'ancienne-cle'});
      final prefs = await SharedPreferences.getInstance();
      final store = ServerStore(prefs);
      expect(store.custom, isNull);

      await store.save(_server);
      expect(store.custom, _server);
      expect(store.active, _server);
      expect(prefs.getString('server.key'), isNull);

      await store.save(null);
      expect(store.custom, isNull);
      // Sans config/supabase.json à la compilation (tests), aucun serveur intégré.
      expect(store.active, isNull);
    });
  });
}
