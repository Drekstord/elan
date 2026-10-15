import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/server/server_config.dart';
import '../../../l10n/app_localizations.dart';

/// Choix du serveur : celui intégré à l'app s'il y en a un, un projet Supabase (adresse et clé
/// publique) ou un serveur personnel (adresse seule). Tout serveur saisi est vérifié avant
/// d'être enregistré.
class ServerScreen extends StatefulWidget {
  /// Serveur en cours (null au tout premier lancement sans serveur intégré).
  final ServerConfig? current;

  /// Serveur intégré à la compilation, s'il y en a un.
  final ServerConfig? builtIn;

  /// Enregistre le choix (null : serveur intégré) et reconnecte l'app.
  final Future<void> Function(ServerConfig? custom) onSave;

  /// Remplaçable dans les tests.
  final Future<ServerCheck> Function(ServerConfig server) check;

  const ServerScreen({
    super.key,
    required this.current,
    required this.builtIn,
    required this.onSave,
    this.check = checkServer,
  });

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

enum _Choice { builtIn, online, personal }

class _ServerScreenState extends State<ServerScreen> {
  late _Choice _choice = _initialChoice();
  late final _address = TextEditingController(text: _choice == _Choice.builtIn ? null : widget.current?.url);
  late final _key = TextEditingController(text: _choice == _Choice.online ? widget.current?.key : null);
  bool _busy = false;
  String? _error;

  _Choice _initialChoice() {
    final current = widget.current;
    if (current != null && current == widget.builtIn) return _Choice.builtIn;
    if (current?.isOnline ?? false) return _Choice.online;
    if (current == null && widget.builtIn != null) return _Choice.builtIn;
    return _Choice.personal;
  }

  @override
  void dispose() {
    _address.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _paste(TextEditingController field) async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text != null) field.text = text.trim();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    if (_choice == _Choice.builtIn) {
      if (widget.current != null && widget.current == widget.builtIn) return Navigator.of(context).pop();
      setState(() => _busy = true);
      return widget.onSave(null);
    }

    final url = normalizeServerAddress(_address.text);
    final online = _choice == _Choice.online;
    final String? error =
        switch (validateServerAddress(url)) {
          ServerAddressError.invalid => t.serverErrorAddress,
          ServerAddressError.httpOnInternet => t.serverErrorHttp,
          null => null,
        } ??
        (!online
            ? null
            : switch (validateOnlineKey(_key.text)) {
                OnlineKeyError.secret => t.serverErrorSecretKey,
                OnlineKeyError.invalid => t.serverErrorKey,
                null => null,
              });
    if (error != null) return setState(() => _error = error);

    final server = online ? ServerConfig.online(url: url, key: _key.text.trim()) : ServerConfig.personal(url);
    if (server == widget.current) return Navigator.of(context).pop();
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.check(server);
    if (!mounted) return;
    if (result != ServerCheck.ok) {
      return setState(() {
        _busy = false;
        _error = switch (result) {
          ServerCheck.tooRecent => t.serverTooRecent,
          ServerCheck.notElan => online ? t.serverNotSupabase : t.serverNotElan,
          ServerCheck.badKey => t.serverBadKey,
          _ => t.serverUnreachable,
        };
      });
    }
    // L'app se reconnecte au nouveau serveur et revient à l'écran de connexion.
    await widget.onSave(server);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final builtIn = widget.builtIn;
    final online = _choice == _Choice.online;

    Widget pasteButton(TextEditingController field) => IconButton(
      tooltip: t.serverPaste,
      icon: const Icon(Icons.content_paste),
      onPressed: _busy ? null : () => _paste(field),
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.serverTitle.toUpperCase())),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(builtIn == null ? t.serverIntroCustomOnly : t.serverIntro),
                  const SizedBox(height: Space.md),
                  RadioGroup<_Choice>(
                    groupValue: _choice,
                    onChanged: (v) {
                      if (!_busy && v != null) {
                        setState(() {
                          _choice = v;
                          _error = null;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        if (builtIn != null)
                          RadioListTile<_Choice>(
                            value: _Choice.builtIn,
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.serverBuiltIn),
                            subtitle: Text(t.serverBuiltInHint),
                          ),
                        RadioListTile<_Choice>(
                          value: _Choice.personal,
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.serverCustom),
                          subtitle: Text(t.serverCustomHint),
                        ),
                        RadioListTile<_Choice>(
                          value: _Choice.online,
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.serverOnline),
                          subtitle: Text(t.serverOnlineHint),
                        ),
                      ],
                    ),
                  ),
                  if (_choice != _Choice.builtIn) ...[
                    const SizedBox(height: Space.md),
                    TextField(
                      controller: _address,
                      enabled: !_busy,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      onSubmitted: (_) => online ? null : _save(),
                      decoration: InputDecoration(
                        labelText: t.serverAddress,
                        hintText: online ? t.serverOnlineAddressHint : t.serverAddressHint,
                        prefixIcon: const Icon(Icons.dns_outlined),
                        suffixIcon: pasteButton(_address),
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    if (!online) Text(t.serverAddressHelp, style: theme.textTheme.bodySmall),
                  ],
                  if (online) ...[
                    const SizedBox(height: Space.sm),
                    TextField(
                      controller: _key,
                      enabled: !_busy,
                      autocorrect: false,
                      enableSuggestions: false,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: t.serverOnlineKey,
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: pasteButton(_key),
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(t.serverOnlineKeyHelp, style: theme.textTheme.bodySmall),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: Space.md),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: Space.lg),
                  FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: Space.md)),
                    icon: _busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_busy ? t.serverChecking : (_choice == _Choice.builtIn ? t.save : t.serverSave)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nom du serveur pour l'affichage : « Serveur ÉLAN » pour celui intégré à l'app, sinon son adresse.
String serverName(AppLocalizations t, ServerConfig server, {ServerConfig? builtIn}) =>
    server == builtIn ? t.serverBuiltIn : server.displayAddress;
