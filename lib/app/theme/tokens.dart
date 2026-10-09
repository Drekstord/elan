import 'package:flutter/material.dart';

/// Jetons de design ÉLAN : « athlétique, nature et solidarité ».
///
/// Élan, c'est l'impulsion de l'effort et l'animal des forêts boréales :
/// papier lichen, bandeaux vert forêt, accent vert mousse pour l'action,
/// terre cuite pour tout ce qui touche au don. Chiffres et titres en
/// capitales condensées, angles francs, aucun dégradé.
class Palette {
  final Color canvas;
  final Color surface;

  /// Bandeau des chiffres héros (vert forêt).
  final Color band;
  final Color onBand;

  /// Accent et couleur solidaire éclaircis pour rester lisibles sur le bandeau.
  final Color bandAccent;
  final Color bandWarm;

  /// Bordure discrète des cartes et de la grille des graphiques (décorative).
  final Color border;

  /// Contour des contrôles (champs de saisie, puces de filtre) : au moins 3:1 sur la carte.
  final Color outline;
  final Color text;
  final Color textMuted;

  /// L'accent d'action : boutons, distance, état actif (vert mousse).
  final Color accent;
  final Color onAccent;

  /// Sens : solidaire (terre cuite) / record (or d'automne) / à venir (bleu lac) / erreur.
  final Color solidarity;
  final Color onSolidarity;
  final Color record;
  final Color upcoming;
  final Color danger;

  /// Graphiques (validés : bande de luminosité, chroma, daltonisme, contraste).
  /// Série principale / série de comparaison / montants.
  final Color chartPrimary;
  final Color chartCompare;
  final Color chartMoney;

  const Palette({
    required this.canvas,
    required this.surface,
    required this.band,
    required this.onBand,
    required this.bandAccent,
    required this.bandWarm,
    required this.border,
    required this.outline,
    required this.text,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.solidarity,
    required this.onSolidarity,
    required this.record,
    required this.upcoming,
    required this.danger,
    required this.chartPrimary,
    required this.chartCompare,
    required this.chartMoney,
  });

  static const light = Palette(
    canvas: Color(0xFFF2EEE4),
    surface: Color(0xFFFFFDF8),
    band: Color(0xFF15301F),
    onBand: Color(0xFFF2EEE4),
    bandAccent: Color(0xFFA8D45E),
    bandWarm: Color(0xFFF2946B),
    border: Color(0xFFCEC6B3),
    outline: Color(0xFF8C8775),
    text: Color(0xFF14231A),
    textMuted: Color(0xFF555F51),
    accent: Color(0xFF356B24),
    onAccent: Color(0xFFFFFFFF),
    solidarity: Color(0xFFA8431F),
    onSolidarity: Color(0xFFFFFFFF),
    record: Color(0xFF87601A),
    upcoming: Color(0xFF2C6B8A),
    danger: Color(0xFFB3261E),
    chartPrimary: Color(0xFF3F7D2B),
    chartCompare: Color(0xFF7A5AA6),
    chartMoney: Color(0xFFC0502C),
  );

  /// Sombre : anthracite chaud, cartes nettement détachées du fond, bandeau en
  /// vert forêt franc (pas un gris verdâtre), textes secondaires assez clairs,
  /// accents désaturés pour ne pas éblouir.
  static const dark = Palette(
    canvas: Color(0xFF0F110F),
    surface: Color(0xFF1B1F1B),
    band: Color(0xFF173822),
    onBand: Color(0xFFF0EEE6),
    bandAccent: Color(0xFFA3CC6C),
    bandWarm: Color(0xFFF0A07E),
    border: Color(0xFF383F38),
    outline: Color(0xFF6F766C),
    text: Color(0xFFEDEBE3),
    textMuted: Color(0xFFA8AB9F),
    accent: Color(0xFF93BE69),
    onAccent: Color(0xFF0F110F),
    solidarity: Color(0xFFE5946F),
    onSolidarity: Color(0xFF0F110F),
    record: Color(0xFFDDB45C),
    upcoming: Color(0xFF86B8D3),
    danger: Color(0xFFF08A80),
    chartPrimary: Color(0xFF76A04C),
    chartCompare: Color(0xFF8E74BC),
    chartMoney: Color(0xFFD07A55),
  );

  /// Libellés secondaires du bandeau (« DISTANCE », « COURSES »…) : texte du bandeau
  /// atténué mais opaque, au moins 4,5:1 quelle que soit la palette.
  Color get onBandMuted => Color.alphaBlend(onBand.withValues(alpha: 0.75), band);

  /// Material You : palette tirée des couleurs du fond d'écran (Android 12+).
  ///
  /// Même grammaire que la palette ÉLAN : bandeau très foncé dans la teinte principale,
  /// chiffres héros en tons clairs « fixes » (identiques en clair et en sombre),
  /// solidaire = teinte tertiaire. L'or des records et le rouge d'erreur gardent leur sens.
  factory Palette.fromScheme(ColorScheme s) {
    final dark = s.brightness == Brightness.dark;
    final brand = dark ? Palette.dark : Palette.light;
    return Palette(
      canvas: dark ? s.surface : s.surfaceContainer,
      surface: dark ? s.surfaceContainer : s.surfaceContainerLowest,
      band: dark ? s.onPrimaryFixedVariant : s.onPrimaryFixed,
      onBand: s.primaryFixed,
      bandAccent: s.primaryFixedDim,
      bandWarm: s.tertiaryFixedDim,
      border: s.outlineVariant,
      outline: s.outline,
      text: s.onSurface,
      textMuted: s.onSurfaceVariant,
      accent: s.primary,
      onAccent: s.onPrimary,
      solidarity: s.tertiary,
      onSolidarity: s.onTertiary,
      record: brand.record,
      upcoming: s.secondary,
      danger: s.error,
      chartPrimary: s.primary,
      // Série de comparaison (année précédente) : neutre, en retrait de la série principale.
      chartCompare: s.outline,
      chartMoney: s.tertiary,
    );
  }
}

/// Familles de police intégrées (assets/fonts, licence OFL).
class Fonts {
  /// Chiffres, titres, libellés en capitales : condensée, très grasse.
  static const display = 'BarlowCondensed';

  /// Texte courant.
  static const body = 'PlusJakartaSans';

  static const tabular = [FontFeature.tabularFigures()];
}

class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Angles francs : l'esthétique « dossard » refuse les formes molles.
class Radii {
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
}

/// Largeur à partir de laquelle la navigation passe en barre latérale.
const double kWideLayout = 840;

/// Largeur maximale d'une colonne de lecture (formulaires, fiche étroite).
const double kContentMaxWidth = 760;

/// Largeur de contenu à partir de laquelle les écrans passent sur deux colonnes.
const double kTwoColumns = 1100;

/// Largeur maximale du contenu en disposition deux colonnes.
const double kWideMaxWidth = 1480;
