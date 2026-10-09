import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'domain/race_reminders.dart';

/// Les rappels n'existent que sur le téléphone.
/// (Système réel : les tests, qui simulent Android, n'ont pas de module natif.)
bool get supportsReminders => !kIsWeb && Platform.isAndroid;

/// Réglage des rappels : activés (par défaut) et heure du rappel (20 h par défaut).
class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSettings({this.enabled = true, this.hour = 20, this.minute = 0});

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute}) =>
      ReminderSettings(enabled: enabled ?? this.enabled, hour: hour ?? this.hour, minute: minute ?? this.minute);
}

class ReminderSettingsController extends Notifier<ReminderSettings> {
  static const _enabled = 'reminder_enabled', _hour = 'reminder_hour', _minute = 'reminder_minute';

  @override
  ReminderSettings build() {
    SharedPreferences.getInstance().then((prefs) {
      if (!ref.mounted) return;
      state = ReminderSettings(
        enabled: prefs.getBool(_enabled) ?? true,
        hour: prefs.getInt(_hour) ?? 20,
        minute: prefs.getInt(_minute) ?? 0,
      );
    });
    return const ReminderSettings();
  }

  Future<void> setEnabled(bool value) async {
    if (value) await ReminderService.instance.requestPermission();
    state = state.copyWith(enabled: value);
    await (await SharedPreferences.getInstance()).setBool(_enabled, value);
  }

  Future<void> setTime(int hour, int minute) async {
    state = state.copyWith(hour: hour, minute: minute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hour, hour);
    await prefs.setInt(_minute, minute);
  }
}

final reminderSettingsProvider = NotifierProvider<ReminderSettingsController, ReminderSettings>(
  ReminderSettingsController.new,
);

/// Programme les notifications locales (flutter_local_notifications).
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'race_reminder',
    'Rappel de course',
    channelDescription: 'Le soir de la course, pour saisir ton temps.',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_launcher_monochrome',
  );

  /// Prépare le module ; [onOpen] reçoit l'identifiant de la course quand on appuie
  /// sur un rappel. Renvoie la course qui a lancé l'app, le cas échéant.
  Future<String?> init(void Function(String courseId) onOpen) async {
    if (!supportsReminders || _ready) return null;
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_launcher_monochrome')),
      onDidReceiveNotificationResponse: (response) {
        final id = response.payload;
        if (id != null && id.isNotEmpty) onOpen(id);
      },
    );
    _ready = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true ? launch!.notificationResponse?.payload : null;
  }

  Future<void> requestPermission() async {
    if (!supportsReminders) return;
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Remplace tous les rappels programmés par [reminders].
  Future<void> schedule(
    List<RaceReminder> reminders, {
    required String Function(String title) title,
    required String body,
  }) async {
    if (!supportsReminders || !_ready) return;
    try {
      await _replace(reminders, title: title, body: body);
    } catch (error) {
      // Appelée sans attente (à chaque changement des courses) : l'erreur ne doit pas remonter.
      debugPrint('Rappels non programmés : $error');
    }
  }

  Future<void> _replace(
    List<RaceReminder> reminders, {
    required String Function(String title) title,
    required String body,
  }) async {
    await _plugin.cancelAll();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: title(r.courseTitle),
        body: body,
        payload: r.courseId,
        // Instant absolu : l'heure locale voulue convertie en UTC (heure d'été comprise).
        scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
        notificationDetails: const NotificationDetails(android: _channel),
        // « Vers » l'heure voulue, même en veille, sans autorisation d'alarme exacte.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
