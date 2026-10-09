import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférence clair / sombre / système, mémorisée sur l'appareil.
class ThemeModeController extends Notifier<ThemeMode> {
  static const String _key = 'theme_mode';

  @override
  ThemeMode build() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = ThemeMode.values.where((m) => m.name == prefs.getString(_key)).firstOrNull;
      if (saved != null && ref.mounted) state = saved;
    });
    return ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Material You (Android 12+) : couleurs du fond d'écran au lieu de la palette ÉLAN.
/// Activé par défaut ; sans effet hors Android.
class WallpaperColorsController extends Notifier<bool> {
  static const String _key = 'wallpaper_colors';

  @override
  bool build() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getBool(_key);
      if (saved != null && ref.mounted) state = saved;
    });
    return true;
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final wallpaperColorsProvider = NotifierProvider<WallpaperColorsController, bool>(WallpaperColorsController.new);
