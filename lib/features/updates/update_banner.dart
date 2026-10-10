import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'update_check.dart';

/// Cherche une nouvelle version et, s'il y en a une, l'annonce dans un bandeau en haut de l'écran.
/// [manual] : demandé depuis les Réglages (on répond aussi quand tout est à jour).
Future<void> checkForUpdate(BuildContext context, WidgetRef ref, {bool manual = false}) async {
  final messenger = ScaffoldMessenger.of(context);
  final t = AppLocalizations.of(context);
  final update = await ref.read(updateProvider.notifier).check(force: manual);
  if (update == null) {
    if (manual) messenger.showSnackBar(SnackBar(content: Text(t.updateUpToDate)));
    return;
  }
  messenger.showMaterialBanner(
    MaterialBanner(
      leading: const Icon(Icons.system_update_outlined),
      content: Text(t.updateAvailable(update.version)),
      actions: [
        TextButton(
          onPressed: () {
            messenger.hideCurrentMaterialBanner();
            ref.read(updateProvider.notifier).dismiss();
          },
          child: Text(t.updateLater),
        ),
        FilledButton.icon(
          onPressed: () {
            messenger.hideCurrentMaterialBanner();
            launchUrl(Uri.parse(update.downloadUrl), mode: LaunchMode.externalApplication);
          },
          icon: const Icon(Icons.download_outlined),
          label: Text(t.updateDownload),
        ),
      ],
    ),
  );
}
