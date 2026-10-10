// Le vrai code de l'app (connexion, synchro, fichiers, comptes) contre un vrai serveur ÉLAN
// (dossier serveur). Lancé par GitHub (workflow « Serveur ÉLAN ») une fois le serveur démarré
// et son premier compte créé :
//   ELAN_SERVEUR_URL=... ELAN_EMAIL=... ELAN_MOT_DE_PASSE=... \
//   flutter test --tags serveur --run-skipped test/server
@Tags(['serveur'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:app_course/core/backend/backend.dart';
import 'package:app_course/core/backend/elan_backend.dart';
import 'package:app_course/core/server/server_config.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:flutter_test/flutter_test.dart';

String _env(String name) => Platform.environment[name] ?? (throw StateError('$name manquant'));

Matcher _fails(AuthFailure reason) => throwsA(isA<AuthError>().having((e) => e.reason, 'raison', reason));

File _tempFile(String name, List<int> bytes) =>
    File('${Directory.systemTemp.createTempSync('elan_ci').path}/$name')..writeAsBytesSync(bytes);

void main() {
  late String url;
  late String email;
  late String password;
  late ElanBackend owner;
  const relative = 'proche-app@exemple.fr';
  const relativePassword = 'mot-de-passe-du-proche';

  setUpAll(() async {
    url = _env('ELAN_SERVEUR_URL');
    email = _env('ELAN_EMAIL');
    password = _env('ELAN_MOT_DE_PASSE');
    owner = ElanBackend(url);
    await owner.signIn(email, password);
  });

  tearDownAll(() => owner.dispose());

  test('écran Serveur : serveur reconnu, premier compte déjà créé', () async {
    expect(await checkServer(ServerConfig.personal(url)), ServerCheck.ok);
    expect(await owner.needsFirstAccount(), isFalse);
    // Une adresse qui répond sans être un serveur ÉLAN (ici, une autre route du même serveur).
    expect(await checkServer(ServerConfig.personal('$url/_')), isNot(ServerCheck.ok));
  });

  test('connexion : mauvais mot de passe refusé, propriétaire reconnu, pas de second « premier compte »', () async {
    final other = ElanBackend(url);
    addTearDown(other.dispose);
    await expectLater(other.signIn(email, 'mauvais-mot-de-passe'), _fails(AuthFailure.wrongCredentials));
    expect(other.currentUser, isNull);

    expect(owner.currentUser!.email, email);
    expect(owner.currentUser!.isOwner, isTrue);
    expect(owner.accounts, isNotNull);
    await expectLater(other.createFirstAccount('intrus@exemple.fr', 'mot-de-passe-intrus'), throwsA(isA<AuthError>()));
    expect(other.currentUser, isNull);
  });

  test('synchro : envoi, lecture, repère, la plus récente gagne', () async {
    final gateway = owner.gateway;
    final uid = owner.currentUser!.id;
    final course = Course(
      id: 'app-coeur',
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
          key: '$uid/docs/facture-app.pdf',
          name: 'facture.pdf',
          sizeBytes: 24,
          addedAt: DateTime.utc(2026, 9, 2),
          kind: DocumentKind.invoice,
        ),
      ],
      updatedAt: DateTime.utc(2026, 9, 21, 10),
    );

    await gateway.upsertCourses([course]);
    var pulled = await gateway.pullSince(null);
    final back = pulled.singleWhere((r) => r.course.id == 'app-coeur').course;
    expect(back.title, 'La Course du Cœur');
    expect(back.associationName, 'Les Restos du Cœur');
    expect(back.raceDate, calendarDate(2026, 9, 20));
    expect(back.documents.single.kind, DocumentKind.invoice);
    expect(back.updatedAt, DateTime.utc(2026, 9, 21, 10));

    // Repère de synchro : rien de neuf après la dernière ligne reçue.
    final cursor = pulled.last.serverUpdatedAt;
    expect(await gateway.pullSince(cursor), isEmpty);

    // Un autre appareil envoie une version plus ancienne : ignorée.
    await gateway.upsertCourses([course.copyWith(title: 'Version périmée', updatedAt: DateTime.utc(2026, 9, 21, 9))]);
    expect(await gateway.pullSince(cursor), isEmpty);

    // Une version plus récente : acceptée, et seule renvoyée depuis le repère.
    await gateway.upsertCourses([
      course.copyWith(title: 'La Course du Cœur 2026', updatedAt: DateTime.utc(2026, 9, 21, 11)),
    ]);
    pulled = await gateway.pullSince(cursor);
    expect(pulled.map((r) => r.course.title), ['La Course du Cœur 2026']);
    expect(pulled.single.serverUpdatedAt.isAfter(cursor), isTrue);

    // Envoi groupé au-delà d'un lot : tout arrive, dans l'ordre.
    await gateway.upsertCourses([
      for (var i = 0; i < 450; i++)
        Course(
          id: 'app-lot-${i.toString().padLeft(3, '0')}',
          title: 'Course $i',
          raceDate: calendarDate(2025, 1, 1),
          distanceM: 5000,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
    ]);
    final all = await gateway.pullSince(null);
    final lot = all.where((r) => r.course.id.startsWith('app-lot-')).toList();
    expect(lot, hasLength(450));
    expect(lot.first.course.id, 'app-lot-000');
    expect(lot.last.course.id, 'app-lot-449');
    for (var i = 1; i < all.length; i++) {
      expect(all[i].serverUpdatedAt.isAfter(all[i - 1].serverUpdatedAt), isTrue, reason: 'ordre strict ($i)');
    }
  });

  test('triathlon : disciplines et transitions conservées telles quelles par le serveur', () async {
    final triathlon = Course(
      id: 'app-triathlon',
      title: 'Triathlon de Démoville',
      raceDate: calendarDate(2026, 6, 14),
      type: CourseType.multisport,
      distanceM: 6700,
      durationS: 1680,
      multisport: Multisport(
        kind: MultisportKind.triathlon,
        format: 'XXS',
        legs: const [
          Leg(sport: Sport.swim, distanceM: 200, durationS: 420),
          Leg(sport: Sport.bike, distanceM: 5000, durationS: 780),
          Leg(sport: Sport.run, distanceM: 1500, durationS: 480),
        ],
        transitionsIncluded: true,
      ),
    );
    await owner.gateway.upsertCourses([triathlon]);
    final back = (await owner.gateway.pullSince(null)).singleWhere((r) => r.course.id == 'app-triathlon').course;
    expect(back.type, CourseType.multisport);
    expect(back.multisport, triathlon.multisport);
    expect(back.runDistanceM, 1500);
    expect(back.durationS, 1680);
  });

  test('fichiers : envoi, lecture, remplacement, suppression', () async {
    final gateway = owner.gateway;
    final key = '${owner.currentUser!.id}/docs/facture-app.pdf';
    final v1 = Uint8List.fromList('%PDF-1.4 facture de test'.codeUnits);
    final v2 = Uint8List.fromList('%PDF-1.4 facture remplacee, plus longue'.codeUnits);

    await gateway.uploadPhoto(key, _tempFile('facture.pdf', v1));
    expect(await gateway.downloadPhoto(key), v1);

    await gateway.uploadPhoto(key, _tempFile('facture.pdf', v2));
    expect(await gateway.downloadPhoto(key), v2);

    await gateway.deletePhotos([key, 'inconnu/absent.jpg']);
    await expectLater(gateway.downloadPhoto(key), throwsA(anything));
  });

  test('comptes : le propriétaire ajoute un proche, qui ne voit que ses données', () async {
    final accounts = owner.accounts!;
    await accounts.create(relative, relativePassword);
    await expectLater(accounts.create(relative, relativePassword), _fails(AuthFailure.emailTaken));
    await expectLater(accounts.create('autre@exemple.fr', 'court'), _fails(AuthFailure.weakPassword));

    final list = await accounts.list();
    expect(list.where((a) => a.isOwner).single.email, email);
    final account = list.singleWhere((a) => a.email == relative);
    expect(account.isOwner, isFalse);

    final proche = ElanBackend(url);
    addTearDown(proche.dispose);
    await proche.signIn(relative, relativePassword);
    expect(proche.currentUser!.isOwner, isFalse);
    expect(proche.accounts, isNull, reason: 'gestion des comptes réservée au propriétaire');

    // Cloisonnement : ni les courses ni les fichiers du propriétaire.
    expect(await proche.gateway.pullSince(null), isEmpty);
    final ownerKey = '${owner.currentUser!.id}/secret.jpg';
    await owner.gateway.uploadPhoto(ownerKey, _tempFile('secret.jpg', [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]));
    await expectLater(proche.gateway.downloadPhoto(ownerKey), throwsA(anything));
    // Même en reprenant le nom d'un fichier du propriétaire, le proche n'écrit que dans son espace.
    await proche.gateway.uploadPhoto(ownerKey, _tempFile('intrus.jpg', [0xFF, 0xD8, 0xFF, 0xE0, 9]));
    expect(await proche.gateway.downloadPhoto(ownerKey), [0xFF, 0xD8, 0xFF, 0xE0, 9]);
    expect(await owner.gateway.downloadPhoto(ownerKey), [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);

    // Ses propres données.
    await proche.gateway.upsertCourses([
      Course(
        id: 'proche-1',
        title: 'Trail des Monts Imaginaires',
        raceDate: calendarDate(2026, 6, 14),
        distanceM: 22500,
      ),
    ]);
    expect((await proche.gateway.pullSince(null)).single.course.title, 'Trail des Monts Imaginaires');
    expect((await owner.gateway.pullSince(null)).any((r) => r.course.id == 'proche-1'), isFalse);
  });

  test("mots de passe : le sien avec l'actuel, celui d'un proche par le propriétaire", () async {
    final proche = ElanBackend(url);
    addTearDown(proche.dispose);
    await proche.signIn(relative, relativePassword);

    await expectLater(
      proche.changePassword('nouveau-mot-de-passe', current: 'pas-le-bon'),
      _fails(AuthFailure.wrongCredentials),
    );
    await expectLater(proche.changePassword('court', current: relativePassword), _fails(AuthFailure.weakPassword));
    await proche.changePassword('nouveau-mot-de-passe', current: relativePassword);
    // Toujours connecté après le changement, et la session fonctionne.
    expect(proche.currentUser!.email, relative);
    expect(await proche.gateway.pullSince(null), hasLength(1));

    // Mot de passe oublié : le propriétaire en redonne un, sans connaître l'ancien.
    final account = (await owner.accounts!.list()).singleWhere((a) => a.email == relative);
    await owner.accounts!.resetPassword(account.id, 'mot-de-passe-redonne');
    final again = ElanBackend(url);
    addTearDown(again.dispose);
    await expectLater(again.signIn(relative, 'nouveau-mot-de-passe'), _fails(AuthFailure.wrongCredentials));
    await again.signIn(relative, 'mot-de-passe-redonne');
    expect(again.currentUser, isNotNull);
  });

  test("suppression d'un compte : il est déconnecté, ses données partent, pas celles des autres", () async {
    final proche = ElanBackend(url);
    addTearDown(proche.dispose);
    await proche.signIn(relative, 'mot-de-passe-redonne');

    final before = (await owner.gateway.pullSince(null)).length;
    final account = (await owner.accounts!.list()).singleWhere((a) => a.email == relative);
    await owner.accounts!.delete(account.id);

    expect((await owner.accounts!.list()).any((a) => a.email == relative), isFalse);
    expect(await owner.gateway.pullSince(null), hasLength(before));

    // À la prochaine ouverture de l'app du proche : session fermée.
    await proche.refreshSession();
    expect(proche.currentUser, isNull);
    final again = ElanBackend(url);
    addTearDown(again.dispose);
    await expectLater(again.signIn(relative, 'mot-de-passe-redonne'), _fails(AuthFailure.wrongCredentials));
  });
}
