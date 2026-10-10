/// Épreuves enchaînées : triathlon, duathlon, aquathlon.
library;

enum Sport { swim, bike, run }

/// Épreuve enchaînée et ordre de ses disciplines.
enum MultisportKind {
  triathlon([Sport.swim, Sport.bike, Sport.run]),
  duathlon([Sport.run, Sport.bike, Sport.run]),
  aquathlon([Sport.swim, Sport.run]);

  final List<Sport> sports;
  const MultisportKind(this.sports);

  static MultisportKind parse(String? value) =>
      values.firstWhere((k) => k.name == value, orElse: () => MultisportKind.triathlon);
}

/// Format courant : nom et distance de chaque discipline, en mètres, dans l'ordre de l'épreuve.
/// Les distances réelles varient d'une organisation à l'autre : elles restent modifiables à la saisie.
class MultisportFormat {
  final String name;
  final List<int> distancesM;

  const MultisportFormat(this.name, this.distancesM);

  static const Map<MultisportKind, List<MultisportFormat>> presets = {
    MultisportKind.triathlon: [
      MultisportFormat('XXS', [200, 5000, 1500]),
      MultisportFormat('XS', [400, 10000, 2500]),
      MultisportFormat('S', [750, 20000, 5000]),
      MultisportFormat('M', [1500, 40000, 10000]),
      MultisportFormat('L', [1900, 90000, 21100]),
      MultisportFormat('XL', [3800, 180000, 42200]),
    ],
    MultisportKind.duathlon: [
      MultisportFormat('XS', [2500, 10000, 1250]),
      MultisportFormat('S', [5000, 20000, 2500]),
      MultisportFormat('M', [10000, 40000, 5000]),
    ],
    MultisportKind.aquathlon: [
      MultisportFormat('XS', [500, 2500]),
      MultisportFormat('S', [1000, 5000]),
      MultisportFormat('M', [2000, 10000]),
    ],
  };

  static List<MultisportFormat> of(MultisportKind kind) => presets[kind] ?? const [];
}

/// Une discipline de l'épreuve. [durationS] vaut 0 quand le temps intermédiaire n'est pas connu.
class Leg {
  final Sport sport;
  final int distanceM;
  final int durationS;

  const Leg({required this.sport, required this.distanceM, this.durationS = 0});

  bool get hasTime => durationS > 0 && distanceM > 0;

  /// Rythme comparable d'une épreuve à l'autre, où le plus petit est le meilleur :
  /// secondes aux 100 m en natation, secondes au kilomètre à vélo comme à pied.
  double? get effort => !hasTime ? null : durationS / (distanceM / (sport == Sport.swim ? 100 : 1000));

  /// Natation : secondes aux 100 m.
  double? get secondsPer100m => hasTime ? durationS / (distanceM / 100) : null;

  /// Vélo : km/h.
  double? get speedKmh => hasTime ? (distanceM / 1000) / (durationS / 3600) : null;

  /// Course à pied : secondes au kilomètre.
  double? get secondsPerKm => hasTime ? durationS / (distanceM / 1000) : null;

  Map<String, dynamic> toJson() => {'sport': sport.name, 'distance_m': distanceM, 'duration_s': durationS};

