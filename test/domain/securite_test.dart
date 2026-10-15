import 'dart:convert';
import 'dart:io';

import 'package:app_course/app/widgets/file_open.dart';
import 'package:app_course/core/media/media_store.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/updates/update_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('clés de fichiers venues du serveur', () {
    test('format de l\'app accepté', () {
      expect(isSafeFileKey('c4f1e2a0-5b6d-4e7f-8a9b-0c1d2e3f4a5b/3f2a9c1e-1111-4abc-9def-123456789abc.jpg'), isTrue);
      expect(isSafeFileKey('user-1/3f2a9c1e_t.jpg'), isTrue, reason: 'miniature');
      expect(isSafeFileKey('abc123def456ghi/docs/3f2a9c1e.pdf'), isTrue, reason: 'serveur personnel');
      expect(isSafeFileKey('user-1/photo.heic'), isTrue);
    });

    test('chemins piégés et types exécutables refusés', () {
      for (final key in [
        '../../shared_prefs/FlutterSharedPreferences.xml',
        'user-1/../../evil.jpg',
        'user-1/docs/../../x.pdf',
        '/etc/passwd.jpg',
        r'C:\Users\x\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\x.jpg',
        r'user-1\..\..\x.jpg',
        'user-1/facture.pdf.exe',
        'user-1/script.bat',
        'user-1/page.html',
        'user-1/x.jpg/../y.jpg',
        'user-1/sous/dossier/x.jpg',
        'user-1/.jpg',
        'x.jpg',
        '',
      ]) {
        expect(isSafeFileKey(key), isFalse, reason: key);
      }
    });

    test('le stockage local refuse de sortir de son dossier', () async {
      final root = Directory.systemTemp.createTempSync('elan_securite');
      addTearDown(() => root.deleteSync(recursive: true));
      final store = MediaStore(Directory('${root.path}/media'), 'user-1');

      expect(store.fileFor('user-1/abc.jpg').path, startsWith(store.root.path));
      expect(() => store.fileFor('../evil.jpg'), throwsA(isA<UnsafeFileKey>()));
      expect(() => store.fileFor('user-1/x.exe'), throwsA(isA<UnsafeFileKey>()));
      expect(() => store.writeDownloaded('../../evil.jpg', [1, 2, 3]), throwsA(isA<UnsafeFileKey>()));
      expect(File('${root.path}/evil.jpg').existsSync(), isFalse);

      // Supprimer une clé piégée ne touche à rien.
      final outside = File('${root.path}/a-garder.jpg')..writeAsStringSync('x');
      await store.deleteLocal('../a-garder.jpg');
      expect(outside.existsSync(), isTrue);
    });

    test('un type de fichier inconnu à l\'import devient une extension sans danger', () async {
      final root = Directory.systemTemp.createTempSync('elan_securite');
      addTearDown(() => root.deleteSync(recursive: true));
      final store = MediaStore(Directory('${root.path}/media'), 'user-1');
      final source = File('${root.path}/note.exe')..writeAsBytesSync(utf8.encode('pas une image'));
      final key = await store.importDocument(source);
      expect(key, endsWith('.pdf'));
      expect(isSafeFileKey(key!), isTrue);
    });
  });

  group('justificatifs : nom et nature du fichier', () {
    CourseDocument doc(String key, String name) =>
        CourseDocument(key: key, name: name, sizeBytes: 10, addedAt: DateTime.utc(2026));

    test('l\'extension vient de la clé, pas du nom affiché', () {
      final piege = doc('user-1/docs/abc.pdf', 'facture.pdf.exe');
      expect(piege.extension, 'pdf');
      expect(piege.safeName, 'facture.pdf.pdf');
      expect(doc('user-1/docs/abc.jpg', 'Reçu de don.jpg').safeName, 'Reçu de don.jpg');
      expect(doc('user-1/docs/abc.pdf', r'..\..\x:y*z.pdf').safeName, '.. .. x y z.pdf');
      expect(doc('user-1/docs/abc.pdf', '').safeName, 'justificatif.pdf');
    });

    test('clé altérée : aucune extension, rien ne s\'ouvre', () async {
      final piege = doc('../../x.exe', 'facture.exe');
      expect(piege.extension, isEmpty);
      expect(piege.safeName, 'facture.bin');
      final file = File('${Directory.systemTemp.createTempSync('elan_securite').path}/x');
      await expectLater(openLocalFile(file, displayName: piege.safeName), throwsArgumentError);
      await expectLater(openLocalFile(file, displayName: 'facture.pdf.exe'), throwsArgumentError);
      await expectLater(openLocalFile(file, displayName: 'sans-extension'), throwsArgumentError);
    });
  });

  group('lien de mise à jour', () {
    test('seulement des adresses https de GitHub', () {
      expect(isGitHubUrl('https://github.com/Drekstord/elan/releases/tag/v2.14.0'), isTrue);
      expect(isGitHubUrl('https://objects.githubusercontent.com/github-production-release-asset/x'), isTrue);
      expect(isGitHubUrl('http://github.com/Drekstord/elan'), isFalse);
      expect(isGitHubUrl('https://github.com.exemple.fr/elan.apk'), isFalse);
      expect(isGitHubUrl('https://exemple.fr/github.com/elan.apk'), isFalse);
      expect(isGitHubUrl('javascript:alert(1)'), isFalse);
    });

    Future<AvailableUpdate?> answer(Map<String, dynamic> json) => fetchUpdate(
      current: '2.13.0',
      assetSuffix: '.apk',
      client: MockClient((_) async => http.Response(jsonEncode(json), 200)),
    );

    test('réponse altérée : le lien de téléchargement retombe sur la page GitHub, ou rien', () async {
      final update = await answer({
        'tag_name': 'v2.14.0',
        'html_url': 'https://github.com/Drekstord/elan/releases/tag/v2.14.0',
        'assets': [
          {'name': 'ELAN-v2.14.0.apk', 'browser_download_url': 'https://pirate.exemple/ELAN.apk'},
        ],
      });
      expect(update!.downloadUrl, 'https://github.com/Drekstord/elan/releases/tag/v2.14.0');
      expect(
        await answer({'tag_name': 'v2.14.0', 'html_url': 'https://pirate.exemple/page', 'assets': const []}),
        isNull,
      );
    });
  });
}
