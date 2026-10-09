import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app.dart';
import '../../../app/theme/theme_mode.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/sync_badge.dart';
import '../../../core/providers.dart';
import '../../../core/server/server_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/widgets/image_export.dart';
import '../../courses/domain/course.dart';
import '../backup.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/server_screen.dart';
import '../../reminders/reminder_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.navSettings.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(Space.md),
        children: [
          const _SyncCard(),
          const SizedBox(height: Space.md),
          const _BackupCard(),
          const SizedBox(height: Space.md),
          const _AccountCard(),
          const SizedBox(height: Space.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.settingsAppearance, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Space.md),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(t.themeSystem),
                        icon: const Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(t.themeLight),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(t.themeDark),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {ref.watch(themeModeProvider)},
                    onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
                  ),
                  if (supportsReminders) ...[const SizedBox(height: Space.md), const _ReminderSettings()],
                  if (supportsWallpaperColors) ...[
                    const SizedBox(height: Space.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.settingsWallpaperColors),
                      subtitle: Text(t.settingsWallpaperColorsHint),
                      value: ref.watch(wallpaperColorsProvider),
                      onChanged: ref.read(wallpaperColorsProvider.notifier).set,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncCard extends ConsumerWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final sync = ref.watch(syncControllerProvider);
    final d = describeSync(context, sync, ref.watch(pendingCountProvider).value ?? 0);
    final last = sync.lastSuccess;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.syncTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Icon(d.icon, color: d.color, size: 20),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    d.label,
                    style: TextStyle(color: d.color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (last != null) ...[
              const SizedBox(height: Space.xs),
              Text(
                t.syncLast(DateFormat('d MMM y, HH:mm', 'fr').format(last.toLocal())),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: Space.md),
            FilledButton.icon(
              onPressed: sync.phase == SyncPhase.syncing
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).sync(),
              icon: const Icon(Icons.sync),
              label: Text(t.syncNow),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    String? error;
    final changed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(t.settingsChangePassword),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: t.settingsNewPassword, errorText: error),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
            FilledButton(
              onPressed: () async {
                if (controller.text.length < 8) return setState(() => error = t.settingsPasswordTooShort);
                try {
                  await ref.read(authRepositoryProvider).changePassword(controller.text);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } on AuthError catch (e) {
                  setState(() => error = e.detail ?? t.signInOffline);
                }
              },
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.settingsPasswordChanged)));
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final pending = ref.read(pendingCountProvider).value ?? 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.settingsSignOutTitle),
        content: Text(pending > 0 ? t.settingsSignOutPending(pending) : t.settingsSignOutClean),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.settingsSignOut)),
        ],
      ),
    );
    if (ok == true) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final email = ref.watch(currentUserProvider).value?.email ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.settingsAccount, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Space.sm),
            Text(t.settingsSignedInAs(email)),
            // Pour changer de serveur : se déconnecter, puis « Serveur » sur l'écran de connexion.
            if (ref.watch(serverChoiceProvider)?.current case final server?) ...[
              const SizedBox(height: Space.xs),
              Text(t.serverLabel(serverName(t, server)), style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _changePassword(context, ref),
                  icon: const Icon(Icons.key_outlined),
                  label: Text(t.settingsChangePassword),
                ),
                OutlinedButton.icon(
                  onPressed: () => _signOut(context, ref),
                  icon: const Icon(Icons.logout),
                  label: Text(t.settingsSignOut),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rappel le soir de la course : activé / désactivé, heure.
class _ReminderSettings extends ConsumerWidget {
  const _ReminderSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final settings = ref.watch(reminderSettingsProvider);
    final controller = ref.read(reminderSettingsProvider.notifier);
    final time = TimeOfDay(hour: settings.hour, minute: settings.minute);
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_active_outlined),
          title: Text(t.reminderSetting),
          subtitle: Text(t.reminderSettingHint(time.format(context))),
          value: settings.enabled,
          onChanged: controller.setEnabled,
        ),
        if (settings.enabled)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(t.reminderTime),
            trailing: Text(time.format(context), style: Theme.of(context).textTheme.titleMedium),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: time);
              if (picked != null) await controller.setTime(picked.hour, picked.minute);
            },
          ),
      ],
    );
  }
}

/// Sauvegarde de toutes les courses en Excel ou en CSV (copie gardée par l'utilisateur).
class _BackupCard extends ConsumerWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final now = DateTime.now();
    final today = calendarDate(now.year, now.month, now.day);
    final stamp = formatIsoDate(today);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.backupSection, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Space.xs),
            Text(t.backupHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                FilledButton.icon(
                  onPressed: courses.isEmpty
                      ? null
                      : () => exportFile(
                          context,
                          backupWorkbook(courses, t, today: today),
                          fileName: 'elan-sauvegarde-$stamp.xlsx',
                          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                          extension: 'xlsx',
                        ),
                  icon: const Icon(Icons.grid_on),
                  label: Text(t.backupExcel),
                ),
                OutlinedButton.icon(
                  onPressed: courses.isEmpty
                      ? null
                      : () => exportFile(
                          context,
                          backupCsv(courses, t, today: today),
                          fileName: 'elan-sauvegarde-$stamp.csv',
                          mimeType: 'text/csv',
                          extension: 'csv',
                        ),
                  icon: const Icon(Icons.description_outlined),
                  label: Text(t.backupCsv),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
