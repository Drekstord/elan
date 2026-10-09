import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Emblème ÉLAN : tête d'élan de face, géométrique, aux bois en palme.
/// Dessiné dans un repère 100 × 100, symétrique, d'une seule couleur.
class ElanEmblem extends StatelessWidget {
  final double size;
  final Color? color;

  const ElanEmblem({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: ElanEmblemPainter(color ?? context.palette.text)),
  );
}

class ElanEmblemPainter extends CustomPainter {
  final Color color;

  const ElanEmblemPainter(this.color);

  /// Bois gauche (palme et andouillers), de la base vers l'extérieur ; le droit en est le miroir.
  static const List<Offset> _antler = [
    Offset(42, 37),
    Offset(33, 37),
    Offset(22, 35),
    Offset(12, 30),
    Offset(4, 22),
    Offset(3, 13), // andouiller extérieur
    Offset(9, 19),
    Offset(11, 9), // andouiller
    Offset(16, 18),
    Offset(20, 7), // andouiller
    Offset(24, 18),
    Offset(29, 9), // andouiller intérieur
    Offset(31, 21),
    Offset(36, 27),
    Offset(44, 31),
  ];

  /// Moitié gauche de la tête : oreille, joue, long museau, mufle.
  static const List<Offset> _head = [
    Offset(50, 30),
    Offset(44, 31),
    Offset(40, 39),
    Offset(26, 45), // pointe de l'oreille, écartée sous les bois
    Offset(31, 48),
    Offset(39, 47),
    Offset(40, 52),
    Offset(42, 70),
    Offset(39, 78), // mufle
    Offset(40, 86),
    Offset(46, 90),
    Offset(50, 90),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    Path mirrored(List<Offset> points, {bool close = true}) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      if (close) path.close();
      return path;
    }

    List<Offset> mirror(List<Offset> pts) => [for (final p in pts) Offset(100 - p.dx, p.dy)];

    // Tête : moitié gauche puis moitié droite parcourue à l'envers.
    final outline = [..._head, ...mirror(_head).reversed.skip(1)];

    // Silhouette dans un calque, puis yeux et naseaux évidés (transparents).
    final cut = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 100, 100), Paint());
    canvas.drawPath(mirrored(_antler), paint);
    canvas.drawPath(mirrored(mirror(_antler)), paint);
    canvas.drawPath(mirrored(outline), paint);
    for (final x in [44.5, 55.5]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 83), width: 3.2, height: 4.6), cut);
    }
    for (final x in [42.5, 57.5]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 2.6, 47)
          ..lineTo(x + 2.6, 47)
          ..lineTo(x, 50.5)
          ..close(),
        cut,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ElanEmblemPainter oldDelegate) => oldDelegate.color != color;
}
