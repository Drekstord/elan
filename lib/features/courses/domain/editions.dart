import '../../../core/text.dart';
import 'course.dart';

/// Nom d'une course débarrassé de ce qui change d'une année à l'autre : le millésime
/// (« 2026 »), le numéro d'édition (« 12e », « 12ème édition », « #12 ») et la ponctuation.
/// « 10 km de Valfleuri 2026 » et « 10 km de Valfleuri (12e édition) » donnent la même clé.
String editionKey(String title) {
  final cleaned = fold(title)
      .replaceAll(RegExp(r'\b(19|20)\d{2}\b'), ' ')
      .replaceAll(RegExp(r'#\s*\d+'), ' ')
      .replaceAll(RegExp(r'\b\d+\s*(e|eme|er|ere|st|nd|rd|th)\b(\s+edition)?'), ' ')
      .replaceAll(RegExp(r'\bedition\b'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
  return cleaned;
}

/// Éditions précédentes de [course], de la plus récente à la plus ancienne : même nom (au
/// millésime près), même type d'épreuve, distance voisine (10 %), déjà courues.
List<Course> previousEditions(Course course, Iterable<Course> all) {
  final key = editionKey(course.title);
  if (key.isEmpty) return const [];
  bool comparable(Course other) =>
      other.id != course.id &&
      !other.isDeleted &&
      other.isCompleted &&
      other.type == course.type &&
      other.multisport?.kind == course.multisport?.kind &&
      other.raceDate.isBefore(course.raceDate) &&
      (other.distanceM - course.distanceM).abs() <= course.distanceM * 0.1 &&
      editionKey(other.title) == key;
  return all.where(comparable).toList()..sort((a, b) => b.raceDate.compareTo(a.raceDate));
}
