import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/server/server_config.dart';
import '../../../l10n/app_localizations.dart';

/// Choix du serveur : celui d'ÉLAN (intégré) ou un serveur personnel, désigné par son adresse.
/// Le serveur personnel est vérifié avant d'être enregistré.
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

class _ServerScreenState extends State<ServerScreen> {
  late bool _custom = widget.builtIn == null || !(widget.current?.builtIn ?? true);
  late final _address = TextEditingController(text: _custom ? widget.current?.url : null);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text != null) _address.text = text.trim();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    if (!_custom) {
      if (widget.current?.builtIn ?? false) return Navigator.of(context).pop();
      setState(() => _busy = true);
      return widget.onSave(null);
    }

    final url = normalizeServerAddress(_address.text);
    final String? error = switch (validateServerAddress(url)) {
      ServerAddressError.invalid => t.serverErrorAddress,
      ServerAddressError.httpOnInternet => t.serverErrorHttp,
      null => null,
    };
    if (error != null) return setState(() => _error = error);

    final server = ServerConfig.personal(url);
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
          ServerCheck.notElan => t.serverNotElan,
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
                  if (builtIn != null)
                    RadioGroup<bool>(
                      groupValue: _custom,
                      onChanged: (v) {
                        if (!_busy) setState(() => _custom = v ?? false);
                      },
                      child: Column(
                        children: [
                          RadioListTile<bool>(
                            value: false,
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.serverBuiltIn),
                            subtitle: Text(t.serverBuiltInHint),
                          ),
                          RadioListTile<bool>(
                            value: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.serverCustom),
                            subtitle: Text(t.serverCustomHint),
                          ),
                        ],
                      ),
                    ),
                  if (_custom) ...[
                    const SizedBox(height: Space.md),
                    TextField(
                      controller: _address,
                      enabled: !_busy,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: t.serverAddress,
                        hintText: t.serverAddressHint,
                        prefixIcon: const Icon(Icons.dns_outlined),
                        suffixIcon: IconButton(
                          tooltip: t.serverPaste,
                          icon: const Icon(Icons.content_paste),
                          onPressed: _busy ? null : _paste,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(t.serverAddressHelp, style: theme.textTheme.bodySmall),
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
                    label: Text(_busy ? t.serverChecking : (_custom ? t.serverSave : t.save)),
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

/// Nom du serveur pour l'affichage : « Serveur ÉLAN » ou son adresse.
String serverName(AppLocalizations t, ServerConfig server) => server.builtIn ? t.serverBuiltIn : server.displayAddress;
