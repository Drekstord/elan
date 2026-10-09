import '../../../core/text.dart';
import '../../courses/domain/course.dart';

/// Tout ce qui a été fait pour une association : courses solidaires terminées,
/// argent engagé, kilomètres, causes, équivalences annoncées, justificatifs.
class AssociationSummary {
  /// Nom affiché (celui de la course la plus récente).
  final String name;

  /// Courses terminées pour cette association, de la plus ancienne à la plus récente.
  final List<Course> courses;

  AssociationSummary(this.name, this.courses);

  int get donationCents => courses.fold(0, (sum, c) => sum + c.donationCents);
  int get distanceM => courses.fold(0, (sum, c) => sum + c.distanceM);
  DateTime get first => courses.first.raceDate;
  DateTime get last => courses.last.raceDate;

  /// Causes soutenues, sans doublon.
  List<CauseType> get causes => {for (final c in courses) ?c.associationCause}.toList();

  /// Équivalences annoncées cumulées (ex. arbres -> 13).
  Map<ImpactMetric, double> get declared {
    final result = <ImpactMetric, double>{};
    for (final c in courses) {
      final q = c.impactQuantity;
      if (q != null && q > 0 && c.impactMetric != ImpactMetric.euroDirect) {
        result[c.impactMetric] = (result[c.impactMetric] ?? 0) + q;
      }
    }
    return result;
  }

  int get documentCount => courses.fold(0, (sum, c) => sum + c.documents.length);
}

/// Clé de regroupement : même association malgré la casse ou les accents
/// (« LES COQUELICOTS… » et « Les Coquelicots… »).
String associationKey(String name) => fold(name.trim());

/// Récapitulatif de chaque association soutenue (courses solidaires terminées),
/// de la plus soutenue (argent engagé) à la moins soutenue.
List<AssociationSummary> associationSummaries(Iterable<Course> courses) {
  final groups = <String, List<Course>>{};
  for (final c in courses) {
    final name = c.associationName?.trim();
    if (c.isDeleted || !c.isCompleted || !c.isCharity || name == null || name.isEmpty) continue;
    (groups[associationKey(name)] ??= []).add(c);
  }
  final list = [
    for (final group in groups.values)
      AssociationSummary((group..sort((a, b) => a.raceDate.compareTo(b.raceDate))).last.associationName!.trim(), group),
  ];
  list.sort((a, b) {
    final byMoney = b.donationCents.compareTo(a.donationCents);
    return byMoney != 0 ? byMoney : a.name.compareTo(b.name);
  });
  return list;
}

/// Récapitulatif d'une association par son nom (insensible à la casse et aux accents).
AssociationSummary? associationSummary(Iterable<Course> courses, String name) {
  final key = associationKey(name);
  for (final s in associationSummaries(courses)) {
    if (associationKey(s.name) == key) return s;
  }
  return null;
}
