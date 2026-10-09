import 'package:flutter/material.dart';

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
  };

  IconData get icon => switch (this) {
    CourseType.officialRace => Icons.directions_run,
    CourseType.theConqueror => Icons.flag_outlined,
  };
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
