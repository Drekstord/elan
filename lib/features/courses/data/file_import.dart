import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'fit_parser.dart';
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

  /// Fichier de montre choisi par l'utilisateur : une trace GPX, ou un fichier FIT (le seul qui
  /// garde le détail d'un triathlon). Null s'il annule.
  /// Lève [GpxFormatException] ou [FitFormatException] si le fichier est illisible.
  static Future<({GpxSummary? gpx, FitSummary? fit, String name})?> pickActivity({required String dialogTitle}) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['gpx', 'fit'],
    );
    if (picked == null) return null;
    final path = picked.path;
    final name = picked.name.replaceAll(RegExp(r'\.(gpx|fit)$', caseSensitive: false), '');
    if (picked.name.toLowerCase().endsWith('.fit')) {
      final bytes = path != null ? await File(path).readAsBytes() : await picked.xFile.readAsBytes();
      return (gpx: null, fit: FitParser.parse(bytes), name: name);
    }
    final content = path != null ? await File(path).readAsString() : await picked.xFile.readAsString();
    return (gpx: GpxParser.parse(content, fallbackName: name), fit: null, name: name);
  }

  /// Plusieurs traces GPX d'un coup : les lisibles, et le nombre de fichiers illisibles.
  static Future<({List<GpxSummary> tracks, int unreadable})?> pickGpxFiles({required String dialogTitle}) async {
    final picked = await FilePicker.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['gpx'],
    );
    if (picked.isEmpty) return null;
    final tracks = <GpxSummary>[];
    var unreadable = 0;
    for (final file in picked) {
      try {
        final path = file.path;
        final content = path != null ? await File(path).readAsString() : await file.xFile.readAsString();
        tracks.add(
          GpxParser.parse(content, fallbackName: file.name.replaceAll(RegExp(r'\.gpx$', caseSensitive: false), '')),
        );
      } catch (_) {
        unreadable++;
      }
    }
    return (tracks: tracks, unreadable: unreadable);
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
