import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../features/courses/domain/course.dart';
import '../features/records/domain/personal_records.dart';
import '../l10n/app_localizations.dart';

/// Libellés et icônes des notions métier (le domaine reste sans Flutter).

extension CauseLabel on CauseType {
  String label(AppLocalizations t) => switch (this) {
    CauseType.sante => t.causeSante,
    CauseType.environnement => t.causeEnvironnement,
    CauseType.precarite => t.causePrecarite,
    CauseType.enfance => t.causeEnfance,
    CauseType.animaux => t.causeAnimaux,
    CauseType.handicap => t.causeHandicap,
    CauseType.autre => t.causeAutre,
  };

  IconData get icon => switch (this) {
    CauseType.sante => Icons.biotech_outlined,
    CauseType.environnement => Icons.eco_outlined,
    CauseType.precarite => Icons.soup_kitchen_outlined,
    CauseType.enfance => Icons.child_care_outlined,
    CauseType.animaux => Icons.pets_outlined,
    CauseType.handicap => Icons.accessible_forward_outlined,
    CauseType.autre => Icons.volunteer_activism_outlined,
  };
}

extension MetricLabel on ImpactMetric {
  String label(AppLocalizations t) => switch (this) {
    ImpactMetric.trees => t.metricTrees,
    ImpactMetric.oceanBottles => t.metricOceanBottles,
    ImpactMetric.careSessions => t.metricCareSessions,
    ImpactMetric.researchHours => t.metricResearchHours,
    ImpactMetric.meals => t.metricMeals,
    ImpactMetric.careKits => t.metricCareKits,
    ImpactMetric.animalMeals => t.metricAnimalMeals,
    ImpactMetric.euroDirect => t.metricNone,
  };

  IconData get icon => switch (this) {
    ImpactMetric.trees => Icons.park_outlined,
    ImpactMetric.oceanBottles => Icons.water_drop_outlined,
    ImpactMetric.careSessions => Icons.healing_outlined,
    ImpactMetric.researchHours => Icons.science_outlined,
    ImpactMetric.meals => Icons.restaurant_outlined,
    ImpactMetric.careKits => Icons.medical_services_outlined,
    ImpactMetric.animalMeals => Icons.pets_outlined,
    ImpactMetric.euroDirect => Icons.euro_outlined,
  };
}

extension CourseTypeLabel on CourseType {
  String label(AppLocalizations t) => switch (this) {
    CourseType.officialRace => t.typeOfficial,
    CourseType.theConqueror => t.typeConqueror,
    CourseType.multisport => t.typeMultisport,
  };

  /// Libellé court, pour le choix du type dans le formulaire.
  String shortLabel(AppLocalizations t) => switch (this) {
    CourseType.officialRace => t.typeShortOfficial,
    CourseType.theConqueror => t.typeShortConqueror,
    CourseType.multisport => t.typeShortMultisport,
  };

  IconData get icon => switch (this) {
    CourseType.officialRace => Icons.directions_run,
    CourseType.theConqueror => Icons.flag_outlined,
    CourseType.multisport => Icons.pool,
  };
}

extension MultisportKindLabel on MultisportKind {
  String label(AppLocalizations t) => switch (this) {
    MultisportKind.triathlon => t.multisportTriathlon,
    MultisportKind.duathlon => t.multisportDuathlon,
    MultisportKind.aquathlon => t.multisportAquathlon,
  };
}

extension SportLabel on Sport {
  String label(AppLocalizations t) => switch (this) {
    Sport.swim => t.sportSwim,
    Sport.bike => t.sportBike,
    Sport.run => t.sportRun,
  };

  IconData get icon => switch (this) {
    Sport.swim => Icons.pool,
    Sport.bike => Icons.directions_bike,
    Sport.run => Icons.directions_run,
  };
}

extension MultisportLabel on Multisport {
  /// « Triathlon S », « Duathlon » (format libre).
  String title(AppLocalizations t) => format == null ? kind.label(t) : '${kind.label(t)} $format';

  /// Nom de la discipline n° [index] ; les disciplines répétées sont numérotées (duathlon).
  String legLabel(int index, AppLocalizations t) => sportLabelAt(kind.sports, index, t);
}

/// Nom de la discipline n° [index] d'un enchaînement ; les disciplines répétées sont numérotées.
String sportLabelAt(List<Sport> sports, int index, AppLocalizations t) {
  final sport = sports[index];
  if (sports.where((s) => s == sport).length < 2) return sport.label(t);
  final rank = sports.take(index + 1).where((s) => s == sport).length;
  return sport == Sport.run ? t.sportRunNumbered(rank) : '${sport.label(t)} $rank';
}

/// Détail d'une épreuve enchaînée en une ligne, pour les exports :
/// « Natation 750 m 15:30 · Transition 1 2:10 · Vélo 20 km 40:12 · Course à pied 5 km 26:05 ».
String multisportSummary(Multisport m, AppLocalizations t) {
  String meters(int v) => '${NumberFormat('#,##0', 'fr').format(v)} m';
  String km(int v) => '${NumberFormat('#,##0.##', 'fr').format(v / 1000)} km';
  String time(int s) {
    String two(int v) => v.toString().padLeft(2, '0');
    return s >= 3600 ? '${s ~/ 3600}:${two(s % 3600 ~/ 60)}:${two(s % 60)}' : '${two(s ~/ 60)}:${two(s % 60)}';
  }

  return [
    for (var i = 0; i < m.legs.length; i++) ...[
      [
        m.legLabel(i, t),
        m.legs[i].sport == Sport.swim ? meters(m.legs[i].distanceM) : km(m.legs[i].distanceM),
        if (m.legs[i].durationS > 0) time(m.legs[i].durationS),
        if (m.legIncludesTransition(i) && m.legs[i].durationS > 0) '(${t.multisportTransitionIncludedNote})',
      ].join(' '),
      if (i < m.transitionsS.length && m.transitionsS[i] > 0)
        '${t.multisportTransition(i + 1)} ${time(m.transitionsS[i])}',
    ],
  ].join(' · ');
}

extension CourseLabel on Course {
  /// Nature de la course en clair : « Course officielle », « Triathlon S »…
  String typeLabel(AppLocalizations t) => multisport?.title(t) ?? type.label(t);
}

extension StatusLabel on CourseStatus {
  String label(AppLocalizations t) => switch (this) {
    CourseStatus.upcoming => t.statusUpcoming,
    CourseStatus.awaitingResult => t.statusAwaiting,
    CourseStatus.completed => t.statusCompleted,
  };
}

extension DistanceLabel on StandardDistance {
  String label(AppLocalizations t) => switch (this) {
    StandardDistance.fiveK => t.distance5k,
    StandardDistance.tenK => t.distance10k,
    StandardDistance.halfMarathon => t.distanceHalf,
    StandardDistance.marathon => t.distanceMarathon,
  };
}
