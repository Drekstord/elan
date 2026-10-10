import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/backend/backend.dart';
import '../core/providers.dart';
import '../core/server/server_config.dart';
import '../features/auth/presentation/server_screen.dart';
import '../l10n/app_localizations.dart';
import 'app.dart';
import 'theme/app_theme.dart';

/// Racine de l'app : connectée au serveur choisi, recréée entièrement quand il change
/// (le changement ne se fait que déconnecté, depuis l'écran de connexion).
class ServerRoot extends StatefulWidget {
  final ServerStore store;
  final Directory dataDir;

  /// Serveur déjà relié par `main` (null : aucun serveur, à saisir).
  final ServerConfig? initial;
  final Backend? initialBackend;

  const ServerRoot({
    super.key,
    required this.store,
    required this.dataDir,
    required this.initial,
    required this.initialBackend,
  });

  @override
  State<ServerRoot> createState() => _ServerRootState();
}

class _ServerRootState extends State<ServerRoot> {
  late ServerConfig? _server = widget.initial;
  late Backend? _backend = widget.initialBackend;
  var _generation = 0;

  SharedPreferences get _prefs => widget.store.prefs;

  Future<void> _switchTo(ServerConfig? custom) async {
    await widget.store.save(custom);
    final next = widget.store.active;
    await _backend?.dispose();
    final backend = next == null ? null : await Backend.connect(next, _prefs);
    if (mounted) {
      setState(() {
        _server = next;
        _backend = backend;
        _generation++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final server = _server;
    final backend = _backend;
    if (server == null || backend == null) return _ServerSetupApp(onSave: _switchTo);
    return ProviderScope(
      key: ValueKey(_generation),
      overrides: [
        appDirectoryProvider.overrideWithValue(widget.dataDir),
        backendProvider.overrideWithValue(backend),
        serverChoiceProvider.overrideWithValue(
          ServerChoice(current: server, builtIn: ServerConfig.compiled, switchTo: _switchTo),
        ),
      ],
      child: const ElanApp(),
    );
  }
}

/// Aucun serveur intégré à la compilation : l'app demande d'abord l'adresse du serveur.
class _ServerSetupApp extends StatelessWidget {
  final Future<void> Function(ServerConfig? custom) onSave;

  const _ServerSetupApp({required this.onSave});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: ServerScreen(current: null, builtIn: null, onSave: onSave),
  );
}
