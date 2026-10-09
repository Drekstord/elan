import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/reminders/domain/race_reminders.dart';
import '../features/reminders/reminder_service.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/tokens.dart';

/// Coque de l'espace connecté : barre latérale sur grand écran, barre du bas sur téléphone.
/// Prépare aussi la session (reprise v1, première synchro) et resynchronise au retour dans l'app.
class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (ref.read(userIdProvider) != null) ref.read(syncControllerProvider.notifier).sync();
        _reschedule();
      },
    );
    _initReminders();
  }

  /// Rappels du soir de la course (Android) : un appui ouvre la fiche de la course.
  Future<void> _initReminders() async {
    if (!supportsReminders) return;
    try {
      final launchedFor = await ReminderService.instance.init(_openCourse);
      if (launchedFor != null) _openCourse(launchedFor);
      _reschedule();
    } catch (error) {
      // Les rappels sont un confort : leur échec ne doit jamais empêcher l'app de fonctionner.
      debugPrint('Rappels indisponibles : $error');
    }
  }

  void _openCourse(String courseId) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) GoRouter.of(context).push(Routes.course(courseId));
    });
  }

  /// Reprogramme les rappels d'après les courses et le réglage du moment.
  void _reschedule() {
    if (!supportsReminders || !mounted) return;
    final settings = ref.read(reminderSettingsProvider);
    final courses = ref.read(coursesProvider).value;
    if (courses == null) return;
    final t = AppLocalizations.of(context);
    ReminderService.instance.schedule(
      settings.enabled
          ? raceReminders(courses, now: DateTime.now(), hour: settings.hour, minute: settings.minute)
          : const [],
      title: t.reminderTitle,
      body: t.reminderBody,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (ref.watch(userIdProvider) == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Les rappels suivent les courses (ajout, date, résultat saisi…) et le réglage.
    ref.listen(coursesProvider, (_, _) => _reschedule());
    ref.listen(reminderSettingsProvider, (_, _) => _reschedule());

    ref.listen(sessionBootstrapProvider, (_, next) {
      final imported = next.value ?? 0;
      if (imported > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.syncImported(imported))));
      }
    });
    final bootstrap = ref.watch(sessionBootstrapProvider);
    if (bootstrap.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final destinations = [
      (Icons.directions_run_outlined, Icons.directions_run, t.navCourses),
      (Icons.insights_outlined, Icons.insights, t.navEvolution),
      (Icons.favorite_outline, Icons.favorite, t.navImpact),
      (Icons.emoji_events_outlined, Icons.emoji_events, t.navRecords),
      (Icons.settings_outlined, Icons.settings, t.navSettings),
    ];
    void go(int index) => widget.shell.goBranch(index, initialLocation: index == widget.shell.currentIndex);

    if (MediaQuery.sizeOf(context).width >= kWideLayout) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (icon, selected, label) in destinations)
                  NavigationRailDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: Text(label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.shell.currentIndex,
        onDestinationSelected: go,
        destinations: [
          for (final (icon, selected, label) in destinations)
            NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: label),
        ],
      ),
    );
  }
}
