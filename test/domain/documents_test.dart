import 'dart:io';

import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/documents/documents.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

/// Justificatif [id], rangé comme le fait l'app : `u/docs/id.extension-du-nom`.
CourseDocument doc(String id, String name) => CourseDocument(
  key: 'u/docs/$id.${name.split('.').last.toLowerCase()}',
  name: name,
  sizeBytes: 10,
  addedAt: DateTime.utc(2026, 1, 1),
);

/// Identifiant d'une clé de justificatif (« u/docs/k1.pdf » -> « k1 »).
String idOf(String key) => key.split('/').last.split('.').first;

Course course(String id, DateTime date, List<CourseDocument> docs, {DateTime? deletedAt}) =>
    Course(id: id, title: 'Course $id', raceDate: date, distanceM: 10000, documents: docs, deletedAt: deletedAt);

void main() {
  final courses = [
    course('a', calendarDate(2025, 9, 20), [doc('k1', 'facture.pdf')]),
    course('b', calendarDate(2026, 3, 1), [doc('k2', 'facture.pdf'), doc('k3', 'reçu don.jpg')]),
    course('c', calendarDate(2026, 5, 1), const []),
    course('d', calendarDate(2026, 6, 1), [doc('k4', 'x.pdf')], deletedAt: DateTime.utc(2026, 6, 2)),
  ];

  test('justificatifs par période, course la plus récente d\'abord, courses supprimées exclues', () {
    expect(documentsOf(courses).map((e) => idOf(e.document.key)), ['k2', 'k3', 'k1']);
    expect(
      documentsOf(
        courses,
        from: calendarDate(2026, 1, 1),
        to: calendarDate(2026, 12, 31),
      ).map((e) => idOf(e.document.key)),
      ['k2', 'k3'],
    );
    // Bornes incluses.
    expect(documentsOf(courses, from: calendarDate(2025, 9, 20), to: calendarDate(2025, 9, 20)), hasLength(1));
  });

  test('nom d\'export : date, course, nom d\'origine, caractères interdits retirés', () {
    final e = DocumentEntry(
      Course(id: 'x', title: 'Semi : Paris/2026', raceDate: calendarDate(2026, 3, 8), distanceM: 21097),
      doc('k', 'facture.pdf'),
    );
    expect(e.exportName(), '2026-03-08 Semi Paris 2026 - facture.pdf');
    expect(e.exportName(kindLabel: 'Facture'), '2026-03-08 Semi Paris 2026 - Facture.pdf');
  });

  test('ZIP : un fichier par justificatif, doublons numérotés, introuvables ignorés', () async {
    final dir = await Directory.systemTemp.createTemp('elan_docs');
    addTearDown(() => dir.delete(recursive: true));
    final files = {
      'k1': File('${dir.path}/1')..writeAsBytesSync([1]),
      'k2': File('${dir.path}/2')..writeAsBytesSync([2]),
    };
    final same = Course(id: 's', title: 'Trail', raceDate: calendarDate(2026, 4, 1), distanceM: 1);
    final entries = [
      DocumentEntry(same, doc('k1', 'facture.pdf')),
      DocumentEntry(same, doc('k2', 'facture.pdf')),
      DocumentEntry(same, doc('absent', 'perdu.pdf')),
    ];
    final (bytes, missing) = await zipDocuments(entries, (key) async => files[idOf(key)]);
    expect(missing, 1);
    final zip = ZipDecoder().decodeBytes(bytes);
    expect(zip.files.map((f) => f.name), ['2026-04-01 Trail - facture.pdf', '2026-04-01 Trail - facture (2).pdf']);
    expect(zip.files.last.content, [2]);
  });

  test('justificatifs : aller-retour JSON avec le serveur', () {
    final c = courses[1];
    final back = Course.fromRemoteJson(c.toRemoteJson());
    expect(back.documents.map((d) => (idOf(d.key), d.name, d.sizeBytes)), [
      ('k2', 'facture.pdf', 10),
      ('k3', 'reçu don.jpg', 10),
    ]);
    expect(back.fileKeys.map(idOf), ['k2', 'k3']);
    // Ancienne ligne sans la colonne : aucun justificatif.
    expect(Course.fromRemoteJson({...c.toRemoteJson()}..remove('documents')).documents, isEmpty);
    expect(doc('k', 'Facture.PDF').isPdf, isTrue);
  });

  test("types : proposés d'après le nom du fichier, enregistrés, anciens justificatifs sans type", () {
    expect(DocumentKind.guess('Facture_2026.pdf'), DocumentKind.invoice);
    expect(DocumentKind.guess('reçu_N3304694061013.pdf'), DocumentKind.donationReceipt);
    expect(DocumentKind.guess('mail foulée.pdf'), DocumentKind.confirmation);
    expect(DocumentKind.guess('Classement-officiel.pdf'), DocumentKind.result);
    expect(DocumentKind.guess('2026-10-09_09h34_15.png'), isNull);

    final typed = doc('k', 'x.pdf').withKind(DocumentKind.invoice);
    expect(CourseDocument.fromJson(typed.toJson()).kind, DocumentKind.invoice);
    expect(CourseDocument.fromJson(doc('k', 'x.pdf').toJson()).kind, isNull);
    expect(doc('k', 'x.pdf').toJson().containsKey('kind'), isFalse);
  });

  test("ZIP : noms fournis par l'appelant (libellés des types)", () async {
    final dir = await Directory.systemTemp.createTemp('elan_docs');
    addTearDown(() => dir.delete(recursive: true));
    final f = File('${dir.path}/1')..writeAsBytesSync([1]);
    final race = Course(id: 's', title: 'Trail', raceDate: calendarDate(2026, 4, 1), distanceM: 1);
    final entries = [
      DocumentEntry(race, doc('a', 'scan1.pdf').withKind(DocumentKind.invoice)),
      DocumentEntry(race, doc('b', 'scan2.pdf').withKind(DocumentKind.invoice)),
    ];
    final (bytes, _) = await zipDocuments(entries, (_) async => f, nameOf: (e) => e.exportName(kindLabel: 'Facture'));
    expect(ZipDecoder().decodeBytes(bytes).files.map((x) => x.name), [
      '2026-04-01 Trail - Facture.pdf',
      '2026-04-01 Trail - Facture (2).pdf',
    ]);
  });
}
