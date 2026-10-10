import 'multisport.dart';

export 'multisport.dart';

/// Type d'épreuve.
enum CourseType {
  officialRace,
  theConqueror,

  /// Épreuve enchaînée (triathlon, duathlon, aquathlon) : détail dans [Course.multisport].
  multisport;

  static CourseType parse(String? value) =>
      CourseType.values.firstWhere((e) => e.name == value, orElse: () => CourseType.officialRace);
}

/// Cause soutenue par une course solidaire.
enum CauseType {
  sante,
  environnement,
  precarite,
  enfance,
  animaux,
  handicap,
  autre;

  static CauseType? tryParse(String? value) {
    for (final e in CauseType.values) {
      if (e.name == value) return e;
    }
    return null;
  }
}

/// Unité d'une équivalence d'impact concrète, déclarée par l'organisateur
/// (ex. 4 arbres pour un défi The Conqueror). `euroDirect` = aucune équivalence :
/// seul l'argent réellement donné compte.
enum ImpactMetric {
  trees,
  oceanBottles,
  careSessions,
  researchHours,
  meals,
  careKits,
  animalMeals,
  euroDirect;

  static ImpactMetric parse(String? value) =>
      ImpactMetric.values.firstWhere((e) => e.name == value, orElse: () => ImpactMetric.euroDirect);
}

/// Date calendaire sans heure ni fuseau, représentée à minuit UTC.
DateTime calendarDate(int year, int month, int day) => DateTime.utc(year, month, day);

/// `2026-10-07`
String formatIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Lit `2026-10-07` (ou un horodatage ISO complet, dont seule la date est gardée).
DateTime parseIsoDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
  if (match == null) throw FormatException('Date invalide', value);
  return calendarDate(int.parse(match[1]!), int.parse(match[2]!), int.parse(match[3]!));
}

const Object _unset = Object();

/// Type d'un justificatif : il sert de titre dans l'app et nomme le fichier à l'export.
enum DocumentKind {
  confirmation,
  invoice,
  donationReceipt,
  result,
  other;

  static DocumentKind? tryParse(String? value) {
    for (final k in values) {
      if (k.name == value) return k;
    }
    return null;
  }

  /// Type probable d'après le nom du fichier (proposé à l'ajout, modifiable).
  static DocumentKind? guess(String fileName) {
    final n = fileName.toLowerCase();
    bool has(List<String> words) => words.any(n.contains);
    if (has(['facture', 'invoice', 'factura'])) return DocumentKind.invoice;
    if (has(['reçu', 'recu', 'receipt', 'cerfa', 'don'])) return DocumentKind.donationReceipt;
    if (has(['résultat', 'resultat', 'result', 'classement', 'diplôme', 'diplome', 'certificat'])) {
      return DocumentKind.result;
    }
    if (has(['mail', 'confirm', 'inscription', 'billet', 'ticket', 'dossard'])) return DocumentKind.confirmation;
    return null;
  }
}

/// Justificatif joint à une course (facture d'inscription, reçu de don…) :
/// un fichier PDF ou image du bucket `course-media`, sous `<user_id>/docs/`.
class CourseDocument {
  /// Clé du fichier dans le bucket (et dans le cache local).
  final String key;

  /// Nom d'origine du fichier, affiché et utilisé à l'export.
  final String name;
  final int sizeBytes;
  final DateTime addedAt;

  /// Type choisi (null : justificatif ajouté avant les types, désigné par son nom de fichier).
  final DocumentKind? kind;

  CourseDocument({required this.key, required this.name, required this.sizeBytes, required DateTime addedAt, this.kind})
    : addedAt = addedAt.toUtc();

