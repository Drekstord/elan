// Images sources de l'icône d'application (1024 px), puis :
//   dart run flutter_launcher_icons
@Tags(['screenshots'])
library;

import 'package:app_course/app/theme/tokens.dart';
import 'package:app_course/app/widgets/elan_emblem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(
  WidgetTester tester,
  String file, {
  required bool background,
  required double emblemShare,
  Color? color,
}) async {
  tester.view.physicalSize = const Size(1024, 1024);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        child: Container(
          color: background ? Palette.light.band : const Color(0x00000000),
          alignment: Alignment.center,
          child: ElanEmblemFrame(size: 1024 * emblemShare, color: color),
        ),
      ),
    ),
  );
  await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('../../assets/icon/$file'));
}

/// Emblème vert mousse, légèrement remonté (la masse des bois est en haut).
class ElanEmblemFrame extends StatelessWidget {
  final double size;
  final Color? color;
  const ElanEmblemFrame({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(0, size * 0.02),
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: ElanEmblemPainter(color ?? Palette.light.bandAccent)),
    ),
  );
}

void main() {
  testWidgets('icône complète', (t) => _render(t, 'app_icon.png', background: true, emblemShare: 0.72));
  // Android adaptatif : zone sûre d'environ 66 % du carré.
  testWidgets(
    'premier plan adaptatif',
    (t) => _render(t, 'app_icon_foreground.png', background: false, emblemShare: 0.56),
  );
  // Icône à thème (Android 13+) : seule la silhouette compte, le système la colore.
  testWidgets(
    'monochrome',
    (t) => _render(t, 'app_icon_monochrome.png', background: false, emblemShare: 0.56, color: const Color(0xFF000000)),
  );
}
