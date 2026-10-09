import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

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

  File fileFor(String key) => File(p.joinAll([root.path, ...key.split('/')]));

  /// Importe une image : redimensionnée (2000 px max, JPEG), plus une miniature.
  /// Si le format n'est pas décodable (ex. HEIC), l'original est conservé tel quel.
  Future<String> importPhoto(File source) async {
    final id = const Uuid().v4();
    final bytes = await source.readAsBytes();
    final encoded = await Isolate.run(() => _encode(bytes));

    if (encoded == null) {
      final ext = p.extension(source.path).toLowerCase();
      final key = '$userId/$id${ext.isEmpty ? '.jpg' : ext}';
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
    final ext = p.extension(source.path).toLowerCase();
    final key = '$userId/docs/${const Uuid().v4()}${ext.isEmpty ? '.pdf' : ext}';
    await _write(key, await source.readAsBytes());
    return key;
  }

  Future<void> _write(String key, List<int> bytes) async {
    final file = fileFor(key);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> writeDownloaded(String key, List<int> bytes) => _write(key, bytes);

  /// Supprime la photo et sa miniature du cache local.
  Future<void> deleteLocal(String key) async {
    for (final k in {key, thumbKeyOf(key)}) {
      final file = fileFor(k);
      if (await file.exists()) await file.delete();
    }
  }
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
