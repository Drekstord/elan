// Planche de l'emblème : flutter test test/screenshots --tags screenshots --run-skipped --update-goldens
@Tags(['screenshots'])
library;

import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/app/theme/tokens.dart';
import 'package:app_course/app/widgets/common.dart';
import 'package:app_course/app/widgets/elan_emblem.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_test.dart' show loadTestFonts;

void main() {
  setUpAll(loadTestFonts);

  testWidgets('planche emblème', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Widget board(ThemeData theme) => Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final p = context.palette;
          return Container(
            color: p.canvas,
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ElanEmblem(size: 260),
                const SizedBox(width: 32),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [ElanEmblem(size: 56), SizedBox(width: 12), Wordmark(size: 48)]),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        for (final s in [48.0, 32.0, 24.0, 16.0]) ...[ElanEmblem(size: s), const SizedBox(width: 16)],
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(color: p.band, borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(10),
                          child: ElanEmblem(color: p.bandAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Material(
          child: Column(
            children: [
              Expanded(child: board(AppTheme.light())),
              Expanded(child: board(AppTheme.dark())),
            ],
          ),
        ),
      ),
    );
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/emblème.png'));
    expect(Space.md, 16);
  });
}
