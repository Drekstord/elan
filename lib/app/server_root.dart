import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers.dart';
import '../core/server/server_config.dart';
import '../features/auth/presentation/server_screen.dart';
import '../l10n/app_localizations.dart';
import 'app.dart';
import 'theme/app_theme.dart';

/// Ouvre la connexion au serveur choisi.
Future<void> connectTo(ServerConfig server) async {
  final key = server.sessionStorageKey;
  await Supabase.initialize(
    url: server.url,
    publishableKey: server.key,
    authOptions: key == null
        ? const FlutterAuthClientOptions()
        : FlutterAuthClientOptions(localStorage: SharedPreferencesLocalStorage(persistSessionKey: key)),
  );
}

/// Racine de l'app : connectée au serveur choisi, recréée entièrement quand il change
/// (le changement ne se fait que déconnecté, depuis l'écran de connexion).
class ServerRoot extends StatefulWidget {
  final ServerStore store;
  final Directory dataDir;

  /// Serveur déjà connecté par `main` (null : aucun serveur, à saisir).
  final ServerConfig? initial;

  const ServerRoot({super.key, required this.store, required this.dataDir, required this.initial});

  @override
  State<ServerRoot> createState() => _ServerRootState();
}

class _ServerRootState extends State<ServerRoot> {
  late ServerConfig? _server = widget.initial;
  var _generation = 0;

  Future<void> _switchTo(ServerConfig? custom) async {
    await widget.store.save(custom);
    final next = widget.store.active;
    if (Supabase.instance.isInitialized) await Supabase.instance.dispose();
    if (next != null) await connectTo(next);
    if (mounted) {
      setState(() {
        _server = next;
        _generation++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final server = _server;
    if (server == null) return _ServerSetupApp(onSave: _switchTo);
    return ProviderScope(
      key: ValueKey(_generation),
      overrides: [
        appDirectoryProvider.overrideWithValue(widget.dataDir),
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
