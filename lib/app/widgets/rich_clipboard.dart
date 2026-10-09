import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Canal natif (windows/runner/rich_clipboard.cpp, MainActivity.kt).
const _channel = MethodChannel('elan/clipboard');

/// Copie [html] (tableau, gras, listes : Word, Excel, Docs le collent mis en forme)
/// avec [text] en version brute pour les applications qui ignorent le HTML.
/// Sans support natif (ou en cas d'échec), seul le texte est copié.
Future<void> copyRich({required String text, required String html}) async {
  try {
    if (!kIsWeb && Platform.isWindows) {
      await _channel.invokeMethod('setRich', {'html': Uint8List.fromList(utf8.encode(cfHtml(html))), 'text': text});
      return;
    }
    if (!kIsWeb && Platform.isAndroid) {
      await _channel.invokeMethod('setRich', {'html': html, 'text': text});
      return;
    }
  } on PlatformException {
    // Repli sur le texte brut ci-dessous.
  } on MissingPluginException {
    // Idem (tests, plateforme sans canal).
  }
  await Clipboard.setData(ClipboardData(text: text));
}

/// Enveloppe « HTML Format » du presse-papier Windows : en-tête donnant, en octets UTF-8,
/// le début et la fin du document et du fragment copié.
String cfHtml(String fragment) {
  const pre = '<html><head><meta charset="utf-8"></head><body><!--StartFragment-->';
  const post = '<!--EndFragment--></body></html>';
  String header(int startHtml, int endHtml, int startFragment, int endFragment) {
    String n(int v) => v.toString().padLeft(10, '0');
    return 'Version:0.9\r\nStartHTML:${n(startHtml)}\r\nEndHTML:${n(endHtml)}\r\n'
        'StartFragment:${n(startFragment)}\r\nEndFragment:${n(endFragment)}\r\n';
  }

  int bytes(String s) => utf8.encode(s).length;
  final headerLength = bytes(header(0, 0, 0, 0)); // longueur fixe (nombres sur 10 chiffres)
  final startFragment = headerLength + bytes(pre);
  final endFragment = startFragment + bytes(fragment);
  final endHtml = endFragment + bytes(post);
  return '${header(headerLength, endHtml, startFragment, endFragment)}$pre$fragment$post';
}

/// Échappement HTML du texte.
String htmlEscape(String v) =>
    v.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
