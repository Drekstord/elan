import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_localizations.dart';

/// Canal vers MainActivity.kt (partage d'une image via le menu système d'Android).
const _androidShare = MethodChannel('elan/share');

/// Sur téléphone on partage, sur ordinateur on enregistre.
bool get exportShares => !kIsWeb && Platform.isAndroid;

/// Nom de fichier lisible : « elan-octobre-rett.png ».
String exportFileName(String prefix, String title, {String extension = 'png'}) {
  final slug = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9àâäéèêëîïôöùûüç]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return '$prefix-${slug.isEmpty ? 'image' : slug}.$extension';
}

/// Rend le [RepaintBoundary] de [boundary] en PNG (× [pixelRatio]), puis le partage
/// (Android) ou propose de l'enregistrer (ordinateur). Renvoie vrai si c'est fait.
Future<bool> exportImage(
  BuildContext context,
  GlobalKey boundary, {
  required String fileName,
  double pixelRatio = 3,
}) async {
  final render = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await render.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (!context.mounted) return false;
  return exportFile(
    context,
    data!.buffer.asUint8List(),
    fileName: fileName,
    mimeType: 'image/png',
    extension: 'png',
    savedMessage: AppLocalizations.of(context).shareSaved,
  );
}

/// Partage (Android) ou enregistre (ordinateur) un fichier déjà produit.
Future<bool> exportFile(
  BuildContext context,
  Uint8List bytes, {
  required String fileName,
  required String mimeType,
  required String extension,
  String? savedMessage,
}) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  if (exportShares) {
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    // Menu de partage Android natif (MainActivity.kt) : pas de module tiers.
    await _androidShare.invokeMethod('shareImage', {'path': file.path, 'title': t.shareTitle, 'mime': mimeType});
    return true;
  }
  final saved = await FilePicker.saveFile(
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
    dialogTitle: t.shareSave,
    type: FileType.custom,
    allowedExtensions: [extension],
  );
  if (saved == null) return false;
  // Selon la plateforme, le sélecteur renvoie l'emplacement sans écrire le fichier.
  if (saved.scheme == 'file') {
    final file = File(saved.toFilePath());
    if (!await file.exists() || await file.length() == 0) await file.writeAsBytes(bytes, flush: true);
  }
  messenger.showSnackBar(SnackBar(content: Text(savedMessage ?? t.fileSaved)));
  return true;
}
