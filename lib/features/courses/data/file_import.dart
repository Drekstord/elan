import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'gpx_parser.dart';

/// Sélection de fichiers sur l'appareil (GPX, photos).
class FileImport {
  /// Trace GPX choisie par l'utilisateur ; null s'il annule.
  /// Lève [GpxFormatException] si le fichier est illisible.
  static Future<GpxSummary?> pickGpx({required String dialogTitle}) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['gpx'],
    );
    if (picked == null) return null;
    final path = picked.path;
    final content = path != null ? await File(path).readAsString() : await picked.xFile.readAsString();
    return GpxParser.parse(content, fallbackName: picked.name.replaceAll(RegExp(r'\.gpx$', caseSensitive: false), ''));
  }

  /// Justificatif choisi par l'utilisateur (PDF ou image) ; null s'il annule.
  static Future<({File file, String name})?> pickDocument({required String dialogTitle}) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic'],
    );
    final path = picked?.path;
    return path == null ? null : (file: File(path), name: picked!.name);
  }

  /// Image choisie par l'utilisateur ; null s'il annule.
  static Future<File?> pickImage({required String dialogTitle}) async {
    final picked = await FilePicker.pickFile(dialogTitle: dialogTitle, type: FileType.image);
    final path = picked?.path;
    return path == null ? null : File(path);
  }
}