  CourseDocument withKind(DocumentKind kind) =>
      CourseDocument(key: key, name: name, sizeBytes: sizeBytes, addedAt: addedAt, kind: kind);

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  bool get isPdf => extension == 'pdf';

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'size': sizeBytes,
    'added_at': addedAt.toIso8601String(),
    'kind': ?kind?.name,
  };

  factory CourseDocument.fromJson(Map<String, dynamic> json) => CourseDocument(
    key: json['key'] as String,
    name: json['name'] as String? ?? 'justificatif',
    sizeBytes: (json['size'] as num?)?.toInt() ?? 0,
    addedAt: json['added_at'] == null ? DateTime.now() : DateTime.parse(json['added_at'] as String),
    kind: DocumentKind.tryParse(json['kind'] as String?),
  );

  static List<CourseDocument> listFromJson(Object? raw) => [
    if (raw is List)
      for (final item in raw)
        if (item is Map) CourseDocument.fromJson(Map<String, dynamic>.from(item)),
  ];
}

/// Classement officiel d'une course : place et nombre d'arrivants, au général et dans la catégorie.
/// Tout est facultatif : on saisit ce que donne la feuille de résultats.
class Ranking {
  final int? overall;
  final int? finishers;
  final int? category;
  final int? categoryFinishers;

  /// Nom de la catégorie tel que l'organisateur l'écrit (« SEH », « M1 »…).
  final String? categoryName;

  const Ranking({this.overall, this.finishers, this.category, this.categoryFinishers, this.categoryName});

  bool get isEmpty =>
      overall == null && finishers == null && category == null && categoryFinishers == null && categoryName == null;

  /// Part des arrivants devant soi ou à égalité, en pour cent : 15 = « dans les 15 % premiers ».
  static double? _percent(int? rank, int? total) =>
      rank == null || total == null || total <= 0 || rank > total ? null : rank * 100 / total;

  double? get overallPercent => _percent(overall, finishers);
  double? get categoryPercent => _percent(category, categoryFinishers);

  Map<String, dynamic> toJson() => {
    'overall': ?overall,
    'finishers': ?finishers,
    'category': ?category,
    'category_finishers': ?categoryFinishers,
    'category_name': ?categoryName,
  };

  static Ranking? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    int? positive(String key) {
      final v = (raw[key] as num?)?.toInt();
      return v != null && v > 0 ? v : null;
    }

    final name = (raw['category_name'] as String?)?.trim();
    final ranking = Ranking(
      overall: positive('overall'),
      finishers: positive('finishers'),
      category: positive('category'),
      categoryFinishers: positive('category_finishers'),
      categoryName: name == null || name.isEmpty ? null : name,
    );
    return ranking.isEmpty ? null : ranking;
  }

  @override
  bool operator ==(Object other) =>
      other is Ranking &&
      other.overall == overall &&
      other.finishers == finishers &&
      other.category == category &&
      other.categoryFinishers == categoryFinishers &&
      other.categoryName == categoryName;

  @override
  int get hashCode => Object.hash(overall, finishers, category, categoryFinishers, categoryName);
}

/// Avancement d'une course.
enum CourseStatus {
  /// Inscrite à l'avance, date pas encore atteinte.
  upcoming,

  /// Inscrite à l'avance, date atteinte : le résultat reste à saisir.
  awaitingResult,

  /// Courue, résultat saisi : compte dans les totaux et les records.
  completed,
}

/// Une course : performance sportive, éventuel volet solidaire, souvenirs.
///
/// Unités entières pour éviter les erreurs d'arrondi : mètres, secondes, centimes.
class Course {
  final String id;
  final String title;
  final DateTime raceDate;

  final CourseType type;

  /// Course inscrite à l'avance (« course future ») : pas encore de résultat.
  final bool isPlanned;

  /// Distance totale. Épreuve enchaînée : toutes disciplines confondues (voir [runDistanceM]).
  final int distanceM;

  /// Temps total, transitions comprises.
  final int durationS;
  final int? elevationGainM;

  /// Disciplines et transitions d'une épreuve enchaînée ; null pour les autres types.
  final Multisport? multisport;

