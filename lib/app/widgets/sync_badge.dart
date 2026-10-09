import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../router.dart';
import '../theme/app_theme.dart';

/// État de synchronisation résumé : icône, couleur et libellé.
({IconData icon, Color color, String label}) describeSync(BuildContext context, SyncState sync, int pending) {
  final t = AppLocalizations.of(context);
  final p = context.palette;
  return switch (sync.phase) {
    SyncPhase.syncing => (icon: Icons.sync, color: p.upcoming, label: t.syncRunning),
    SyncPhase.error => (icon: Icons.cloud_off_outlined, color: p.danger, label: sync.error ?? t.syncFailed),
    SyncPhase.idle when pending > 0 => (
      icon: Icons.cloud_upload_outlined,
      color: p.record,
      label: t.syncPending(pending),
    ),
    SyncPhase.idle => (icon: Icons.cloud_done_outlined, color: p.accent, label: t.syncUpToDate),
  };
}

/// Pastille compacte pour les barres d'en-tête ; ouvre les réglages.
class SyncBadge extends ConsumerWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = describeSync(context, ref.watch(syncControllerProvider), ref.watch(pendingCountProvider).value ?? 0);
    return IconButton(
      tooltip: d.label,
      onPressed: () => context.go(Routes.settings),
      icon: Icon(d.icon, color: d.color),
    );
  }
}
