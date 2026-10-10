import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/backend/backend.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';

/// Gestion des comptes, ou null : réservée au propriétaire d'un serveur personnel.
final serverAccountsProvider = Provider<ServerAccounts?>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(backendProvider).accounts;
});

final _accountListProvider = FutureProvider.autoDispose<List<ServerAccount>>(
  (ref) async => await ref.watch(serverAccountsProvider)?.list() ?? const [],
);

/// Comptes d'un serveur personnel : le propriétaire ajoute ses proches, leur redonne un mot de
/// passe, retire un compte. Chacun ne voit que ses propres courses.
class ServerAccountsScreen extends ConsumerWidget {
  const ServerAccountsScreen({super.key});

  void _say(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  String _describe(AppLocalizations t, AuthError e) => switch (e.reason) {
    AuthFailure.emailTaken => t.accountsEmailTaken,
    AuthFailure.weakPassword => t.settingsPasswordTooShort,
    AuthFailure.rateLimited => t.signInRateLimited,
    _ => t.accountsError,
  };

  /// Saisie d'un e-mail (si [withEmail]) et d'un mot de passe ; [submit] renvoie l'erreur à afficher.
  Future<bool> _ask(
    BuildContext context, {
    required String title,
    String? intro,
    required bool withEmail,
    required Future<String?> Function(String email, String password) submit,
  }) async {
    final t = AppLocalizations.of(context);
    final email = TextEditingController();
    final password = TextEditingController();
    String? error;
    var busy = false;
    final done = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (intro != null) ...[Text(intro), const SizedBox(height: Space.md)],
                if (withEmail) ...[
                  TextField(
                    controller: email,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(labelText: t.emailLabel),
                  ),
                  const SizedBox(height: Space.md),
                ],
                TextField(
                  controller: password,
                  autofocus: !withEmail,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: t.settingsNewPassword,
                    helperText: t.settingsPasswordTooShort,
                    errorText: error,
                    errorMaxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: busy ? null : () => Navigator.pop(ctx, false), child: Text(t.cancel)),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (withEmail && !email.text.contains('@')) {
                        return setState(() => error = t.signInInvalidEmail);
                      }
                      if (password.text.length < 8) return setState(() => error = t.settingsPasswordTooShort);
                      setState(() => busy = true);
                      final failure = await submit(email.text, password.text);
                      if (!ctx.mounted) return;
                      if (failure == null) return Navigator.pop(ctx, true);
                      setState(() {
                        busy = false;
                        error = failure;
                      });
                    },
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );
    email.dispose();
    password.dispose();
    return done ?? false;
  }

  Future<String?> _run(AppLocalizations t, Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on AuthError catch (e) {
      return _describe(t, e);
    } catch (_) {
      return t.accountsError;
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref, ServerAccounts accounts) async {
    final t = AppLocalizations.of(context);
    final created = await _ask(
      context,
      title: t.accountsAdd,
      intro: t.accountsAddIntro,
      withEmail: true,
      submit: (email, password) => _run(t, () => accounts.create(email, password)),
    );
    if (!created || !context.mounted) return;
    ref.invalidate(_accountListProvider);
    _say(context, t.accountsCreated);
  }

  Future<void> _reset(BuildContext context, ServerAccounts accounts, ServerAccount account) async {
    final t = AppLocalizations.of(context);
    final changed = await _ask(
      context,
      title: t.accountsReset,
      intro: account.email,
      withEmail: false,
      submit: (_, password) => _run(t, () => accounts.resetPassword(account.id, password)),
    );
    if (changed && context.mounted) _say(context, t.accountsResetDone);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ServerAccounts accounts, ServerAccount account) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.accountsDelete),
        content: Text(t.accountsDeleteConfirm(account.email)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final failure = await _run(t, () => accounts.delete(account.id));
    if (!context.mounted) return;
    ref.invalidate(_accountListProvider);
    _say(context, failure ?? t.accountsDeleted);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accounts = ref.watch(serverAccountsProvider);
    final me = ref.watch(currentUserProvider).value?.id;
    final list = ref.watch(_accountListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.accountsTitle.toUpperCase())),
      floatingActionButton: accounts == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _add(context, ref, accounts),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(t.accountsAdd),
            ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(padding: const EdgeInsets.all(Space.lg), child: Text(t.accountsError)),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, 96),
          children: [
            Text(t.accountsIntro),
            const SizedBox(height: Space.md),
            for (final account in items)
              Card(
                child: ListTile(
                  leading: Icon(account.isOwner ? Icons.shield_outlined : Icons.person_outline),
                  title: Text(account.email),
                  subtitle: account.isOwner || account.id == me
                      ? Text(
                          [if (account.isOwner) t.accountsOwner, if (account.id == me) t.accountsYou].join(' · '),
                          style: theme.textTheme.bodySmall,
                        )
                      : null,
                  // Son propre compte se gère dans Réglages (mot de passe actuel demandé).
                  trailing: accounts == null || account.id == me
                      ? null
                      : PopupMenuButton<void Function()>(
                          tooltip: t.accountsActions(account.email),
                          onSelected: (action) => action(),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: () => _reset(context, accounts, account),
                              child: ListTile(
                                leading: const Icon(Icons.key_outlined),
                                title: Text(t.accountsReset),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value: () => _delete(context, ref, accounts, account),
                              child: ListTile(
                                leading: const Icon(Icons.delete_outline),
                                title: Text(t.accountsDelete),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