  /// Temps visé, fixé avant la course et gardé après pour comparer.
  final int? targetDurationS;

  /// Classement officiel, s'il a été saisi.
  final Ranking? ranking;

  /// Défi en équipe : taille de l'équipe (null = solo) et distance totale du défi.
  final int? teamSize;
  final int? challengeDistanceM;

  /// Volet solidaire. Sans objet (null / 0) quand [isCharity] est faux.
  final bool isCharity;
  final String? associationId;
  final String? associationName;
  final CauseType? associationCause;
  final String? associationDescription;

  /// Parrainage : montant versé par kilomètre couru.
  final int sponsorCentsPerKm;
  final int registrationDonationCents;

  /// Montant collecté (cagnotte, page de collecte).
  final int fundraisingCents;

  /// Équivalence déclarée par l'organisateur, jamais calculée : unité + quantité.
  final ImpactMetric impactMetric;
  final double? impactQuantity;

  /// Clés du bucket `course-media` : `<user_id>/<uuid>.jpg`.
  final String? bibPhotoKey;
  final String? medalPhotoKey;
  final String? notes;

  /// Justificatifs (factures d'inscription…), du plus ancien au plus récent.
  final List<CourseDocument> documents;

  final DateTime createdAt;

  /// Dernière modification : arbitre les conflits (la plus récente gagne).
  final DateTime updatedAt;

  /// Suppression logique, propagée aux autres appareils.
  final DateTime? deletedAt;

