import 'course.dart';

/// Plafonds d'impact annoncés par The Conqueror pour un défi.
class ConquerorRules {
  static const double maxTrees = 4;
  static const double maxBottles = 40;

  static double? capFor(ImpactMetric metric) => switch (metric) {
    ImpactMetric.trees => maxTrees,
    ImpactMetric.oceanBottles => maxBottles,
    _ => null,
  };

  /// Part personnelle d'un défi en équipe : distance totale divisée par la taille de l'équipe.
  static int personalShareM(int challengeDistanceM, int teamSize) =>
      teamSize <= 1 ? challengeDistanceM : (challengeDistanceM / teamSize).round();
}

enum CourseIssue {
  missingTitle,
  distanceNotPositive,
  negativeDuration,
  negativeElevation,

  /// Course terminée datée dans le futur : elle devrait être « à venir ».
  completedInFuture,

  /// Course à venir avec un chrono : elle devrait être marquée terminée.
  plannedWithResult,
  teamSizeInvalid,
  impactQuantityNotPositive,

  /// Quantité déclarée au-delà du plafond annoncé (défi The Conqueror).
  impactAboveCap,
}

/// Contrôles avant enregistrement. Une liste vide = course valide.
List<CourseIssue> validateCourse(Course c, {required DateTime today}) => [
  if (c.title.trim().isEmpty) CourseIssue.missingTitle,
  if (c.distanceM <= 0) CourseIssue.distanceNotPositive,
  if (c.durationS < 0) CourseIssue.negativeDuration,
  if ((c.elevationGainM ?? 0) < 0) CourseIssue.negativeElevation,
  if (!c.isPlanned && c.raceDate.isAfter(today)) CourseIssue.completedInFuture,
  if (c.isPlanned && c.durationS > 0) CourseIssue.plannedWithResult,
  if (c.teamSize != null && c.teamSize! < 1) CourseIssue.teamSizeInvalid,
  if (c.impactQuantity != null && c.impactQuantity! <= 0) CourseIssue.impactQuantityNotPositive,
  if (c.type == CourseType.theConqueror &&
      c.impactQuantity != null &&
      (ConquerorRules.capFor(c.impactMetric) ?? double.infinity) < c.impactQuantity!)
    CourseIssue.impactAboveCap,
];

/// Saisie du résultat d'une course à venir : elle devient une course terminée.
Course completeWithResult(Course planned, {required int durationS, int? distanceM, int? elevationGainM}) =>
    planned.copyWith(
      isPlanned: false,
      durationS: durationS,
      distanceM: distanceM ?? planned.distanceM,
      elevationGainM: elevationGainM ?? planned.elevationGainM,
    );
