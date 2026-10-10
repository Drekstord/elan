import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'format.dart';
import 'language.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode.dart';

/// Material You n'existe que sur Android (le module fournirait sinon la couleur d'accent de Windows).
bool get supportsWallpaperColors => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class ElanApp extends ConsumerWidget {
  const ElanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaper = supportsWallpaperColors && ref.watch(wallpaperColorsProvider);
    final locale = resolveLocale(ref.watch(languageProvider), WidgetsBinding.instance.platformDispatcher.locales);
    // Les nombres et les dates suivent la langue de l'app.
    formatLocale = locale.languageCode;
    Intl.defaultLocale = locale.languageCode;
    // Le fond d'écran fournit ses couleurs sur Android 12+ ; ailleurs (ou si l'option
    // est coupée), palette ÉLAN.
    return DynamicColorBuilder(
      builder: (systemLight, systemDark) => MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: wallpaper && systemLight != null ? AppTheme.fromWallpaper(systemLight) : AppTheme.light(),
        darkTheme: wallpaper && systemDark != null ? AppTheme.fromWallpaper(systemDark) : AppTheme.dark(),
        themeMode: ref.watch(themeModeProvider),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
