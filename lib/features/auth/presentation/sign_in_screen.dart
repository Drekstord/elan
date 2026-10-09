import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../core/server/server_config.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_repository.dart';
import 'server_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    if (!_email.text.contains('@')) return setState(() => _error = t.signInInvalidEmail);
    if (_password.text.isEmpty) return setState(() => _error = t.signInMissingPassword);

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // En cas de succès, le routeur bascule vers l'accueil.
      await ref.read(authRepositoryProvider).signIn(_email.text, _password.text);
    } on AuthError catch (e) {
      if (mounted) {
        setState(
          () => _error = switch (e.reason) {
            AuthFailure.wrongCredentials => t.signInWrongCredentials,
            AuthFailure.rateLimited => t.signInRateLimited,
            AuthFailure.offline => t.signInOffline,
            _ => e.detail ?? t.signInOffline,
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final server = ref.watch(serverChoiceProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Space.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Réduit au besoin (téléphone étroit, textes agrandis) au lieu de déborder.
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Wordmark(size: 72),
                    ),
                    const SizedBox(height: Space.md),
                    Kicker(t.appTagline, color: theme.colorScheme.onSurface, size: 18),
                    const SizedBox(height: Space.xl),
                    Text(t.signInIntro),
                    const SizedBox(height: Space.lg),
                    TextField(
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: t.emailLabel,
                        prefixIcon: const Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    TextField(
                      controller: _password,
                      enabled: !_busy,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: t.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? t.signInShowPassword : t.signInHidePassword,
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: Space.md),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: Space.lg),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: Space.md)),
                      child: _busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(t.signInButton),
                    ),
                    const SizedBox(height: Space.md),
                    Text(
                      (server?.current.builtIn ?? true) ? t.signInForgotten : t.signInForgottenCustom,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (server != null) ...[
                      const SizedBox(height: Space.lg),
                      Center(
                        child: TextButton.icon(
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    fullscreenDialog: true,
                                    builder: (_) => ServerScreen(
                                      current: server.current,
                                      builtIn: server.builtIn,
                                      onSave: server.switchTo,
                                    ),
                                  ),
                                ),
                          icon: const Icon(Icons.dns_outlined, size: 18),
                          label: Text(t.serverLabel(serverName(t, server.current))),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
