// Règle du projet : aucun tiret long (U+2014) nulle part, ni dans l'app ni dans la documentation.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aucun tiret long dans le code, les textes et la documentation', () {
    final dash = String.fromCharCode(0x2014);
    final offenders = <String>[];
    for (final root in ['lib', 'test', 'docs', 'scripts', 'supabase', '.github', 'android/app/src', 'windows/runner']) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        if (!RegExp(r'\.(dart|arb|md|ps1|sql|yml|kt|kts|xml|cpp|h|rc)$').hasMatch(f.path)) continue;
        final lines = f.readAsLinesSync();
        for (final (i, line) in lines.indexed) {
          if (line.contains(dash)) offenders.add('${f.path}:${i + 1}');
        }
      }
    }
    for (final f in ['README.md']) {
      if (File(f).readAsStringSync().contains(dash)) offenders.add(f);
    }
    expect(offenders, isEmpty);
  });
}
