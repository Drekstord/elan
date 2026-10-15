import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../courses/domain/course.dart';

/// Un justificatif et la course à laquelle il est rattaché.
class DocumentEntry {
  final Course course;
  final CourseDocument document;

  const DocumentEntry(this.course, this.document);

  /// Nom à l'export : « 2026-10-04 Foulée de Démoville - Facture.pdf » avec le libellé du type
  /// ([kindLabel]), sinon le nom d'origine du fichier (justificatif ajouté avant les types).
  String exportName({String? kindLabel}) {
    String clean(String v) => v.replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    final ext = document.extension;
    final file = kindLabel == null ? document.safeName : (ext.isEmpty ? kindLabel : '$kindLabel.$ext');
    return '${formatIsoDate(course.raceDate)} ${clean(course.title)} - ${clean(file)}';
  }
}

/// Justificatifs des courses (non supprimées) dont la date est dans [from, to] (bornes
/// incluses, null = sans borne), de la course la plus récente à la plus ancienne.
List<DocumentEntry> documentsOf(Iterable<Course> courses, {DateTime? from, DateTime? to}) {
  final selected =
      courses
          .where(
            (c) =>
                !c.isDeleted &&
                c.documents.isNotEmpty &&
                (from == null || !c.raceDate.isBefore(from)) &&
                (to == null || !c.raceDate.isAfter(to)),
          )
          .toList()
        ..sort((a, b) => b.raceDate.compareTo(a.raceDate));
  return [
    for (final c in selected)
      for (final d in c.documents) DocumentEntry(c, d),
  ];
}

/// Archive ZIP des justificatifs, aux noms clairs (doublons numérotés).
/// [fileFor] fournit le fichier local (téléchargé au besoin) ; les introuvables sont ignorés.
Future<(Uint8List zip, int missing)> zipDocuments(
  List<DocumentEntry> entries,
  Future<File?> Function(String key) fileFor, {
  String Function(DocumentEntry)? nameOf,
}) async {
  final archive = Archive();
  final used = <String>{};
  var missing = 0;
  for (final e in entries) {
    final file = await fileFor(e.document.key);
    if (file == null) {
      missing++;
      continue;
    }
    var name = nameOf?.call(e) ?? e.exportName();
    if (used.contains(name.toLowerCase())) {
      final dot = name.lastIndexOf('.');
      final (base, ext) = dot < 0 ? (name, '') : (name.substring(0, dot), name.substring(dot));
      var i = 2;
      while (used.contains('$base ($i)$ext'.toLowerCase())) {
        i++;
      }
      name = '$base ($i)$ext';
    }
    used.add(name.toLowerCase());
    archive.addFile(ArchiveFile.bytes(name, await file.readAsBytes()));
  }
  return (ZipEncoder().encodeBytes(archive), missing);
}

/// Ajout / retrait de justificatifs sur une course.
class DocumentActions {
  final Ref ref;

  DocumentActions(this.ref);

  /// Joint [source] à [course], avec son type. Renvoie faux si le fichier dépasse 10 Mo.
  Future<bool> add(Course course, File source, String name, DocumentKind kind) async {
    final key = await ref.read(mediaStoreProvider).importDocument(source);
    if (key == null) return false;
    final doc = CourseDocument(
      key: key,
      name: name,
      sizeBytes: await source.length(),
      addedAt: DateTime.now(),
      kind: kind,
    );
    await ref.read(courseRepositoryProvider).save(course.copyWith(documents: [...course.documents, doc]));
    return true;
  }

  Future<void> remove(Course course, CourseDocument doc) => ref
      .read(courseRepositoryProvider)
      .save(
        course.copyWith(
          documents: [
            for (final d in course.documents)
              if (d.key != doc.key) d,
          ],
        ),
      );

  Future<void> setKind(Course course, CourseDocument doc, DocumentKind kind) => ref
      .read(courseRepositoryProvider)
      .save(course.copyWith(documents: [for (final d in course.documents) d.key == doc.key ? d.withKind(kind) : d]));

  /// Fichier local du justificatif, téléchargé depuis le cloud si besoin.
  Future<File?> file(CourseDocument doc) => ref.read(syncEngineProvider).photoFile(doc.key);
}

final documentActionsProvider = Provider<DocumentActions>(DocumentActions.new);
