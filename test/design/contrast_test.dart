// Contrastes des couleurs réellement associées dans l'app (norme WCAG 2.x).
// Texte courant : 4,5:1. Grands chiffres, marques de graphique, contours de champs : 3:1.
import 'dart:math' as math;

import 'package:app_course/app/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Couleur [c] posée avec l'opacité [alpha] sur [bg].
Color over(Color c, double alpha, Color bg) => Color.alphaBlend(c.withValues(alpha: alpha), bg);

/// (nom, premier plan, fond, seuil)
List<(String, Color, Color, double)> pairs(Palette p, {required bool dark}) => [
  ('texte / fond', p.text, p.canvas, 4.5),
  ('texte / carte', p.text, p.surface, 4.5),
  ('texte secondaire / fond', p.textMuted, p.canvas, 4.5),
  ('texte secondaire / carte', p.textMuted, p.surface, 4.5),
  ('accent (libellés) / fond', p.accent, p.canvas, 4.5),
  ('accent (libellés) / carte', p.accent, p.surface, 4.5),
  ('bouton : texte / accent', p.onAccent, p.accent, 4.5),
  ('à venir / carte', p.upcoming, p.surface, 4.5),
  ('record / carte', p.record, p.surface, 4.5),
  ('solidaire / carte', p.solidarity, p.surface, 4.5),
  ('étiquette solidaire', p.solidarity, over(p.solidarity, 0.12, p.surface), 4.5),
  ('étiquette record', p.record, over(p.record, 0.12, p.surface), 4.5),
  ('étiquette à venir', p.upcoming, over(p.upcoming, 0.12, p.surface), 4.5),
  ('solidaire plein : texte', p.onSolidarity, p.solidarity, 4.5),
  ('bandeau : chiffres', p.onBand, p.band, 4.5),
  ('bandeau : libellés', p.onBandMuted, p.band, 4.5),
  ('bandeau : accent', p.bandAccent, p.band, 4.5),
  ('bandeau : euros', p.bandWarm, p.band, 4.5),
  if (dark) ('rappel à saisir (sombre)', p.accent, over(p.accent, 0.16, p.canvas), 4.5),
  ('contour de champ / carte', p.outline, p.surface, 3),
  ('contour de champ / fond', p.outline, p.canvas, 3),
  ('graphique principal / carte', p.chartPrimary, p.surface, 3),
  ('graphique comparaison / carte', p.chartCompare, p.surface, 3),
  ('graphique montants / carte', p.chartMoney, p.surface, 3),
];

final _wallpapers = {
  'bleu': const Color(0xFF3A6EA5),
  'rose': const Color(0xFFC2185B),
  'vert': const Color(0xFF4CAF50),
  'jaune': const Color(0xFFFBC02D),
  'violet': const Color(0xFF7E57C2),
};

Map<String, (Palette, bool)> palettes() => {
  'ÉLAN clair': (Palette.light, false),
  'ÉLAN sombre': (Palette.dark, true),
  for (final MapEntry(key: name, value: seed) in _wallpapers.entries) ...{
    'You $name clair': (Palette.fromScheme(ColorScheme.fromSeed(seedColor: seed)), false),
    'You $name sombre': (Palette.fromScheme(ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)), true),
  },
};

void main() {
  for (final MapEntry(key: name, value: (palette, dark)) in palettes().entries) {
    test('contrastes : $name', () {
      final failures = <String>[];
      for (final (label, fg, bg, min) in pairs(palette, dark: dark)) {
        final ratio = contrast(fg, bg);
        if (ratio < min) failures.add('$label : ${ratio.toStringAsFixed(2)} (min $min)');
      }
      expect(failures, isEmpty, reason: name);
    });
  }
}
