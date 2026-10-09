import 'dart:async';
import 'dart:io';

import 'package:app_course/core/server/server_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.cle.publique';
const _server = ServerConfig(url: 'http://192.168.1.20:8000', key: _key);

/// Faux serveur : réponse de /auth/v1/health puis de /rest/v1/courses.
MockClient _respond(int health, [int table = 200]) => MockClient((request) async {
  expect(request.headers['apikey'], _key);
  return request.url.path.startsWith('/auth/v1/health') ? http.Response('{}', health) : http.Response('[]', table);
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
        'https://abcd.supabase.co',
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
      for (final bad in ['', 'http://', 'ftp://nas.local', 'http://nas.local/rest/v1', 'http://nas.local?x=1']) {
        expect(validateServerAddress(bad), ServerAddressError.invalid, reason: bad);
      }
    });

    test('clé : retours à la ligne et espaces du copier-coller retirés', () {
      expect(normalizeServerKey(' eyJ.abc\n.def \r\n'), 'eyJ.abc.def');
      expect(isPlausibleServerKey('court'), isFalse);
      expect(isPlausibleServerKey(_key), isTrue);
    });

    test('affichage et session propres à chaque serveur personnel', () {
      expect(_server.displayAddress, '192.168.1.20:8000');
      expect(const ServerConfig(url: 'https://elan.exemple.fr', key: _key).displayAddress, 'elan.exemple.fr');
      expect(_server.sessionStorageKey, 'sb-elan-192.168.1.20-8000-auth-token');
      expect(const ServerConfig(url: 'https://x.supabase.co', key: _key, builtIn: true).sessionStorageKey, isNull);
    });
  });

  group('vérification du serveur', () {
    test('serveur ÉLAN prêt', () async {
      expect(await checkServer(_server, client: _respond(200)), ServerCheck.ok);
    });

    test('clé refusée', () async {
      expect(await checkServer(_server, client: _respond(401)), ServerCheck.wrongKey);
    });

    test('base pas encore créée (migrations)', () async {
      expect(await checkServer(_server, client: _respond(200, 404)), ServerCheck.notReady);
    });

    test("autre chose qu'un serveur Supabase", () async {
      expect(await checkServer(_server, client: _respond(404)), ServerCheck.notSupabase);
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

  group('choix enregistré', () {
    test('serveur personnel gardé, puis retour au serveur intégré', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ServerStore(await SharedPreferences.getInstance());
      expect(store.custom, isNull);

      await store.save(_server);
      expect(store.custom, _server);
      expect(store.active, _server);

      await store.save(null);
      expect(store.custom, isNull);
      // Sans config/supabase.json à la compilation (tests), aucun serveur intégré.
      expect(store.active, isNull);
    });
  });
}