  static Leg? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final sport = Sport.values.where((s) => s.name == raw['sport']).firstOrNull;
    if (sport == null) return null;
    return Leg(
      sport: sport,
      distanceM: (raw['distance_m'] as num?)?.toInt() ?? 0,
      durationS: (raw['duration_s'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Leg && other.sport == sport && other.distanceM == distanceM && other.durationS == durationS;

  @override
  int get hashCode => Object.hash(sport, distanceM, durationS);
}

/// Détail d'une épreuve enchaînée : ses disciplines et ses transitions.
///
/// Les chronos officiels ne détaillent pas toujours les transitions : certains les comptent dans
/// la discipline qui précède (T1 dans la natation, T2 dans le vélo). Dans ce cas
/// [transitionsIncluded] est vrai, [transitionsS] reste vide, et les allures de ces disciplines
/// sont un peu plus lentes que la réalité : l'app le signale au lieu de les présenter comme exactes.
class Multisport {
  final MultisportKind kind;

  /// Nom du format (« S », « M »…) ou null pour des distances libres.
  final String? format;
  final List<Leg> legs;

  /// Temps de chaque transition (une de moins que de disciplines), 0 si inconnu.
  final List<int> transitionsS;

  /// Transitions comptées dans le temps de la discipline qui les précède.
  final bool transitionsIncluded;

  Multisport({
    required this.kind,
    this.format,
    required List<Leg> legs,
    List<int> transitionsS = const [],
    this.transitionsIncluded = false,
  }) : legs = List.unmodifiable(legs),
       transitionsS = List.unmodifiable(
         transitionsIncluded
             ? const <int>[]
             : [for (var i = 0; i < legs.length - 1; i++) i < transitionsS.length ? transitionsS[i] : 0],
       );

  /// Distance totale, toutes disciplines confondues.
  int get distanceM => legs.fold(0, (sum, l) => sum + l.distanceM);

  /// Distance de la seule course à pied : c'est elle qui compte dans les kilomètres courus.
  int get runDistanceM => distanceOf(Sport.run);

  int distanceOf(Sport sport) => legs.where((l) => l.sport == sport).fold(0, (sum, l) => sum + l.distanceM);

  /// Tous les temps intermédiaires sont connus.
  bool get hasSplits => legs.isNotEmpty && legs.every((l) => l.durationS > 0);

  int get transitionsTotalS => transitionsS.fold(0, (sum, t) => sum + t);

  /// Temps total reconstitué à partir des temps intermédiaires, ou null s'il en manque.
  int? get splitsTotalS => hasSplits ? legs.fold(0, (sum, l) => sum + l.durationS) + transitionsTotalS : null;

  /// La discipline n° [index] contient-elle le temps d'une transition ?
  bool legIncludesTransition(int index) => transitionsIncluded && index < legs.length - 1;

  /// Une discipline sur toute l'épreuve : les deux courses d'un duathlon n'en font qu'une.
  /// Null si l'épreuve ne la comporte pas ; sans temps s'il manque un temps intermédiaire.
  Leg? split(Sport sport) {
    final own = legs.where((l) => l.sport == sport).toList();
    if (own.isEmpty) return null;
    return Leg(
      sport: sport,
      distanceM: own.fold(0, (sum, l) => sum + l.distanceM),
      durationS: own.every((l) => l.durationS > 0) ? own.fold(0, (sum, l) => sum + l.durationS) : 0,
    );
  }

  /// Le temps de cette discipline contient-il une transition ? Son rythme est alors sous-estimé.
  bool splitIncludesTransition(Sport sport) {
    for (var i = 0; i < legs.length; i++) {
      if (legs[i].sport == sport && legIncludesTransition(i)) return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'format': ?format,
    'legs': [for (final l in legs) l.toJson()],
    'transitions_s': transitionsS,
    'transitions_included': transitionsIncluded,
  };

  static Multisport? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final legs = [
      if (raw['legs'] is List)
        for (final item in raw['legs'] as List) ?Leg.tryFromJson(item),
    ];
    if (legs.isEmpty) return null;
    return Multisport(
      kind: MultisportKind.parse(raw['kind'] as String?),
      format: raw['format'] as String?,
      legs: legs,
      transitionsS: [
        if (raw['transitions_s'] is List)
          for (final t in raw['transitions_s'] as List) (t as num?)?.toInt() ?? 0,
      ],
      transitionsIncluded: raw['transitions_included'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Multisport &&
      other.kind == kind &&
      other.format == format &&
      other.transitionsIncluded == transitionsIncluded &&
      _same(other.legs, legs) &&
      _same(other.transitionsS, transitionsS);

  @override
  int get hashCode =>
      Object.hash(kind, format, transitionsIncluded, Object.hashAll(legs), Object.hashAll(transitionsS));

  static bool _same<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