  Course({
    required this.id,
    required this.title,
    required this.raceDate,
    this.type = CourseType.officialRace,
    this.isPlanned = false,
    required this.distanceM,
    this.durationS = 0,
    this.elevationGainM,
    Multisport? multisport,
    int? targetDurationS,
    Ranking? ranking,
    this.teamSize,
    this.challengeDistanceM,
    this.isCharity = false,
    String? associationId,
    String? associationName,
    CauseType? associationCause,
    String? associationDescription,
    int sponsorCentsPerKm = 0,
    int registrationDonationCents = 0,
    int fundraisingCents = 0,
    ImpactMetric impactMetric = ImpactMetric.euroDirect,
    double? impactQuantity,
    this.bibPhotoKey,
    this.medalPhotoKey,
    this.notes,
    this.documents = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : multisport = type == CourseType.multisport ? multisport : null,
       targetDurationS = (targetDurationS ?? 0) > 0 ? targetDurationS : null,
       ranking = (ranking?.isEmpty ?? true) ? null : ranking,
       associationId = isCharity ? associationId : null,
       associationName = isCharity ? associationName : null,
       associationCause = isCharity ? associationCause : null,
       associationDescription = isCharity ? associationDescription : null,
       sponsorCentsPerKm = isCharity ? sponsorCentsPerKm : 0,
       registrationDonationCents = isCharity ? registrationDonationCents : 0,
       fundraisingCents = isCharity ? fundraisingCents : 0,
       impactMetric = isCharity && impactQuantity != null ? impactMetric : ImpactMetric.euroDirect,
       impactQuantity = isCharity && impactMetric != ImpactMetric.euroDirect ? impactQuantity : null,
       createdAt = (createdAt ?? DateTime.now()).toUtc(),
       updatedAt = (updatedAt ?? createdAt ?? DateTime.now()).toUtc();

  bool get isDeleted => deletedAt != null;
  bool get isTeam => (teamSize ?? 1) > 1;
  double get distanceKm => distanceM / 1000;

  bool get isMultisport => multisport != null;

  /// Kilomètres courus : pour une épreuve enchaînée, la seule partie course à pied.
  /// C'est cette distance qui alimente les totaux, les graphiques et le widget.
  int get runDistanceM => multisport?.runDistanceM ?? distanceM;

  /// Seules les courses terminées comptent dans les totaux, l'impact et les records.
  bool get isCompleted => !isPlanned;

  /// [today] : date du jour, sans heure (voir [calendarDate]).
  CourseStatus statusOn(DateTime today) {
    if (!isPlanned) return CourseStatus.completed;
    return raceDate.isAfter(today) ? CourseStatus.upcoming : CourseStatus.awaitingResult;
  }

  bool get hasTime => durationS > 0 && distanceM > 0;

  /// Allure en secondes par kilomètre, null sans chrono. Sans objet pour une épreuve enchaînée
  /// (natation, vélo et transitions mêlés) : chaque discipline a la sienne, voir [Leg].
  double? get paceSecondsPerKm => hasTime && !isMultisport ? durationS / distanceKm : null;

  /// Vitesse moyenne en km/h, null sans chrono ou pour une épreuve enchaînée.
  double? get speedKmh => hasTime && !isMultisport ? distanceKm / (durationS / 3600) : null;

  /// Écart au temps visé, en secondes : négatif quand l'objectif est battu.
  /// Null tant que la course n'est pas terminée et chronométrée, ou sans objectif.
  int? get targetDeltaS => isCompleted && hasTime && targetDurationS != null ? durationS - targetDurationS! : null;

  /// Objectif et classement, regroupés dans une seule colonne du serveur ; null si rien n'est saisi.
  Map<String, dynamic>? get detailsJson {
    final details = {'target_s': ?targetDurationS, 'ranking': ?ranking?.toJson()};
    return details.isEmpty ? null : details;
  }

  /// Argent réellement engagé pour la cause : parrainage au km + inscription + collecte.
  int get donationCents {
    if (!isCharity) return 0;
    return (sponsorCentsPerKm * distanceM / 1000).round() + registrationDonationCents + fundraisingCents;
  }

  List<String> get photoKeys => [?bibPhotoKey, ?medalPhotoKey];

  /// Tous les fichiers de la course dans le bucket : photos et justificatifs.
  List<String> get fileKeys => [...photoKeys, for (final d in documents) d.key];

  Course copyWith({
    String? title,
    DateTime? raceDate,
    CourseType? type,
    bool? isPlanned,
    int? distanceM,
    int? durationS,
    Object? elevationGainM = _unset,
    Object? multisport = _unset,
    Object? targetDurationS = _unset,
    Object? ranking = _unset,
    Object? teamSize = _unset,
    Object? challengeDistanceM = _unset,
    bool? isCharity,
    Object? associationId = _unset,
    Object? associationName = _unset,
    Object? associationCause = _unset,
    Object? associationDescription = _unset,
    int? sponsorCentsPerKm,
    int? registrationDonationCents,
    int? fundraisingCents,
    ImpactMetric? impactMetric,
    Object? impactQuantity = _unset,
    Object? bibPhotoKey = _unset,
    Object? medalPhotoKey = _unset,
    Object? notes = _unset,
    List<CourseDocument>? documents,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    T pick<T>(Object? value, T current) => identical(value, _unset) ? current : value as T;
    return Course(
      id: id,
      title: title ?? this.title,
      raceDate: raceDate ?? this.raceDate,
      type: type ?? this.type,
      isPlanned: isPlanned ?? this.isPlanned,
      distanceM: distanceM ?? this.distanceM,
      durationS: durationS ?? this.durationS,
      elevationGainM: pick(elevationGainM, this.elevationGainM),
      multisport: pick(multisport, this.multisport),
      targetDurationS: pick(targetDurationS, this.targetDurationS),
      ranking: pick(ranking, this.ranking),
      teamSize: pick(teamSize, this.teamSize),
      challengeDistanceM: pick(challengeDistanceM, this.challengeDistanceM),
      isCharity: isCharity ?? this.isCharity,
      associationId: pick(associationId, this.associationId),
      associationName: pick(associationName, this.associationName),
      associationCause: pick(associationCause, this.associationCause),
      associationDescription: pick(associationDescription, this.associationDescription),
      sponsorCentsPerKm: sponsorCentsPerKm ?? this.sponsorCentsPerKm,
      registrationDonationCents: registrationDonationCents ?? this.registrationDonationCents,
      fundraisingCents: fundraisingCents ?? this.fundraisingCents,
      impactMetric: impactMetric ?? this.impactMetric,
      impactQuantity: pick(impactQuantity, this.impactQuantity),
      bibPhotoKey: pick(bibPhotoKey, this.bibPhotoKey),
      medalPhotoKey: pick(medalPhotoKey, this.medalPhotoKey),
      notes: pick(notes, this.notes),
      documents: documents ?? this.documents,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: pick(deletedAt, this.deletedAt),
    );
  }

  /// Format d'échange avec Supabase (colonnes de la table `courses`, hors `user_id`).
  Map<String, dynamic> toRemoteJson() => {
    'id': id,
    'title': title,
    'race_date': formatIsoDate(raceDate),
    'course_type': type.name,
    'is_planned': isPlanned,
    'distance_m': distanceM,
    'duration_s': durationS,
    'elevation_gain_m': elevationGainM,
    'multisport': multisport?.toJson(),
    'details': detailsJson,
    'team_size': teamSize,
    'challenge_distance_m': challengeDistanceM,
    'is_charity': isCharity,
    'association_id': associationId,
    'association_name': associationName,
    'association_cause': associationCause?.name,
    'association_description': associationDescription,
    'sponsor_cents_per_km': sponsorCentsPerKm,
    'registration_donation_cents': registrationDonationCents,
    'fundraising_cents': fundraisingCents,
    'impact_metric': impactMetric.name,
    'impact_quantity': impactQuantity,
    'bib_photo_key': bibPhotoKey,
    'medal_photo_key': medalPhotoKey,
    'notes': notes,
    'documents': [for (final d in documents) d.toJson()],
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  factory Course.fromRemoteJson(Map<String, dynamic> json) {
    DateTime? ts(String key) => json[key] == null ? null : DateTime.parse(json[key] as String).toUtc();
    int? integer(String key) => (json[key] as num?)?.toInt();
    final details = json['details'];
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      raceDate: parseIsoDate(json['race_date'] as String),
      type: CourseType.parse(json['course_type'] as String?),
      isPlanned: json['is_planned'] as bool? ?? false,
      distanceM: integer('distance_m') ?? 0,
      durationS: integer('duration_s') ?? 0,
      elevationGainM: integer('elevation_gain_m'),
      multisport: Multisport.tryFromJson(json['multisport']),
      targetDurationS: details is Map ? (details['target_s'] as num?)?.toInt() : null,
      ranking: details is Map ? Ranking.tryFromJson(details['ranking']) : null,
      teamSize: integer('team_size'),
      challengeDistanceM: integer('challenge_distance_m'),
      isCharity: json['is_charity'] as bool? ?? false,
      associationId: json['association_id'] as String?,
      associationName: json['association_name'] as String?,
      associationCause: CauseType.tryParse(json['association_cause'] as String?),
      associationDescription: json['association_description'] as String?,
      sponsorCentsPerKm: integer('sponsor_cents_per_km') ?? 0,
      registrationDonationCents: integer('registration_donation_cents') ?? 0,
      fundraisingCents: integer('fundraising_cents') ?? 0,
      impactMetric: ImpactMetric.parse(json['impact_metric'] as String?),
      impactQuantity: (json['impact_quantity'] as num?)?.toDouble(),
      bibPhotoKey: json['bib_photo_key'] as String?,
      medalPhotoKey: json['medal_photo_key'] as String?,
      notes: json['notes'] as String?,
      documents: CourseDocument.listFromJson(json['documents']),
      createdAt: ts('created_at'),
      updatedAt: ts('updated_at'),
      deletedAt: ts('deleted_at'),
    );
  }
}
