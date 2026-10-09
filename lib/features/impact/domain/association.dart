import '../../../core/text.dart';
import '../../courses/domain/course.dart';

/// Association ou programme solidaire soutenu par une course.
class Association {
  final String id;
  final String name;
  final CauseType cause;
  final String? description;

  /// Identifiants officiels, connus seulement pour les résultats de recherche.
  final String? siren;
  final String? rna;

  /// Commune du siège : distingue les antennes locales d'un même réseau.
  final String? city;

  /// Unités d'impact que l'organisateur annonce (ex. arbres pour The Conqueror).
  final List<ImpactMetric> declaredMetrics;

  const Association({
    required this.id,
    required this.name,
    required this.cause,
    this.description,
    this.siren,
    this.rna,
    this.city,
    this.declaredMetrics = const [],
  });
}

/// Déduit la cause d'une association à partir de son nom, de son objet
/// et de son code d'activité (NAF). Les mots-clés passent avant le NAF,
/// beaucoup d'associations étant classées « autres organisations » (94.99Z).
CauseType inferCause({required String name, String description = '', String? nafCode}) {
  final text = ' ${fold('$name $description')} ';
  bool any(List<String> words) => words.any(text.contains);

  if (any([
    'handicap',
    'rett',
    'syndrome',
    'polyhandicap',
    'paralys',
    'autis',
    'trisomi',
    'deficien',
    'myopath',
    'fauteuil',
    'sourd',
    'aveugle',
    'malvoyan',
    'inclusion',
    'moelle epiniere',
  ])) {
    return CauseType.handicap;
  }
  if (any([
    'cancer',
    'recherche medicale',
    'maladie',
    'hopital',
    'telethon',
    'medecin',
    'sante',
    'soins',
    'leucemie',
    'mucoviscidose',
    'alzheimer',
    'sauvetage',
  ])) {
    return CauseType.sante;
  }
  if (any([
    'environnement',
    'climat',
    'ecolog',
    'nature',
    'biodiversite',
    'foret',
    'arbre',
    'ocean',
    'plastique',
    'reforestation',
    'littoral',
  ])) {
    return CauseType.environnement;
  }
  if (any(['animal', 'animaux', ' spa ', 'refuge', 'chien', 'chat ', 'faune'])) return CauseType.animaux;
  if (any(['enfant', 'enfance', 'jeunesse', 'scolaire', 'ecole', 'pediatr', 'orphelin', 'education'])) {
    return CauseType.enfance;
  }
  if (any([
    'faim',
    'repas',
    'pauvrete',
    'precarite',
    'secours',
    'sans-abri',
    'sans abri',
    'restos',
    'solidarite',
    'humanitaire',
    'exclusion',
    'logement',
  ])) {
    return CauseType.precarite;
  }

  final naf = nafCode ?? '';
  if (naf.startsWith('86') || naf.startsWith('72.1')) return CauseType.sante;
  if (naf.startsWith('87') || naf.startsWith('88.1')) return CauseType.handicap;
  if (naf.startsWith('88.9')) return CauseType.precarite;
  if (naf.startsWith('85')) return CauseType.enfance;
  if (naf == '91.04Z') return CauseType.environnement;
  return CauseType.autre;
}

/// « ASS FRANCAISE CONTRE LES MYOPATHIES (AFM) » -> « Association Française contre les Myopathies (AFM) ».
String formatOfficialName(String raw) {
  final trimmed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed.isEmpty || trimmed != trimmed.toUpperCase()) return trimmed;

  const small = {'DE', 'DU', 'DES', 'LE', 'LA', 'LES', 'ET', 'EN', 'AU', 'AUX', 'POUR', 'SUR', 'D', 'L'};
  const expansions = {'ASS': 'Association', 'ASSO': 'Association', 'FRANCAISE': 'Française', 'FRANCAIS': 'Français'};
  final words = trimmed.split(' ');
  return [
    for (var i = 0; i < words.length; i++) _formatWord(words[i], first: i == 0, small: small, expansions: expansions),
  ].join(' ');
}

String _formatWord(
  String word, {
  required bool first,
  required Set<String> small,
  required Map<String, String> expansions,
}) {
  // Sigles entre parenthèses ou très courts : laissés en capitales.
  if (word.startsWith('(') && word.endsWith(')')) return word;
  final expanded = expansions[word];
  if (expanded != null) return expanded;
  if (!first && small.contains(word)) return word.toLowerCase();
  // D'ENTRAIDE -> d'Entraide (élision en minuscule sauf en début de nom)
  final parts = word.split("'");
  return [
    for (var i = 0; i < parts.length; i++)
      if (parts[i].isEmpty)
        parts[i]
      else if (i == 0 && parts.length > 1 && !first && small.contains(parts[i]))
        parts[i].toLowerCase()
      else
        parts[i][0] + parts[i].substring(1).toLowerCase(),
  ].join("'");
}
