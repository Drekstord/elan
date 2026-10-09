// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CoursesTable extends Courses with TableInfo<$CoursesTable, CourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _raceDateMeta = const VerificationMeta('raceDate');
  @override
  late final GeneratedColumn<String> raceDate = GeneratedColumn<String>(
    'race_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseTypeMeta = const VerificationMeta('courseType');
  @override
  late final GeneratedColumn<String> courseType = GeneratedColumn<String>(
    'course_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPlannedMeta = const VerificationMeta('isPlanned');
  @override
  late final GeneratedColumn<bool> isPlanned = GeneratedColumn<bool>(
    'is_planned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_planned" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<int> distanceM = GeneratedColumn<int>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSMeta = const VerificationMeta('durationS');
  @override
  late final GeneratedColumn<int> durationS = GeneratedColumn<int>(
    'duration_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevationGainMMeta = const VerificationMeta('elevationGainM');
  @override
  late final GeneratedColumn<int> elevationGainM = GeneratedColumn<int>(
    'elevation_gain_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teamSizeMeta = const VerificationMeta('teamSize');
  @override
  late final GeneratedColumn<int> teamSize = GeneratedColumn<int>(
    'team_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _challengeDistanceMMeta = const VerificationMeta('challengeDistanceM');
  @override
  late final GeneratedColumn<int> challengeDistanceM = GeneratedColumn<int>(
    'challenge_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCharityMeta = const VerificationMeta('isCharity');
  @override
  late final GeneratedColumn<bool> isCharity = GeneratedColumn<bool>(
    'is_charity',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_charity" IN (0, 1))'),
  );
  static const VerificationMeta _associationIdMeta = const VerificationMeta('associationId');
  @override
  late final GeneratedColumn<String> associationId = GeneratedColumn<String>(
    'association_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _associationNameMeta = const VerificationMeta('associationName');
  @override
  late final GeneratedColumn<String> associationName = GeneratedColumn<String>(
    'association_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _associationCauseMeta = const VerificationMeta('associationCause');
  @override
  late final GeneratedColumn<String> associationCause = GeneratedColumn<String>(
    'association_cause',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _associationDescriptionMeta = const VerificationMeta('associationDescription');
  @override
  late final GeneratedColumn<String> associationDescription = GeneratedColumn<String>(
    'association_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sponsorCentsPerKmMeta = const VerificationMeta('sponsorCentsPerKm');
  @override
  late final GeneratedColumn<int> sponsorCentsPerKm = GeneratedColumn<int>(
    'sponsor_cents_per_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationDonationCentsMeta = const VerificationMeta('registrationDonationCents');
  @override
  late final GeneratedColumn<int> registrationDonationCents = GeneratedColumn<int>(
    'registration_donation_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundraisingCentsMeta = const VerificationMeta('fundraisingCents');
  @override
  late final GeneratedColumn<int> fundraisingCents = GeneratedColumn<int>(
    'fundraising_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _impactMetricMeta = const VerificationMeta('impactMetric');
  @override
  late final GeneratedColumn<String> impactMetric = GeneratedColumn<String>(
    'impact_metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _impactQuantityMeta = const VerificationMeta('impactQuantity');
  @override
  late final GeneratedColumn<double> impactQuantity = GeneratedColumn<double>(
    'impact_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bibPhotoKeyMeta = const VerificationMeta('bibPhotoKey');
  @override
  late final GeneratedColumn<String> bibPhotoKey = GeneratedColumn<String>(
    'bib_photo_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medalPhotoKeyMeta = const VerificationMeta('medalPhotoKey');
  @override
  late final GeneratedColumn<String> medalPhotoKey = GeneratedColumn<String>(
    'medal_photo_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentsMeta = const VerificationMeta('documents');
  @override
  late final GeneratedColumn<String> documents = GeneratedColumn<String>(
    'documents',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta('pending');
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("pending" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    raceDate,
    courseType,
    isPlanned,
    distanceM,
    durationS,
    elevationGainM,
    teamSize,
    challengeDistanceM,
    isCharity,
    associationId,
    associationName,
    associationCause,
    associationDescription,
    sponsorCentsPerKm,
    registrationDonationCents,
    fundraisingCents,
    impactMetric,
    impactQuantity,
    bibPhotoKey,
    medalPhotoKey,
    notes,
    documents,
    createdAt,
    updatedAt,
    deletedAt,
    pending,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(Insertable<CourseRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('race_date')) {
      context.handle(_raceDateMeta, raceDate.isAcceptableOrUnknown(data['race_date']!, _raceDateMeta));
    } else if (isInserting) {
      context.missing(_raceDateMeta);
    }
    if (data.containsKey('course_type')) {
      context.handle(_courseTypeMeta, courseType.isAcceptableOrUnknown(data['course_type']!, _courseTypeMeta));
    } else if (isInserting) {
      context.missing(_courseTypeMeta);
    }
    if (data.containsKey('is_planned')) {
      context.handle(_isPlannedMeta, isPlanned.isAcceptableOrUnknown(data['is_planned']!, _isPlannedMeta));
    }
    if (data.containsKey('distance_m')) {
      context.handle(_distanceMMeta, distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta));
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('duration_s')) {
      context.handle(_durationSMeta, durationS.isAcceptableOrUnknown(data['duration_s']!, _durationSMeta));
    } else if (isInserting) {
      context.missing(_durationSMeta);
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
        _elevationGainMMeta,
        elevationGainM.isAcceptableOrUnknown(data['elevation_gain_m']!, _elevationGainMMeta),
      );
    }
    if (data.containsKey('team_size')) {
      context.handle(_teamSizeMeta, teamSize.isAcceptableOrUnknown(data['team_size']!, _teamSizeMeta));
    }
    if (data.containsKey('challenge_distance_m')) {
      context.handle(
        _challengeDistanceMMeta,
        challengeDistanceM.isAcceptableOrUnknown(data['challenge_distance_m']!, _challengeDistanceMMeta),
      );
    }
    if (data.containsKey('is_charity')) {
      context.handle(_isCharityMeta, isCharity.isAcceptableOrUnknown(data['is_charity']!, _isCharityMeta));
    } else if (isInserting) {
      context.missing(_isCharityMeta);
    }
    if (data.containsKey('association_id')) {
      context.handle(
        _associationIdMeta,
        associationId.isAcceptableOrUnknown(data['association_id']!, _associationIdMeta),
      );
    }
    if (data.containsKey('association_name')) {
      context.handle(
        _associationNameMeta,
        associationName.isAcceptableOrUnknown(data['association_name']!, _associationNameMeta),
      );
    }
    if (data.containsKey('association_cause')) {
      context.handle(
        _associationCauseMeta,
        associationCause.isAcceptableOrUnknown(data['association_cause']!, _associationCauseMeta),
      );
    }
    if (data.containsKey('association_description')) {
      context.handle(
        _associationDescriptionMeta,
        associationDescription.isAcceptableOrUnknown(data['association_description']!, _associationDescriptionMeta),
      );
    }
    if (data.containsKey('sponsor_cents_per_km')) {
      context.handle(
        _sponsorCentsPerKmMeta,
        sponsorCentsPerKm.isAcceptableOrUnknown(data['sponsor_cents_per_km']!, _sponsorCentsPerKmMeta),
      );
    } else if (isInserting) {
      context.missing(_sponsorCentsPerKmMeta);
    }
    if (data.containsKey('registration_donation_cents')) {
      context.handle(
        _registrationDonationCentsMeta,
        registrationDonationCents.isAcceptableOrUnknown(
          data['registration_donation_cents']!,
          _registrationDonationCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationDonationCentsMeta);
    }
    if (data.containsKey('fundraising_cents')) {
      context.handle(
        _fundraisingCentsMeta,
        fundraisingCents.isAcceptableOrUnknown(data['fundraising_cents']!, _fundraisingCentsMeta),
      );
    }
    if (data.containsKey('impact_metric')) {
      context.handle(_impactMetricMeta, impactMetric.isAcceptableOrUnknown(data['impact_metric']!, _impactMetricMeta));
    } else if (isInserting) {
      context.missing(_impactMetricMeta);
    }
    if (data.containsKey('impact_quantity')) {
      context.handle(
        _impactQuantityMeta,
        impactQuantity.isAcceptableOrUnknown(data['impact_quantity']!, _impactQuantityMeta),
      );
    }
    if (data.containsKey('bib_photo_key')) {
      context.handle(_bibPhotoKeyMeta, bibPhotoKey.isAcceptableOrUnknown(data['bib_photo_key']!, _bibPhotoKeyMeta));
    }
    if (data.containsKey('medal_photo_key')) {
      context.handle(
        _medalPhotoKeyMeta,
        medalPhotoKey.isAcceptableOrUnknown(data['medal_photo_key']!, _medalPhotoKeyMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('documents')) {
      context.handle(_documentsMeta, documents.isAcceptableOrUnknown(data['documents']!, _documentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('pending')) {
      context.handle(_pendingMeta, pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      raceDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}race_date'])!,
      courseType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}course_type'])!,
      isPlanned: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_planned'])!,
      distanceM: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}distance_m'])!,
      durationS: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_s'])!,
      elevationGainM: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}elevation_gain_m']),
      teamSize: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}team_size']),
      challengeDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}challenge_distance_m'],
      ),
      isCharity: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_charity'])!,
      associationId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}association_id']),
      associationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_name'],
      ),
      associationCause: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_cause'],
      ),
      associationDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_description'],
      ),
      sponsorCentsPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sponsor_cents_per_km'],
      )!,
      registrationDonationCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registration_donation_cents'],
      )!,
      fundraisingCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fundraising_cents'],
      )!,
      impactMetric: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}impact_metric'])!,
      impactQuantity: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}impact_quantity']),
      bibPhotoKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bib_photo_key']),
      medalPhotoKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}medal_photo_key']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      documents: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}documents'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      pending: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}pending'])!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class CourseRow extends DataClass implements Insertable<CourseRow> {
  final String id;
  final String title;
  final String raceDate;
  final String courseType;
  final bool isPlanned;
  final int distanceM;
  final int durationS;
  final int? elevationGainM;
  final int? teamSize;
  final int? challengeDistanceM;
  final bool isCharity;
  final String? associationId;
  final String? associationName;
  final String? associationCause;
  final String? associationDescription;
  final int sponsorCentsPerKm;
  final int registrationDonationCents;
  final int fundraisingCents;
  final String impactMetric;
  final double? impactQuantity;
  final String? bibPhotoKey;
  final String? medalPhotoKey;
  final String? notes;

  /// Justificatifs, en JSON (liste de [CourseDocument]).
  final String documents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Modifiée localement, pas encore confirmée par le serveur.
  final bool pending;
  const CourseRow({
    required this.id,
    required this.title,
    required this.raceDate,
    required this.courseType,
    required this.isPlanned,
    required this.distanceM,
    required this.durationS,
    this.elevationGainM,
    this.teamSize,
    this.challengeDistanceM,
    required this.isCharity,
    this.associationId,
    this.associationName,
    this.associationCause,
    this.associationDescription,
    required this.sponsorCentsPerKm,
    required this.registrationDonationCents,
    required this.fundraisingCents,
    required this.impactMetric,
    this.impactQuantity,
    this.bibPhotoKey,
    this.medalPhotoKey,
    this.notes,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pending,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['race_date'] = Variable<String>(raceDate);
    map['course_type'] = Variable<String>(courseType);
    map['is_planned'] = Variable<bool>(isPlanned);
    map['distance_m'] = Variable<int>(distanceM);
    map['duration_s'] = Variable<int>(durationS);
    if (!nullToAbsent || elevationGainM != null) {
      map['elevation_gain_m'] = Variable<int>(elevationGainM);
    }
    if (!nullToAbsent || teamSize != null) {
      map['team_size'] = Variable<int>(teamSize);
    }
    if (!nullToAbsent || challengeDistanceM != null) {
      map['challenge_distance_m'] = Variable<int>(challengeDistanceM);
    }
    map['is_charity'] = Variable<bool>(isCharity);
    if (!nullToAbsent || associationId != null) {
      map['association_id'] = Variable<String>(associationId);
    }
    if (!nullToAbsent || associationName != null) {
      map['association_name'] = Variable<String>(associationName);
    }
    if (!nullToAbsent || associationCause != null) {
      map['association_cause'] = Variable<String>(associationCause);
    }
    if (!nullToAbsent || associationDescription != null) {
      map['association_description'] = Variable<String>(associationDescription);
    }
    map['sponsor_cents_per_km'] = Variable<int>(sponsorCentsPerKm);
    map['registration_donation_cents'] = Variable<int>(registrationDonationCents);
    map['fundraising_cents'] = Variable<int>(fundraisingCents);
    map['impact_metric'] = Variable<String>(impactMetric);
    if (!nullToAbsent || impactQuantity != null) {
      map['impact_quantity'] = Variable<double>(impactQuantity);
    }
    if (!nullToAbsent || bibPhotoKey != null) {
      map['bib_photo_key'] = Variable<String>(bibPhotoKey);
    }
    if (!nullToAbsent || medalPhotoKey != null) {
      map['medal_photo_key'] = Variable<String>(medalPhotoKey);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['documents'] = Variable<String>(documents);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pending'] = Variable<bool>(pending);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      title: Value(title),
      raceDate: Value(raceDate),
      courseType: Value(courseType),
      isPlanned: Value(isPlanned),
      distanceM: Value(distanceM),
      durationS: Value(durationS),
      elevationGainM: elevationGainM == null && nullToAbsent ? const Value.absent() : Value(elevationGainM),
      teamSize: teamSize == null && nullToAbsent ? const Value.absent() : Value(teamSize),
      challengeDistanceM: challengeDistanceM == null && nullToAbsent ? const Value.absent() : Value(challengeDistanceM),
      isCharity: Value(isCharity),
      associationId: associationId == null && nullToAbsent ? const Value.absent() : Value(associationId),
      associationName: associationName == null && nullToAbsent ? const Value.absent() : Value(associationName),
      associationCause: associationCause == null && nullToAbsent ? const Value.absent() : Value(associationCause),
      associationDescription: associationDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(associationDescription),
      sponsorCentsPerKm: Value(sponsorCentsPerKm),
      registrationDonationCents: Value(registrationDonationCents),
      fundraisingCents: Value(fundraisingCents),
      impactMetric: Value(impactMetric),
      impactQuantity: impactQuantity == null && nullToAbsent ? const Value.absent() : Value(impactQuantity),
      bibPhotoKey: bibPhotoKey == null && nullToAbsent ? const Value.absent() : Value(bibPhotoKey),
      medalPhotoKey: medalPhotoKey == null && nullToAbsent ? const Value.absent() : Value(medalPhotoKey),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      documents: Value(documents),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      pending: Value(pending),
    );
  }

  factory CourseRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      raceDate: serializer.fromJson<String>(json['raceDate']),
      courseType: serializer.fromJson<String>(json['courseType']),
      isPlanned: serializer.fromJson<bool>(json['isPlanned']),
      distanceM: serializer.fromJson<int>(json['distanceM']),
      durationS: serializer.fromJson<int>(json['durationS']),
      elevationGainM: serializer.fromJson<int?>(json['elevationGainM']),
      teamSize: serializer.fromJson<int?>(json['teamSize']),
      challengeDistanceM: serializer.fromJson<int?>(json['challengeDistanceM']),
      isCharity: serializer.fromJson<bool>(json['isCharity']),
      associationId: serializer.fromJson<String?>(json['associationId']),
      associationName: serializer.fromJson<String?>(json['associationName']),
      associationCause: serializer.fromJson<String?>(json['associationCause']),
      associationDescription: serializer.fromJson<String?>(json['associationDescription']),
      sponsorCentsPerKm: serializer.fromJson<int>(json['sponsorCentsPerKm']),
      registrationDonationCents: serializer.fromJson<int>(json['registrationDonationCents']),
      fundraisingCents: serializer.fromJson<int>(json['fundraisingCents']),
      impactMetric: serializer.fromJson<String>(json['impactMetric']),
      impactQuantity: serializer.fromJson<double?>(json['impactQuantity']),
      bibPhotoKey: serializer.fromJson<String?>(json['bibPhotoKey']),
      medalPhotoKey: serializer.fromJson<String?>(json['medalPhotoKey']),
      notes: serializer.fromJson<String?>(json['notes']),
      documents: serializer.fromJson<String>(json['documents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'raceDate': serializer.toJson<String>(raceDate),
      'courseType': serializer.toJson<String>(courseType),
      'isPlanned': serializer.toJson<bool>(isPlanned),
      'distanceM': serializer.toJson<int>(distanceM),
      'durationS': serializer.toJson<int>(durationS),
      'elevationGainM': serializer.toJson<int?>(elevationGainM),
      'teamSize': serializer.toJson<int?>(teamSize),
      'challengeDistanceM': serializer.toJson<int?>(challengeDistanceM),
      'isCharity': serializer.toJson<bool>(isCharity),
      'associationId': serializer.toJson<String?>(associationId),
      'associationName': serializer.toJson<String?>(associationName),
      'associationCause': serializer.toJson<String?>(associationCause),
      'associationDescription': serializer.toJson<String?>(associationDescription),
      'sponsorCentsPerKm': serializer.toJson<int>(sponsorCentsPerKm),
      'registrationDonationCents': serializer.toJson<int>(registrationDonationCents),
      'fundraisingCents': serializer.toJson<int>(fundraisingCents),
      'impactMetric': serializer.toJson<String>(impactMetric),
      'impactQuantity': serializer.toJson<double?>(impactQuantity),
      'bibPhotoKey': serializer.toJson<String?>(bibPhotoKey),
      'medalPhotoKey': serializer.toJson<String?>(medalPhotoKey),
      'notes': serializer.toJson<String?>(notes),
      'documents': serializer.toJson<String>(documents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pending': serializer.toJson<bool>(pending),
    };
  }

  CourseRow copyWith({
    String? id,
    String? title,
    String? raceDate,
    String? courseType,
    bool? isPlanned,
    int? distanceM,
    int? durationS,
    Value<int?> elevationGainM = const Value.absent(),
    Value<int?> teamSize = const Value.absent(),
    Value<int?> challengeDistanceM = const Value.absent(),
    bool? isCharity,
    Value<String?> associationId = const Value.absent(),
    Value<String?> associationName = const Value.absent(),
    Value<String?> associationCause = const Value.absent(),
    Value<String?> associationDescription = const Value.absent(),
    int? sponsorCentsPerKm,
    int? registrationDonationCents,
    int? fundraisingCents,
    String? impactMetric,
    Value<double?> impactQuantity = const Value.absent(),
    Value<String?> bibPhotoKey = const Value.absent(),
    Value<String?> medalPhotoKey = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pending,
  }) => CourseRow(
    id: id ?? this.id,
    title: title ?? this.title,
    raceDate: raceDate ?? this.raceDate,
    courseType: courseType ?? this.courseType,
    isPlanned: isPlanned ?? this.isPlanned,
    distanceM: distanceM ?? this.distanceM,
    durationS: durationS ?? this.durationS,
    elevationGainM: elevationGainM.present ? elevationGainM.value : this.elevationGainM,
    teamSize: teamSize.present ? teamSize.value : this.teamSize,
    challengeDistanceM: challengeDistanceM.present ? challengeDistanceM.value : this.challengeDistanceM,
    isCharity: isCharity ?? this.isCharity,
    associationId: associationId.present ? associationId.value : this.associationId,
    associationName: associationName.present ? associationName.value : this.associationName,
    associationCause: associationCause.present ? associationCause.value : this.associationCause,
    associationDescription: associationDescription.present ? associationDescription.value : this.associationDescription,
    sponsorCentsPerKm: sponsorCentsPerKm ?? this.sponsorCentsPerKm,
    registrationDonationCents: registrationDonationCents ?? this.registrationDonationCents,
    fundraisingCents: fundraisingCents ?? this.fundraisingCents,
    impactMetric: impactMetric ?? this.impactMetric,
    impactQuantity: impactQuantity.present ? impactQuantity.value : this.impactQuantity,
    bibPhotoKey: bibPhotoKey.present ? bibPhotoKey.value : this.bibPhotoKey,
    medalPhotoKey: medalPhotoKey.present ? medalPhotoKey.value : this.medalPhotoKey,
    notes: notes.present ? notes.value : this.notes,
    documents: documents ?? this.documents,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pending: pending ?? this.pending,
  );
  CourseRow copyWithCompanion(CoursesCompanion data) {
    return CourseRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      raceDate: data.raceDate.present ? data.raceDate.value : this.raceDate,
      courseType: data.courseType.present ? data.courseType.value : this.courseType,
      isPlanned: data.isPlanned.present ? data.isPlanned.value : this.isPlanned,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      durationS: data.durationS.present ? data.durationS.value : this.durationS,
      elevationGainM: data.elevationGainM.present ? data.elevationGainM.value : this.elevationGainM,
      teamSize: data.teamSize.present ? data.teamSize.value : this.teamSize,
      challengeDistanceM: data.challengeDistanceM.present ? data.challengeDistanceM.value : this.challengeDistanceM,
      isCharity: data.isCharity.present ? data.isCharity.value : this.isCharity,
      associationId: data.associationId.present ? data.associationId.value : this.associationId,
      associationName: data.associationName.present ? data.associationName.value : this.associationName,
      associationCause: data.associationCause.present ? data.associationCause.value : this.associationCause,
      associationDescription: data.associationDescription.present
          ? data.associationDescription.value
          : this.associationDescription,
      sponsorCentsPerKm: data.sponsorCentsPerKm.present ? data.sponsorCentsPerKm.value : this.sponsorCentsPerKm,
      registrationDonationCents: data.registrationDonationCents.present
          ? data.registrationDonationCents.value
          : this.registrationDonationCents,
      fundraisingCents: data.fundraisingCents.present ? data.fundraisingCents.value : this.fundraisingCents,
      impactMetric: data.impactMetric.present ? data.impactMetric.value : this.impactMetric,
      impactQuantity: data.impactQuantity.present ? data.impactQuantity.value : this.impactQuantity,
      bibPhotoKey: data.bibPhotoKey.present ? data.bibPhotoKey.value : this.bibPhotoKey,
      medalPhotoKey: data.medalPhotoKey.present ? data.medalPhotoKey.value : this.medalPhotoKey,
      notes: data.notes.present ? data.notes.value : this.notes,
      documents: data.documents.present ? data.documents.value : this.documents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('raceDate: $raceDate, ')
          ..write('courseType: $courseType, ')
          ..write('isPlanned: $isPlanned, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationS: $durationS, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('teamSize: $teamSize, ')
          ..write('challengeDistanceM: $challengeDistanceM, ')
          ..write('isCharity: $isCharity, ')
          ..write('associationId: $associationId, ')
          ..write('associationName: $associationName, ')
          ..write('associationCause: $associationCause, ')
          ..write('associationDescription: $associationDescription, ')
          ..write('sponsorCentsPerKm: $sponsorCentsPerKm, ')
          ..write('registrationDonationCents: $registrationDonationCents, ')
          ..write('fundraisingCents: $fundraisingCents, ')
          ..write('impactMetric: $impactMetric, ')
          ..write('impactQuantity: $impactQuantity, ')
          ..write('bibPhotoKey: $bibPhotoKey, ')
          ..write('medalPhotoKey: $medalPhotoKey, ')
          ..write('notes: $notes, ')
          ..write('documents: $documents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pending: $pending')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    raceDate,
    courseType,
    isPlanned,
    distanceM,
    durationS,
    elevationGainM,
    teamSize,
    challengeDistanceM,
    isCharity,
    associationId,
    associationName,
    associationCause,
    associationDescription,
    sponsorCentsPerKm,
    registrationDonationCents,
    fundraisingCents,
    impactMetric,
    impactQuantity,
    bibPhotoKey,
    medalPhotoKey,
    notes,
    documents,
    createdAt,
    updatedAt,
    deletedAt,
    pending,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.raceDate == this.raceDate &&
          other.courseType == this.courseType &&
          other.isPlanned == this.isPlanned &&
          other.distanceM == this.distanceM &&
          other.durationS == this.durationS &&
          other.elevationGainM == this.elevationGainM &&
          other.teamSize == this.teamSize &&
          other.challengeDistanceM == this.challengeDistanceM &&
          other.isCharity == this.isCharity &&
          other.associationId == this.associationId &&
          other.associationName == this.associationName &&
          other.associationCause == this.associationCause &&
          other.associationDescription == this.associationDescription &&
          other.sponsorCentsPerKm == this.sponsorCentsPerKm &&
          other.registrationDonationCents == this.registrationDonationCents &&
          other.fundraisingCents == this.fundraisingCents &&
          other.impactMetric == this.impactMetric &&
          other.impactQuantity == this.impactQuantity &&
          other.bibPhotoKey == this.bibPhotoKey &&
          other.medalPhotoKey == this.medalPhotoKey &&
          other.notes == this.notes &&
          other.documents == this.documents &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pending == this.pending);
}

class CoursesCompanion extends UpdateCompanion<CourseRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> raceDate;
  final Value<String> courseType;
  final Value<bool> isPlanned;
  final Value<int> distanceM;
  final Value<int> durationS;
  final Value<int?> elevationGainM;
  final Value<int?> teamSize;
  final Value<int?> challengeDistanceM;
  final Value<bool> isCharity;
  final Value<String?> associationId;
  final Value<String?> associationName;
  final Value<String?> associationCause;
  final Value<String?> associationDescription;
  final Value<int> sponsorCentsPerKm;
  final Value<int> registrationDonationCents;
  final Value<int> fundraisingCents;
  final Value<String> impactMetric;
  final Value<double?> impactQuantity;
  final Value<String?> bibPhotoKey;
  final Value<String?> medalPhotoKey;
  final Value<String?> notes;
  final Value<String> documents;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pending;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.raceDate = const Value.absent(),
    this.courseType = const Value.absent(),
    this.isPlanned = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.durationS = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.teamSize = const Value.absent(),
    this.challengeDistanceM = const Value.absent(),
    this.isCharity = const Value.absent(),
    this.associationId = const Value.absent(),
    this.associationName = const Value.absent(),
    this.associationCause = const Value.absent(),
    this.associationDescription = const Value.absent(),
    this.sponsorCentsPerKm = const Value.absent(),
    this.registrationDonationCents = const Value.absent(),
    this.fundraisingCents = const Value.absent(),
    this.impactMetric = const Value.absent(),
    this.impactQuantity = const Value.absent(),
    this.bibPhotoKey = const Value.absent(),
    this.medalPhotoKey = const Value.absent(),
    this.notes = const Value.absent(),
    this.documents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    required String title,
    required String raceDate,
    required String courseType,
    this.isPlanned = const Value.absent(),
    required int distanceM,
    required int durationS,
    this.elevationGainM = const Value.absent(),
    this.teamSize = const Value.absent(),
    this.challengeDistanceM = const Value.absent(),
    required bool isCharity,
    this.associationId = const Value.absent(),
    this.associationName = const Value.absent(),
    this.associationCause = const Value.absent(),
    this.associationDescription = const Value.absent(),
    required int sponsorCentsPerKm,
    required int registrationDonationCents,
    this.fundraisingCents = const Value.absent(),
    required String impactMetric,
    this.impactQuantity = const Value.absent(),
    this.bibPhotoKey = const Value.absent(),
    this.medalPhotoKey = const Value.absent(),
    this.notes = const Value.absent(),
    this.documents = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       raceDate = Value(raceDate),
       courseType = Value(courseType),
       distanceM = Value(distanceM),
       durationS = Value(durationS),
       isCharity = Value(isCharity),
       sponsorCentsPerKm = Value(sponsorCentsPerKm),
       registrationDonationCents = Value(registrationDonationCents),
       impactMetric = Value(impactMetric),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CourseRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? raceDate,
    Expression<String>? courseType,
    Expression<bool>? isPlanned,
    Expression<int>? distanceM,
    Expression<int>? durationS,
    Expression<int>? elevationGainM,
    Expression<int>? teamSize,
    Expression<int>? challengeDistanceM,
    Expression<bool>? isCharity,
    Expression<String>? associationId,
    Expression<String>? associationName,
    Expression<String>? associationCause,
    Expression<String>? associationDescription,
    Expression<int>? sponsorCentsPerKm,
    Expression<int>? registrationDonationCents,
    Expression<int>? fundraisingCents,
    Expression<String>? impactMetric,
    Expression<double>? impactQuantity,
    Expression<String>? bibPhotoKey,
    Expression<String>? medalPhotoKey,
    Expression<String>? notes,
    Expression<String>? documents,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pending,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (raceDate != null) 'race_date': raceDate,
      if (courseType != null) 'course_type': courseType,
      if (isPlanned != null) 'is_planned': isPlanned,
      if (distanceM != null) 'distance_m': distanceM,
      if (durationS != null) 'duration_s': durationS,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
      if (teamSize != null) 'team_size': teamSize,
      if (challengeDistanceM != null) 'challenge_distance_m': challengeDistanceM,
      if (isCharity != null) 'is_charity': isCharity,
      if (associationId != null) 'association_id': associationId,
      if (associationName != null) 'association_name': associationName,
      if (associationCause != null) 'association_cause': associationCause,
      if (associationDescription != null) 'association_description': associationDescription,
      if (sponsorCentsPerKm != null) 'sponsor_cents_per_km': sponsorCentsPerKm,
      if (registrationDonationCents != null) 'registration_donation_cents': registrationDonationCents,
      if (fundraisingCents != null) 'fundraising_cents': fundraisingCents,
      if (impactMetric != null) 'impact_metric': impactMetric,
      if (impactQuantity != null) 'impact_quantity': impactQuantity,
      if (bibPhotoKey != null) 'bib_photo_key': bibPhotoKey,
      if (medalPhotoKey != null) 'medal_photo_key': medalPhotoKey,
      if (notes != null) 'notes': notes,
      if (documents != null) 'documents': documents,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pending != null) 'pending': pending,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? raceDate,
    Value<String>? courseType,
    Value<bool>? isPlanned,
    Value<int>? distanceM,
    Value<int>? durationS,
    Value<int?>? elevationGainM,
    Value<int?>? teamSize,
    Value<int?>? challengeDistanceM,
    Value<bool>? isCharity,
    Value<String?>? associationId,
    Value<String?>? associationName,
    Value<String?>? associationCause,
    Value<String?>? associationDescription,
    Value<int>? sponsorCentsPerKm,
    Value<int>? registrationDonationCents,
    Value<int>? fundraisingCents,
    Value<String>? impactMetric,
    Value<double?>? impactQuantity,
    Value<String?>? bibPhotoKey,
    Value<String?>? medalPhotoKey,
    Value<String?>? notes,
    Value<String>? documents,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pending,
    Value<int>? rowid,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      raceDate: raceDate ?? this.raceDate,
      courseType: courseType ?? this.courseType,
      isPlanned: isPlanned ?? this.isPlanned,
      distanceM: distanceM ?? this.distanceM,
      durationS: durationS ?? this.durationS,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      teamSize: teamSize ?? this.teamSize,
      challengeDistanceM: challengeDistanceM ?? this.challengeDistanceM,
      isCharity: isCharity ?? this.isCharity,
      associationId: associationId ?? this.associationId,
      associationName: associationName ?? this.associationName,
      associationCause: associationCause ?? this.associationCause,
      associationDescription: associationDescription ?? this.associationDescription,
      sponsorCentsPerKm: sponsorCentsPerKm ?? this.sponsorCentsPerKm,
      registrationDonationCents: registrationDonationCents ?? this.registrationDonationCents,
      fundraisingCents: fundraisingCents ?? this.fundraisingCents,
      impactMetric: impactMetric ?? this.impactMetric,
      impactQuantity: impactQuantity ?? this.impactQuantity,
      bibPhotoKey: bibPhotoKey ?? this.bibPhotoKey,
      medalPhotoKey: medalPhotoKey ?? this.medalPhotoKey,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pending: pending ?? this.pending,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (raceDate.present) {
      map['race_date'] = Variable<String>(raceDate.value);
    }
    if (courseType.present) {
      map['course_type'] = Variable<String>(courseType.value);
    }
    if (isPlanned.present) {
      map['is_planned'] = Variable<bool>(isPlanned.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<int>(distanceM.value);
    }
    if (durationS.present) {
      map['duration_s'] = Variable<int>(durationS.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<int>(elevationGainM.value);
    }
    if (teamSize.present) {
      map['team_size'] = Variable<int>(teamSize.value);
    }
    if (challengeDistanceM.present) {
      map['challenge_distance_m'] = Variable<int>(challengeDistanceM.value);
    }
    if (isCharity.present) {
      map['is_charity'] = Variable<bool>(isCharity.value);
    }
    if (associationId.present) {
      map['association_id'] = Variable<String>(associationId.value);
    }
    if (associationName.present) {
      map['association_name'] = Variable<String>(associationName.value);
    }
    if (associationCause.present) {
      map['association_cause'] = Variable<String>(associationCause.value);
    }
    if (associationDescription.present) {
      map['association_description'] = Variable<String>(associationDescription.value);
    }
    if (sponsorCentsPerKm.present) {
      map['sponsor_cents_per_km'] = Variable<int>(sponsorCentsPerKm.value);
    }
    if (registrationDonationCents.present) {
      map['registration_donation_cents'] = Variable<int>(registrationDonationCents.value);
    }
    if (fundraisingCents.present) {
      map['fundraising_cents'] = Variable<int>(fundraisingCents.value);
    }
    if (impactMetric.present) {
      map['impact_metric'] = Variable<String>(impactMetric.value);
    }
    if (impactQuantity.present) {
      map['impact_quantity'] = Variable<double>(impactQuantity.value);
    }
    if (bibPhotoKey.present) {
      map['bib_photo_key'] = Variable<String>(bibPhotoKey.value);
    }
    if (medalPhotoKey.present) {
      map['medal_photo_key'] = Variable<String>(medalPhotoKey.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (documents.present) {
      map['documents'] = Variable<String>(documents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('raceDate: $raceDate, ')
          ..write('courseType: $courseType, ')
          ..write('isPlanned: $isPlanned, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationS: $durationS, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('teamSize: $teamSize, ')
          ..write('challengeDistanceM: $challengeDistanceM, ')
          ..write('isCharity: $isCharity, ')
          ..write('associationId: $associationId, ')
          ..write('associationName: $associationName, ')
          ..write('associationCause: $associationCause, ')
          ..write('associationDescription: $associationDescription, ')
          ..write('sponsorCentsPerKm: $sponsorCentsPerKm, ')
          ..write('registrationDonationCents: $registrationDonationCents, ')
          ..write('fundraisingCents: $fundraisingCents, ')
          ..write('impactMetric: $impactMetric, ')
          ..write('impactQuantity: $impactQuantity, ')
          ..write('bibPhotoKey: $bibPhotoKey, ')
          ..write('medalPhotoKey: $medalPhotoKey, ')
          ..write('notes: $notes, ')
          ..write('documents: $documents, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pending: $pending, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoOpsTable extends PhotoOps with TableInfo<$PhotoOpsTable, PhotoOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _photoKeyMeta = const VerificationMeta('photoKey');
  @override
  late final GeneratedColumn<String> photoKey = GeneratedColumn<String>(
    'photo_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PhotoOpKind, String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PhotoOpKind>($PhotoOpsTable.$converterkind);
  @override
  List<GeneratedColumn> get $columns => [photoKey, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_ops';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoOpRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('photo_key')) {
      context.handle(_photoKeyMeta, photoKey.isAcceptableOrUnknown(data['photo_key']!, _photoKeyMeta));
    } else if (isInserting) {
      context.missing(_photoKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {photoKey};
  @override
  PhotoOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoOpRow(
      photoKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}photo_key'])!,
      kind: $PhotoOpsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      ),
    );
  }

  @override
  $PhotoOpsTable createAlias(String alias) {
    return $PhotoOpsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PhotoOpKind, String, String> $converterkind = const EnumNameConverter<PhotoOpKind>(
    PhotoOpKind.values,
  );
}

class PhotoOpRow extends DataClass implements Insertable<PhotoOpRow> {
  final String photoKey;
  final PhotoOpKind kind;
  const PhotoOpRow({required this.photoKey, required this.kind});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['photo_key'] = Variable<String>(photoKey);
    {
      map['kind'] = Variable<String>($PhotoOpsTable.$converterkind.toSql(kind));
    }
    return map;
  }

  PhotoOpsCompanion toCompanion(bool nullToAbsent) {
    return PhotoOpsCompanion(photoKey: Value(photoKey), kind: Value(kind));
  }

  factory PhotoOpRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoOpRow(
      photoKey: serializer.fromJson<String>(json['photoKey']),
      kind: $PhotoOpsTable.$converterkind.fromJson(serializer.fromJson<String>(json['kind'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'photoKey': serializer.toJson<String>(photoKey),
      'kind': serializer.toJson<String>($PhotoOpsTable.$converterkind.toJson(kind)),
    };
  }

  PhotoOpRow copyWith({String? photoKey, PhotoOpKind? kind}) =>
      PhotoOpRow(photoKey: photoKey ?? this.photoKey, kind: kind ?? this.kind);
  PhotoOpRow copyWithCompanion(PhotoOpsCompanion data) {
    return PhotoOpRow(
      photoKey: data.photoKey.present ? data.photoKey.value : this.photoKey,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoOpRow(')
          ..write('photoKey: $photoKey, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(photoKey, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PhotoOpRow && other.photoKey == this.photoKey && other.kind == this.kind);
}

class PhotoOpsCompanion extends UpdateCompanion<PhotoOpRow> {
  final Value<String> photoKey;
  final Value<PhotoOpKind> kind;
  final Value<int> rowid;
  const PhotoOpsCompanion({
    this.photoKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoOpsCompanion.insert({required String photoKey, required PhotoOpKind kind, this.rowid = const Value.absent()})
    : photoKey = Value(photoKey),
      kind = Value(kind);
  static Insertable<PhotoOpRow> custom({
    Expression<String>? photoKey,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (photoKey != null) 'photo_key': photoKey,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoOpsCompanion copyWith({Value<String>? photoKey, Value<PhotoOpKind>? kind, Value<int>? rowid}) {
    return PhotoOpsCompanion(photoKey: photoKey ?? this.photoKey, kind: kind ?? this.kind, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (photoKey.present) {
      map['photo_key'] = Variable<String>(photoKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>($PhotoOpsTable.$converterkind.toSql(kind.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoOpsCompanion(')
          ..write('photoKey: $photoKey, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(Insertable<MetaRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String name;
  final String value;
  const MetaRow({required this.name, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(name: Value(name), value: Value(value));
  }

  factory MetaRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(name: serializer.fromJson<String>(json['name']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'name': serializer.toJson<String>(name), 'value': serializer.toJson<String>(value)};
  }

  MetaRow copyWith({String? name, String? value}) => MetaRow(name: name ?? this.name, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaCompanion data) {
    return MetaRow(
      name: data.name.present ? data.name.value : this.name,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MetaRow && other.name == this.name && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> name;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.name = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({required String name, required String value, this.rowid = const Value.absent()})
    : name = Value(name),
      value = Value(value);
  static Insertable<MetaRow> custom({Expression<String>? name, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({Value<String>? name, Value<String>? value, Value<int>? rowid}) {
    return MetaCompanion(name: name ?? this.name, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('name: $name, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $PhotoOpsTable photoOps = $PhotoOpsTable(this);
  late final $MetaTable meta = $MetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [courses, photoOps, meta];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  required String id,
  required String title,
  required String raceDate,
  required String courseType,
  Value<bool> isPlanned,
  required int distanceM,
  required int durationS,
  Value<int?> elevationGainM,
  Value<int?> teamSize,
  Value<int?> challengeDistanceM,
  required bool isCharity,
  Value<String?> associationId,
  Value<String?> associationName,
  Value<String?> associationCause,
  Value<String?> associationDescription,
  required int sponsorCentsPerKm,
  required int registrationDonationCents,
  Value<int> fundraisingCents,
  required String impactMetric,
  Value<double?> impactQuantity,
  Value<String?> bibPhotoKey,
  Value<String?> medalPhotoKey,
  Value<String?> notes,
  Value<String> documents,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> pending,
  Value<int> rowid,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> raceDate,
  Value<String> courseType,
  Value<bool> isPlanned,
  Value<int> distanceM,
  Value<int> durationS,
  Value<int?> elevationGainM,
  Value<int?> teamSize,
  Value<int?> challengeDistanceM,
  Value<bool> isCharity,
  Value<String?> associationId,
  Value<String?> associationName,
  Value<String?> associationCause,
  Value<String?> associationDescription,
  Value<int> sponsorCentsPerKm,
  Value<int> registrationDonationCents,
  Value<int> fundraisingCents,
  Value<String> impactMetric,
  Value<double?> impactQuantity,
  Value<String?> bibPhotoKey,
  Value<String?> medalPhotoKey,
  Value<String?> notes,
  Value<String> documents,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> pending,
  Value<int> rowid,
});

class $$CoursesTableFilterComposer extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get raceDate =>
      $composableBuilder(column: $table.raceDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseType =>
      $composableBuilder(column: $table.courseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPlanned =>
      $composableBuilder(column: $table.isPlanned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationS =>
      $composableBuilder(column: $table.durationS, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elevationGainM =>
      $composableBuilder(column: $table.elevationGainM, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get teamSize =>
      $composableBuilder(column: $table.teamSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get challengeDistanceM =>
      $composableBuilder(column: $table.challengeDistanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCharity =>
      $composableBuilder(column: $table.isCharity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get associationId =>
      $composableBuilder(column: $table.associationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get associationName =>
      $composableBuilder(column: $table.associationName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get associationCause =>
      $composableBuilder(column: $table.associationCause, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get associationDescription =>
      $composableBuilder(column: $table.associationDescription, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sponsorCentsPerKm =>
      $composableBuilder(column: $table.sponsorCentsPerKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get registrationDonationCents =>
      $composableBuilder(column: $table.registrationDonationCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fundraisingCents =>
      $composableBuilder(column: $table.fundraisingCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get impactMetric =>
      $composableBuilder(column: $table.impactMetric, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get impactQuantity =>
      $composableBuilder(column: $table.impactQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bibPhotoKey =>
      $composableBuilder(column: $table.bibPhotoKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medalPhotoKey =>
      $composableBuilder(column: $table.medalPhotoKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documents =>
      $composableBuilder(column: $table.documents, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => ColumnFilters(column));
}

class $$CoursesTableOrderingComposer extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get raceDate =>
      $composableBuilder(column: $table.raceDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseType =>
      $composableBuilder(column: $table.courseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPlanned =>
      $composableBuilder(column: $table.isPlanned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationS =>
      $composableBuilder(column: $table.durationS, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elevationGainM =>
      $composableBuilder(column: $table.elevationGainM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get teamSize =>
      $composableBuilder(column: $table.teamSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get challengeDistanceM =>
      $composableBuilder(column: $table.challengeDistanceM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCharity =>
      $composableBuilder(column: $table.isCharity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get associationId =>
      $composableBuilder(column: $table.associationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get associationName =>
      $composableBuilder(column: $table.associationName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get associationCause =>
      $composableBuilder(column: $table.associationCause, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get associationDescription =>
      $composableBuilder(column: $table.associationDescription, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sponsorCentsPerKm =>
      $composableBuilder(column: $table.sponsorCentsPerKm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get registrationDonationCents =>
      $composableBuilder(column: $table.registrationDonationCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fundraisingCents =>
      $composableBuilder(column: $table.fundraisingCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get impactMetric =>
      $composableBuilder(column: $table.impactMetric, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get impactQuantity =>
      $composableBuilder(column: $table.impactQuantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bibPhotoKey =>
      $composableBuilder(column: $table.bibPhotoKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medalPhotoKey =>
      $composableBuilder(column: $table.medalPhotoKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documents =>
      $composableBuilder(column: $table.documents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => ColumnOrderings(column));
}

class $$CoursesTableAnnotationComposer extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get raceDate => $composableBuilder(column: $table.raceDate, builder: (column) => column);

  GeneratedColumn<String> get courseType => $composableBuilder(column: $table.courseType, builder: (column) => column);

  GeneratedColumn<bool> get isPlanned => $composableBuilder(column: $table.isPlanned, builder: (column) => column);

  GeneratedColumn<int> get distanceM => $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<int> get durationS => $composableBuilder(column: $table.durationS, builder: (column) => column);

  GeneratedColumn<int> get elevationGainM =>
      $composableBuilder(column: $table.elevationGainM, builder: (column) => column);

  GeneratedColumn<int> get teamSize => $composableBuilder(column: $table.teamSize, builder: (column) => column);

  GeneratedColumn<int> get challengeDistanceM =>
      $composableBuilder(column: $table.challengeDistanceM, builder: (column) => column);

  GeneratedColumn<bool> get isCharity => $composableBuilder(column: $table.isCharity, builder: (column) => column);

  GeneratedColumn<String> get associationId =>
      $composableBuilder(column: $table.associationId, builder: (column) => column);

  GeneratedColumn<String> get associationName =>
      $composableBuilder(column: $table.associationName, builder: (column) => column);

  GeneratedColumn<String> get associationCause =>
      $composableBuilder(column: $table.associationCause, builder: (column) => column);

  GeneratedColumn<String> get associationDescription =>
      $composableBuilder(column: $table.associationDescription, builder: (column) => column);

  GeneratedColumn<int> get sponsorCentsPerKm =>
      $composableBuilder(column: $table.sponsorCentsPerKm, builder: (column) => column);

  GeneratedColumn<int> get registrationDonationCents =>
      $composableBuilder(column: $table.registrationDonationCents, builder: (column) => column);

  GeneratedColumn<int> get fundraisingCents =>
      $composableBuilder(column: $table.fundraisingCents, builder: (column) => column);

  GeneratedColumn<String> get impactMetric =>
      $composableBuilder(column: $table.impactMetric, builder: (column) => column);

  GeneratedColumn<double> get impactQuantity =>
      $composableBuilder(column: $table.impactQuantity, builder: (column) => column);

  GeneratedColumn<String> get bibPhotoKey =>
      $composableBuilder(column: $table.bibPhotoKey, builder: (column) => column);

  GeneratedColumn<String> get medalPhotoKey =>
      $composableBuilder(column: $table.medalPhotoKey, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get documents => $composableBuilder(column: $table.documents, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pending => $composableBuilder(column: $table.pending, builder: (column) => column);
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          CourseRow,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (CourseRow, BaseReferences<_$AppDatabase, $CoursesTable, CourseRow>),
          CourseRow,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> raceDate = const Value.absent(),
                Value<String> courseType = const Value.absent(),
                Value<bool> isPlanned = const Value.absent(),
                Value<int> distanceM = const Value.absent(),
                Value<int> durationS = const Value.absent(),
                Value<int?> elevationGainM = const Value.absent(),
                Value<int?> teamSize = const Value.absent(),
                Value<int?> challengeDistanceM = const Value.absent(),
                Value<bool> isCharity = const Value.absent(),
                Value<String?> associationId = const Value.absent(),
                Value<String?> associationName = const Value.absent(),
                Value<String?> associationCause = const Value.absent(),
                Value<String?> associationDescription = const Value.absent(),
                Value<int> sponsorCentsPerKm = const Value.absent(),
                Value<int> registrationDonationCents = const Value.absent(),
                Value<int> fundraisingCents = const Value.absent(),
                Value<String> impactMetric = const Value.absent(),
                Value<double?> impactQuantity = const Value.absent(),
                Value<String?> bibPhotoKey = const Value.absent(),
                Value<String?> medalPhotoKey = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> documents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                title: title,
                raceDate: raceDate,
                courseType: courseType,
                isPlanned: isPlanned,
                distanceM: distanceM,
                durationS: durationS,
                elevationGainM: elevationGainM,
                teamSize: teamSize,
                challengeDistanceM: challengeDistanceM,
                isCharity: isCharity,
                associationId: associationId,
                associationName: associationName,
                associationCause: associationCause,
                associationDescription: associationDescription,
                sponsorCentsPerKm: sponsorCentsPerKm,
                registrationDonationCents: registrationDonationCents,
                fundraisingCents: fundraisingCents,
                impactMetric: impactMetric,
                impactQuantity: impactQuantity,
                bibPhotoKey: bibPhotoKey,
                medalPhotoKey: medalPhotoKey,
                notes: notes,
                documents: documents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pending: pending,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String raceDate,
                required String courseType,
                Value<bool> isPlanned = const Value.absent(),
                required int distanceM,
                required int durationS,
                Value<int?> elevationGainM = const Value.absent(),
                Value<int?> teamSize = const Value.absent(),
                Value<int?> challengeDistanceM = const Value.absent(),
                required bool isCharity,
                Value<String?> associationId = const Value.absent(),
                Value<String?> associationName = const Value.absent(),
                Value<String?> associationCause = const Value.absent(),
                Value<String?> associationDescription = const Value.absent(),
                required int sponsorCentsPerKm,
                required int registrationDonationCents,
                Value<int> fundraisingCents = const Value.absent(),
                required String impactMetric,
                Value<double?> impactQuantity = const Value.absent(),
                Value<String?> bibPhotoKey = const Value.absent(),
                Value<String?> medalPhotoKey = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> documents = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion.insert(
                id: id,
                title: title,
                raceDate: raceDate,
                courseType: courseType,
                isPlanned: isPlanned,
                distanceM: distanceM,
                durationS: durationS,
                elevationGainM: elevationGainM,
                teamSize: teamSize,
                challengeDistanceM: challengeDistanceM,
                isCharity: isCharity,
                associationId: associationId,
                associationName: associationName,
                associationCause: associationCause,
                associationDescription: associationDescription,
                sponsorCentsPerKm: sponsorCentsPerKm,
                registrationDonationCents: registrationDonationCents,
                fundraisingCents: fundraisingCents,
                impactMetric: impactMetric,
                impactQuantity: impactQuantity,
                bibPhotoKey: bibPhotoKey,
                medalPhotoKey: medalPhotoKey,
                notes: notes,
                documents: documents,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pending: pending,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoursesTable, CourseRow>(table),
                  BaseReferences<_$AppDatabase, $CoursesTable, CourseRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      CourseRow,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (CourseRow, BaseReferences<_$AppDatabase, $CoursesTable, CourseRow>),
      CourseRow,
      PrefetchHooks Function()
    >;
typedef $$PhotoOpsTableCreateCompanionBuilder = PhotoOpsCompanion Function({
  required String photoKey,
  required PhotoOpKind kind,
  Value<int> rowid,
});
typedef $$PhotoOpsTableUpdateCompanionBuilder = PhotoOpsCompanion Function({
  Value<String> photoKey,
  Value<PhotoOpKind> kind,
  Value<int> rowid,
});

class $$PhotoOpsTableFilterComposer extends Composer<_$AppDatabase, $PhotoOpsTable> {
  $$PhotoOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get photoKey =>
      $composableBuilder(column: $table.photoKey, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PhotoOpKind, PhotoOpKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$PhotoOpsTableOrderingComposer extends Composer<_$AppDatabase, $PhotoOpsTable> {
  $$PhotoOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get photoKey =>
      $composableBuilder(column: $table.photoKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));
}

class $$PhotoOpsTableAnnotationComposer extends Composer<_$AppDatabase, $PhotoOpsTable> {
  $$PhotoOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get photoKey => $composableBuilder(column: $table.photoKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhotoOpKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$PhotoOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotoOpsTable,
          PhotoOpRow,
          $$PhotoOpsTableFilterComposer,
          $$PhotoOpsTableOrderingComposer,
          $$PhotoOpsTableAnnotationComposer,
          $$PhotoOpsTableCreateCompanionBuilder,
          $$PhotoOpsTableUpdateCompanionBuilder,
          (PhotoOpRow, BaseReferences<_$AppDatabase, $PhotoOpsTable, PhotoOpRow>),
          PhotoOpRow,
          PrefetchHooks Function()
        > {
  $$PhotoOpsTableTableManager(_$AppDatabase db, $PhotoOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PhotoOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PhotoOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PhotoOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> photoKey = const Value.absent(),
            Value<PhotoOpKind> kind = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PhotoOpsCompanion(photoKey: photoKey, kind: kind, rowid: rowid),
          createCompanionCallback: ({
            required String photoKey,
            required PhotoOpKind kind,
            Value<int> rowid = const Value.absent(),
          }) => PhotoOpsCompanion.insert(photoKey: photoKey, kind: kind, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotoOpsTable, PhotoOpRow>(table),
                  BaseReferences<_$AppDatabase, $PhotoOpsTable, PhotoOpRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotoOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotoOpsTable,
      PhotoOpRow,
      $$PhotoOpsTableFilterComposer,
      $$PhotoOpsTableOrderingComposer,
      $$PhotoOpsTableAnnotationComposer,
      $$PhotoOpsTableCreateCompanionBuilder,
      $$PhotoOpsTableUpdateCompanionBuilder,
      (PhotoOpRow, BaseReferences<_$AppDatabase, $PhotoOpsTable, PhotoOpRow>),
      PhotoOpRow,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String name,
  required String value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> name,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$MetaTableOrderingComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$MetaTableAnnotationComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaTable,
          MetaRow,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$AppDatabase, $MetaTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$AppDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(name: name, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String name,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(name: name, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaRow>(table),
                  BaseReferences<_$AppDatabase, $MetaTable, MetaRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaTable,
      MetaRow,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$AppDatabase, $MetaTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoursesTableTableManager get courses => $$CoursesTableTableManager(_db, _db.courses);
  $$PhotoOpsTableTableManager get photoOps => $$PhotoOpsTableTableManager(_db, _db.photoOps);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
