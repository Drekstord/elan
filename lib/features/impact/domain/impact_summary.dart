import '../../courses/domain/course.dart';

/// Bilan solidaire : argent réellement engagé et équivalences déclarées.
/// Aucune quantité n'est extrapolée à partir des kilomètres.
class ImpactSummary {
  final int donationCents;
  final int charityCount;

  /// Kilomètres courus pour une cause (mètres).
  final int charityDistanceM;

  /// Quantités déclarées, par unité (ex. trees -> 8).
  final Map<ImpactMetric, double> declared;

  final Map<CauseType, int> distanceByCause;
  final Map<CauseType, int> donationByCause;

  /// Associations soutenues, par ordre alphabétique.
  final List<String> associations;

  /// Causes dont au moins une course a une équivalence annoncée.
  final Set<CauseType> causesWithDeclared;

  const ImpactSummary({
    required this.donationCents,
    required this.charityCount,
    required this.charityDistanceM,
    required this.declared,
    required this.distanceByCause,
    required this.donationByCause,
    required this.associations,
    this.causesWithDeclared = const {},
  });

  /// Les chiffres mis en avant, une place égale pour chaque cause :
  /// les équivalences annoncées (arbres, bouteilles…), puis, pour chaque cause
  /// qui n'en a pas, les kilomètres courus pour elle.
  List<ImpactHighlight> get highlights {
    final declaredList = declared.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final causes = distanceByCause.entries.where((e) => !causesWithDeclared.contains(e.key)).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in declaredList) DeclaredHighlight(e.key, e.value),
      for (final e in causes) CauseDistanceHighlight(e.key, e.value),
    ];
  }

  factory ImpactSummary.of(Iterable<Course> courses) {
    var cents = 0, count = 0, distance = 0;
    final declared = <ImpactMetric, double>{};
    final byCauseDistance = <CauseType, int>{};
    final byCauseDonation = <CauseType, int>{};
    final associations = <String>{};
    final causesWithDeclared = <CauseType>{};

    for (final c in courses.where((c) => c.isCompleted && c.isCharity)) {
      count++;
      cents += c.donationCents;
      distance += c.distanceM;
      final quantity = c.impactQuantity;
      if (quantity != null && c.impactMetric != ImpactMetric.euroDirect) {
        declared[c.impactMetric] = (declared[c.impactMetric] ?? 0) + quantity;
        if (c.associationCause != null) causesWithDeclared.add(c.associationCause!);
      }
      final cause = c.associationCause;
      if (cause != null) {
        byCauseDistance[cause] = (byCauseDistance[cause] ?? 0) + c.distanceM;
        byCauseDonation[cause] = (byCauseDonation[cause] ?? 0) + c.donationCents;
      }
      final name = c.associationName?.trim();
      if (name != null && name.isNotEmpty) associations.add(name);
    }

    return ImpactSummary(
      donationCents: cents,
      charityCount: count,
      charityDistanceM: distance,
      declared: declared,
      distanceByCause: byCauseDistance,
      donationByCause: byCauseDonation,
      associations: associations.toList()..sort(),
      causesWithDeclared: causesWithDeclared,
    );
  }
}

/// Un chiffre mis en avant dans le bilan solidaire.
sealed class ImpactHighlight {
  const ImpactHighlight();
}

/// Équivalence annoncée par l'organisateur (ex. 13 arbres plantés).
class DeclaredHighlight extends ImpactHighlight {
  final ImpactMetric metric;
  final double quantity;

  const DeclaredHighlight(this.metric, this.quantity);
}

/// Kilomètres courus pour une cause sans équivalence annoncée.
class CauseDistanceHighlight extends ImpactHighlight {
  final CauseType cause;
  final int meters;

  const CauseDistanceHighlight(this.cause, this.meters);
}
