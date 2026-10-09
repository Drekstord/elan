// Le vrai code de synchronisation de l'app contre un vrai serveur auto-hébergé (dossier serveur).
// Lancé par GitHub (workflow « Serveur auto-hébergé ») une fois le serveur démarré :
//   ELAN_SERVEUR_URL=... ELAN_SERVEUR_CLE=... ELAN_EMAIL=... ELAN_MOT_DE_PASSE=... \
//   flutter test --tags serveur --run-skipped test/server
@Tags(['serveur'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:app_course/core/server/server_config.dart';
import 'package:app_course/core/sync/remote_gateway.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _env(String name) => Platform.environment[name] ?? (throw StateError('$name manquant'));

void main() {
  late ServerConfig server;
  late SupabaseClient client;
  late SupabaseGateway gateway;
  late String uid;

  setUpAll(() async {
    server = ServerConfig(url: _env('ELAN_SERVEUR_URL'), key: _env('ELAN_SERVEUR_CLE'));
    client = SupabaseClient(server.url, server.key, authOptions: const AuthClientOptions(autoRefreshToken: false));
    await client.auth.signInWithPassword(email: _env('ELAN_EMAIL'), password: _env('ELAN_MOT_DE_PASSE'));
    uid = client.auth.currentUser!.id;
    gateway = SupabaseGateway(client);
  });

  tearDownAll(() => client.dispose());

  test("vérification de l'écran Serveur : prêt, puis mauvaise clé", () async {
    expect(await checkServer(server), ServerCheck.ok);
    expect(await checkServer(ServerConfig(url: server.url, key: 'x' * 40)), ServerCheck.wrongKey);
  });

  test('course avec justificatif : envoi, lecture, fichier', () async {
    final pdf = Uint8List.fromList('%PDF-1.4 facture de test'.codeUnits);
    final key = '$uid/docs/facture-ci.pdf';
    final course = Course(
      id: 'ci-restos',
      title: 'La Course du Cœur',
      raceDate: calendarDate(2026, 9, 20),
      distanceM: 10000,
      durationS: 3150,
      isCharity: true,
      associationName: 'Les Restos du Cœur',
      associationCause: CauseType.precarite,
      registrationDonationCents: 1500,
      documents: [
        CourseDocument(
          key: key,
          name: 'facture.pdf',
          sizeBytes: pdf.length,
          addedAt: DateTime.utc(2026, 9, 2),
          kind: DocumentKind.invoice,
        ),
      ],
    );

    await gateway.upsertCourses([course]);
    final pulled = await gateway.pullSince(null);
    final back = pulled.singleWhere((r) => r.course.id == 'ci-restos').course;
    expect(back.title, 'La Course du Cœur');
    expect(back.associationName, 'Les Restos du Cœur');
    expect(back.documents.single.kind, DocumentKind.invoice);

    // Curseur de synchro : rien de neuf après la dernière ligne reçue.
    expect(await gateway.pullSince(pulled.last.serverUpdatedAt), isEmpty);

    final file = File('${Directory.systemTemp.createTempSync('elan_ci').path}/facture.pdf')..writeAsBytesSync(pdf);
    await gateway.uploadPhoto(key, file);
    expect(await gateway.downloadPhoto(key), pdf);
  });

  test("dossier d'un autre compte refusé (règles d'accès)", () async {
    final file = File('${Directory.systemTemp.createTempSync('elan_ci').path}/x.jpg')..writeAsBytesSync([1, 2, 3]);
    await expectLater(gateway.uploadPhoto('00000000-0000-0000-0000-000000000000/x.jpg', file), throwsA(isA<StorageException>()));
  });
}
