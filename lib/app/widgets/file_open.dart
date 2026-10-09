import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Canal vers MainActivity.kt (ouverture d'un fichier par l'application adaptée).
const _android = MethodChannel('elan/share');

/// Type MIME d'après l'extension.
String mimeOf(String name) => switch (name.split('.').last.toLowerCase()) {
  'pdf' => 'application/pdf',
  'png' => 'image/png',
  'webp' => 'image/webp',
  'heic' => 'image/heic',
  'jpg' || 'jpeg' => 'image/jpeg',
  _ => 'application/octet-stream',
};

/// Ouvre [file] avec l'application par défaut (lecteur PDF, visionneuse…).
/// [displayName] donne le nom (et l'extension) du fichier présenté à l'utilisateur.
Future<void> openLocalFile(File file, {required String displayName}) async {
  if (kIsWeb) return;
  if (Platform.isWindows) {
    // Copie au nom d'origine : la visionneuse affiche « facture.pdf » plutôt qu'un identifiant.
    // Ouverture comme un double-clic (ShellExecute) : l'application par défaut du type de fichier.
    final copy = await _namedCopy(file, displayName);
    await launchUrl(Uri.file(copy.path));
  } else if (Platform.isAndroid) {
    // Le FileProvider n'expose que le cache : on y place une copie.
    final copy = await _namedCopy(file, displayName);
    await _android.invokeMethod('openFile', {'path': copy.path, 'mime': mimeOf(displayName)});
  }
}

Future<File> _namedCopy(File file, String displayName) async {
  final dir = Directory('${(await getTemporaryDirectory()).path}/justificatifs');
  await dir.create(recursive: true);
  final safe = displayName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return file.copy('${dir.path}/$safe');
}
