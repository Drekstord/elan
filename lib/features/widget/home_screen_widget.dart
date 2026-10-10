import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../courses/domain/course.dart';
import '../courses/domain/course_stats.dart';

/// Widget de l'écran d'accueil Android (android/.../ElanWidget.kt) : prochaine course avec son
/// compte à rebours, et kilomètres de l'année. L'app lui transmet ces données à chaque changement ;
/// le widget recalcule seul le compte à rebours chaque jour.
bool get supportsHomeWidget => !kIsWeb && Platform.isAndroid;

class HomeWidgetData {
  final String? nextTitle;

  /// Jour de la prochaine course (date de calendrier, UTC à minuit).
  final DateTime? nextDate;
  final int year;
  final int yearDistanceM;

  /// Objectif annuel en mètres, s'il y en a un.
  final int? goalM;

  const HomeWidgetData({this.nextTitle, this.nextDate, required this.year, required this.yearDistanceM, this.goalM});

  /// Kilomètres de l'année tels qu'affichés : « 1 234 », ou « 207 / 500 » avec un objectif.
  String get yearKm {
    String km(int meters) => NumberFormat.decimalPattern('fr').format((meters / 1000).round());
    return goalM == null ? km(yearDistanceM) : '${km(yearDistanceM)} / ${km(goalM!)}';
  }

  Map<String, Object?> toMap() => {
    'nextTitle': nextTitle,
    // Jours depuis le 1er janvier 1970 : le widget compare avec le jour courant, sans fuseau.
    'nextEpochDay': nextDate == null ? null : nextDate!.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay,
    'year': year,
    'yearKm': yearKm,
  };

  @override
  bool operator ==(Object other) =>
      other is HomeWidgetData &&
      other.nextTitle == nextTitle &&
      other.nextDate == nextDate &&
      other.year == year &&
      other.yearDistanceM == yearDistanceM &&
      other.goalM == goalM;

  @override
  int get hashCode => Object.hash(nextTitle, nextDate, year, yearDistanceM, goalM);
}

/// Prochaine course à venir (la plus proche) et distance des courses terminées de l'année.
HomeWidgetData homeWidgetData(Iterable<Course> courses, DateTime today, {int? goalM}) {
  final upcoming = courses.where((c) => c.statusOn(today) == CourseStatus.upcoming).toList()
    ..sort((a, b) => a.raceDate.compareTo(b.raceDate));
  final next = upcoming.firstOrNull;
  final ofYear = CourseStats.of(courses.where((c) => !c.isDeleted && c.raceDate.year == today.year));
  return HomeWidgetData(
    nextTitle: next?.title,
    nextDate: next?.raceDate,
    year: today.year,
    yearDistanceM: ofYear.distanceM,
    goalM: goalM,
  );
}

const _channel = MethodChannel('elan/widget');
HomeWidgetData? _sent;

/// Transmet les données au widget si elles ont changé. Sans effet hors Android.
Future<void> updateHomeWidget(HomeWidgetData data) async {
  if (!supportsHomeWidget || data == _sent) return;
  try {
    await _channel.invokeMethod<void>('update', data.toMap());
    _sent = data;
  } catch (error) {
    // Le widget est un confort : son échec ne doit jamais gêner l'app.
    debugPrint('Widget indisponible : $error');
  }
}
