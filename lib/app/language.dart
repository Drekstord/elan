import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Langues de l'app.
const supportedLanguages = ['fr', 'en'];

/// Langue choisie dans les réglages, mémorisée sur l'appareil ; null = celle du téléphone.
class LanguageController extends Notifier<String?> {
  static const String _key = 'language';

  @override
  String? build() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getString(_key);
      if (supportedLanguages.contains(saved) && ref.mounted) state = saved;
    });
    return null;
  }

  Future<void> set(String? code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    code == null ? await prefs.remove(_key) : await prefs.setString(_key, code);
  }
}

final languageProvider = NotifierProvider<LanguageController, String?>(LanguageController.new);

/// Langue réellement affichée : le choix de l'utilisateur, sinon celle de l'appareil si l'app
/// la parle, sinon le français (langue d'origine de l'app).
Locale resolveLocale(String? chosen, Iterable<Locale> device) {
  if (chosen != null && supportedLanguages.contains(chosen)) return Locale(chosen);
  for (final locale in device) {
    if (supportedLanguages.contains(locale.languageCode)) return Locale(locale.languageCode);
  }
  return const Locale('fr');
}
