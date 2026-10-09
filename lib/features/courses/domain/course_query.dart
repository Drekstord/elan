import '../../../core/text.dart';
import 'course.dart';

/// Nature sportive de l'épreuve. Indépendante du volet solidaire :
/// une course officielle peut aussi être solidaire.
enum CourseKind {
  all,
  official,
  challenge;

  bool matches(Course course) => switch (this) {
    CourseKind.all => true,
    CourseKind.official => course.type == CourseType.officialRace,
    CourseKind.challenge => course.type == CourseType.theConqueror,
  };
}

enum CourseSort { raceDate, addedDate }

/// Filtres, recherche et tri de la liste des courses.
class CourseQuery {
  final CourseKind kind;

  /// Seulement les courses avec un volet solidaire.
  final bool charityOnly;

  /// Seulement les courses solidaires de cette cause.
  final CauseType? cause;
  final String search;
  final CourseSort sort;
  final bool descending;

  const CourseQuery({
    this.kind = CourseKind.all,
    this.charityOnly = false,
    this.cause,
    this.search = '',
    this.sort = CourseSort.raceDate,
    this.descending = true,
  });

  bool get isFiltered => kind != CourseKind.all || charityOnly || cause != null || search.trim().isNotEmpty;

  CourseQuery copyWith({
    CourseKind? kind,
    bool? charityOnly,
    Object? cause = _keep,
    String? search,
    CourseSort? sort,
    bool? descending,
  }) => CourseQuery(
    kind: kind ?? this.kind,
    charityOnly: charityOnly ?? this.charityOnly,
    cause: identical(cause, _keep) ? this.cause : cause as CauseType?,
    search: search ?? this.search,
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
  );

  bool matches(Course c) {
    if (!kind.matches(c)) return false;
    if ((charityOnly || cause != null) && !c.isCharity) return false;
    if (cause != null && c.associationCause != cause) return false;
    final needle = fold(search.trim());
    if (needle.isEmpty) return true;
    return fold(c.title).contains(needle) ||
        fold(c.associationName ?? '').contains(needle) ||
        fold(c.notes ?? '').contains(needle);
  }

  /// Les courses dont le résultat est à saisir remontent toujours en tête :
  /// c'est l'action qui attend l'utilisateur.
  List<Course> apply(Iterable<Course> courses, DateTime today) {
    final list = courses.where(matches).toList();

    int byField(Course a, Course b) {
      final primary = switch (sort) {
        CourseSort.raceDate => a.raceDate.compareTo(b.raceDate),
        CourseSort.addedDate => a.createdAt.compareTo(b.createdAt),
      };
      final value = primary != 0 ? primary : a.createdAt.compareTo(b.createdAt);
      return descending ? -value : value;
    }

    list.sort((a, b) {
      final aWaiting = a.statusOn(today) == CourseStatus.awaitingResult;
      final bWaiting = b.statusOn(today) == CourseStatus.awaitingResult;
      if (aWaiting != bWaiting) return aWaiting ? -1 : 1;
      return byField(a, b);
    });
    return list;
  }
}

const Object _keep = Object();

enum SectionKind { awaiting, upcoming, year, done }

/// Un bloc de la liste : à saisir, à venir, puis les courses terminées par année.
class CourseSection {
  final SectionKind kind;

  /// Année des courses terminées ([SectionKind.year]).
  final int? year;
  final List<Course> courses;

  const CourseSection(this.kind, this.courses, {this.year});

  /// Distance des courses terminées du bloc.
  int get distanceM => courses.fold(0, (sum, c) => sum + c.distanceM);
}

/// Découpe une liste déjà triée par [CourseQuery.apply] :
/// résultats à saisir, courses à venir (la plus proche d'abord), puis courses
/// terminées regroupées par année (tri par date de course) ou d'un seul bloc.
List<CourseSection> sectionsOf(List<Course> sorted, DateTime today, {required CourseSort sort}) {
  final awaiting = <Course>[], upcoming = <Course>[], done = <Course>[];
  for (final c in sorted) {
    switch (c.statusOn(today)) {
      case CourseStatus.awaitingResult:
        awaiting.add(c);
      case CourseStatus.upcoming:
        upcoming.add(c);
      case CourseStatus.completed:
        done.add(c);
    }
  }
  upcoming.sort((a, b) => a.raceDate.compareTo(b.raceDate));

  final sections = [
    if (awaiting.isNotEmpty) CourseSection(SectionKind.awaiting, awaiting),
    if (upcoming.isNotEmpty) CourseSection(SectionKind.upcoming, upcoming),
  ];
  if (sort == CourseSort.raceDate) {
    for (final c in done) {
      final last = sections.isEmpty ? null : sections.last;
      if (last != null && last.kind == SectionKind.year && last.year == c.raceDate.year) {
        last.courses.add(c);
      } else {
        sections.add(CourseSection(SectionKind.year, [c], year: c.raceDate.year));
      }
    }
  } else if (done.isNotEmpty) {
    sections.add(CourseSection(SectionKind.done, done));
  }
  return sections;
}
