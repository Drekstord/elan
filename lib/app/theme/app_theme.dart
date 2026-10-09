import 'package:flutter/material.dart';

import 'tokens.dart';

/// Thème Material construit uniquement à partir des jetons.
class AppTheme {
  static ThemeData light() => _build(Palette.light, Brightness.light);
  static ThemeData dark() => _build(Palette.dark, Brightness.dark);

  /// Material You : thème complet régénéré depuis la couleur principale du fond d'écran
  /// (variante « tonal spot », celle d'Android), pour disposer de tous les rôles de couleur.
  static ThemeData fromWallpaper(ColorScheme system) {
    final scheme = ColorScheme.fromSeed(seedColor: system.primary, brightness: system.brightness);
    return _build(Palette.fromScheme(scheme), system.brightness);
  }

  static ThemeData _build(Palette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.text,
      onSecondary: p.canvas,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.textMuted,
      surfaceContainerHighest: p.canvas,
      outline: p.border,
      outlineVariant: p.border,
      inverseSurface: p.band,
      onInverseSurface: p.onBand,
    );

    TextStyle display(double size, {FontWeight weight = FontWeight.w800, double spacing = 0, double height = 1.0}) =>
        TextStyle(
          fontFamily: Fonts.display,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          height: height,
          color: p.text,
          fontFeatures: Fonts.tabular,
        );
    TextStyle body(double size, {FontWeight weight = FontWeight.w400, double height = 1.45}) =>
        TextStyle(fontFamily: Fonts.body, fontSize: size, fontWeight: weight, height: height, color: p.text);

    final textTheme = TextTheme(
      displayLarge: display(72),
      displayMedium: display(56),
      displaySmall: display(44),
      headlineLarge: display(36),
      headlineMedium: display(30),
      headlineSmall: display(26, weight: FontWeight.w700),
      titleLarge: display(22, weight: FontWeight.w700, spacing: 0.3, height: 1.15),
      titleMedium: body(16, weight: FontWeight.w700, height: 1.3),
      titleSmall: body(14, weight: FontWeight.w700, height: 1.3),
      bodyLarge: body(16),
      bodyMedium: body(14),
      bodySmall: body(12.5).copyWith(color: p.textMuted),
      labelLarge: display(16, weight: FontWeight.w700, spacing: 0.8, height: 1.2),
      labelMedium: display(13, weight: FontWeight.w700, spacing: 1.2, height: 1.2).copyWith(color: p.textMuted),
      labelSmall: display(11, weight: FontWeight.w700, spacing: 1.2, height: 1.2).copyWith(color: p.textMuted),
    );

    final square = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md));
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: p.outline),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: Space.lg, vertical: 14);
    final buttonText = textTheme.labelLarge!;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: Fonts.body,
      textTheme: textTheme,
      scaffoldBackgroundColor: p.canvas,
      dividerColor: p.border,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      extensions: [AppPalette(p)],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.canvas,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: display(24, weight: FontWeight.w800, spacing: 1),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: p.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          textStyle: buttonText,
          padding: buttonPadding,
          shape: square,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          side: BorderSide(color: p.text, width: 1.5),
          textStyle: buttonText,
          padding: buttonPadding,
          shape: square,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.text, textStyle: buttonText, shape: square),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        elevation: 0,
        highlightElevation: 0,
        extendedTextStyle: buttonText.copyWith(fontSize: 17),
        shape: square,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.text, width: 1.8)),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.danger)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.danger, width: 1.8)),
        labelStyle: body(14).copyWith(color: p.textMuted),
        floatingLabelStyle: body(14, weight: FontWeight.w600),
        hintStyle: body(14).copyWith(color: p.textMuted),
        errorMaxLines: 2,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.text,
        secondarySelectedColor: p.text,
        // Couleur du libellé selon la sélection (fond noir -> texte clair).
        labelStyle: body(
          13,
          weight: FontWeight.w600,
        ).copyWith(color: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? p.canvas : p.text)),
        secondaryLabelStyle: body(13, weight: FontWeight.w600).copyWith(color: p.canvas),
        iconTheme: IconThemeData(color: p.textMuted, size: 16),
        side: BorderSide(color: p.outline),
        shape: square,
        checkmarkColor: p.canvas,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(square),
          textStyle: WidgetStatePropertyAll(buttonText.copyWith(fontSize: 15)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.text : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.canvas : p.text),
          side: WidgetStatePropertyAll(BorderSide(color: p.text, width: 1.5)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onAccent : p.textMuted),
        // Position « non » : piste du fond de carte cernée du contour franc (lisible au soleil).
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.surface),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.transparent : p.outline,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.accent.withValues(alpha: 0.14),
        indicatorShape: square,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => display(
            13,
            weight: FontWeight.w700,
            spacing: 1,
          ).copyWith(color: s.contains(WidgetState.selected) ? p.text : p.textMuted),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? p.accent : p.textMuted),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.accent.withValues(alpha: 0.14),
        indicatorShape: square,
        selectedIconTheme: IconThemeData(color: p.accent),
        unselectedIconTheme: IconThemeData(color: p.textMuted),
        selectedLabelTextStyle: display(13, weight: FontWeight.w700, spacing: 1),
        unselectedLabelTextStyle: display(13, weight: FontWeight.w700, spacing: 1).copyWith(color: p.textMuted),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        titleTextStyle: display(26, weight: FontWeight.w800),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.band,
        contentTextStyle: body(14, weight: FontWeight.w600).copyWith(color: p.onBand),
        behavior: SnackBarBehavior.floating,
        shape: square,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.text,
        titleTextStyle: body(15, weight: FontWeight.w600),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      popupMenuTheme: PopupMenuThemeData(color: p.surface, shape: square),
    );
  }
}

/// Accès à la palette complète depuis les widgets : `context.palette.accent`.
class AppPalette extends ThemeExtension<AppPalette> {
  final Palette palette;
  const AppPalette(this.palette);

  @override
  AppPalette copyWith({Palette? palette}) => AppPalette(palette ?? this.palette);

  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<AppPalette>()!.palette;
}

/// Styles éditoriaux récurrents, hors de l'échelle Material.
class TextStyles {
  /// Chiffre héros : « 842 ».
  static TextStyle hero(Color color, {double size = 88}) => TextStyle(
    fontFamily: Fonts.display,
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 0.9,
    letterSpacing: -1,
    color: color,
    fontFeatures: Fonts.tabular,
  );

  /// Valeur chiffrée secondaire : « 1:42:10 ».
  static TextStyle figure(Color color, {double size = 22}) => TextStyle(
    fontFamily: Fonts.display,
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.05,
    color: color,
    fontFeatures: Fonts.tabular,
  );

  /// Sur-titre en capitales espacées : « KILOMÈTRES ».
  static TextStyle kicker(Color color, {double size = 13}) => TextStyle(
    fontFamily: Fonts.display,
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    height: 1.2,
    color: color,
  );

  /// Titre de course en capitales condensées.
  static TextStyle courseTitle(Color color, {double size = 20}) => TextStyle(
    fontFamily: Fonts.display,
    fontSize: size,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    height: 1.05,
    color: color,
  );
}
