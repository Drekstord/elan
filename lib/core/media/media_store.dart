import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/courses/domain/course.dart';

/// Photos de course sur le disque, rangées comme dans le bucket `course-media` :
/// `<racine>/<user_id>/<uuid>.jpg` et sa miniature `<uuid>_t.jpg`.
///
/// La clé est la seule référence stockée dans la course ; le fichier local
/// n'est qu'un cache de l'objet distant.
class MediaStore {
  static const int maxSide = 2000;
  static const int thumbSide = 480;

  final Directory root;
  final String userId;

  MediaStore(this.root, this.userId);

  static String thumbKeyOf(String key) => key.replaceFirst(RegExp(r'\.[^./]+$'), '_t.jpg');

  /// Fichier local d'une clé. Une clé qui ne suit pas le format de l'app (données altérées sur
  /// le serveur : « ../ », chemin absolu, extension exécutable) est refusée : rien n'est lu ni
  /// écrit hors du dossier des photos.
  File fileFor(String key) {
    if (!isSafeFileKey(key)) throw UnsafeFileKey(key);
    final path = p.joinAll([root.path, ...key.split('/')]);
    if (!p.isWithin(root.path, path)) throw UnsafeFileKey(key);
    return File(path);
  }

  /// Importe une image : redimensionnée (2000 px max, JPEG), plus une miniature.
  /// Si le format n'est pas décodable (ex. HEIC), l'original est conservé tel quel.
  Future<String> importPhoto(File source) async {
    final id = const Uuid().v4();
    final bytes = await source.readAsBytes();
    final encoded = await Isolate.run(() => _encode(bytes));

    if (encoded == null) {
      final key = '$userId/$id${_extensionOf(source.path, fallback: '.jpg')}';
      await _write(key, bytes);
      return key;
    }
    final key = '$userId/$id.jpg';
    await _write(key, encoded.full);
    await _write(thumbKeyOf(key), encoded.thumb);
    return key;
  }

  /// Taille maximale d'un justificatif (limite du bucket : 10 Mo).
  static const int maxDocumentBytes = 10 * 1024 * 1024;

  /// Importe un justificatif (PDF ou image) tel quel, sous `<user_id>/docs/<uuid>.<ext>`.
  /// Renvoie la clé, ou null si le fichier dépasse [maxDocumentBytes].
  Future<String?> importDocument(File source) async {
    final length = await source.length();
    if (length > maxDocumentBytes) return null;
    final key = '$userId/docs/${const Uuid().v4()}${_extensionOf(source.path, fallback: '.pdf')}';
    await _write(key, await source.readAsBytes());
    return key;
  }

  /// Extension d'un fichier importé, si c'est un type connu ; sinon [fallback].
  static String _extensionOf(String path, {required String fallback}) {
    final ext = p.extension(path).toLowerCase();
    return safeFileExtensions.contains(ext.replaceFirst('.', '')) ? ext : fallback;
  }

  Future<void> _write(String key, List<int> bytes) async {
    final file = fileFor(key);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> writeDownloaded(String key, List<int> bytes) => _write(key, bytes);

  /// Supprime la photo et sa miniature du cache local.
  Future<void> deleteLocal(String key) async {
    if (!isSafeFileKey(key)) return;
    for (final k in {key, thumbKeyOf(key)}) {
      final file = fileFor(k);
      if (await file.exists()) await file.delete();
    }
  }
}

/// Clé de fichier refusée : elle ne suit pas le format de l'app.
class UnsafeFileKey implements Exception {
  final String key;
  const UnsafeFileKey(this.key);

  @override
  String toString() => 'UnsafeFileKey($key)';
}

class _Encoded {
  final List<int> full;
  final List<int> thumb;
  const _Encoded(this.full, this.thumb);
}

_Encoded? _encode(List<int> bytes) {
  final decoded = img.decodeImage(bytes is Uint8List ? bytes : Uint8List.fromList(bytes));
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  img.Image fit(int side) {
    if (oriented.width <= side && oriented.height <= side) return oriented;
    return oriented.width >= oriented.height
        ? img.copyResize(oriented, width: side, interpolation: img.Interpolation.average)
        : img.copyResize(oriented, height: side, interpolation: img.Interpolation.average);
  }

  return _Encoded(
    img.encodeJpg(fit(MediaStore.maxSide), quality: 85),
    img.encodeJpg(fit(MediaStore.thumbSide), quality: 75),
  );
}
