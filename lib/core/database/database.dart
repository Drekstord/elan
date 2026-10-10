import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../features/courses/domain/course.dart';

part 'database.g.dart';

/// Copie locale des courses de l'utilisateur, avec l'état de synchronisation.
@DataClassName('CourseRow')
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get raceDate => text()(); // AAAA-MM-JJ
  TextColumn get courseType => text()();
  BoolColumn get isPlanned => boolean().withDefault(const Constant(false))();
  IntColumn get distanceM => integer()();
  IntColumn get durationS => integer()();
  IntColumn get elevationGainM => integer().nullable()();

  /// Épreuve enchaînée, en JSON ([Multisport]) ; null pour les autres types.
  TextColumn get multisport => text().nullable()();
  IntColumn get teamSize => integer().nullable()();
  IntColumn get challengeDistanceM => integer().nullable()();
  BoolColumn get isCharity => boolean()();
  TextColumn get associationId => text().nullable()();
  TextColumn get associationName => text().nullable()();
  TextColumn get associationCause => text().nullable()();
  TextColumn get associationDescription => text().nullable()();
  IntColumn get sponsorCentsPerKm => integer()();
  IntColumn get registrationDonationCents => integer()();
  IntColumn get fundraisingCents => integer().withDefault(const Constant(0))();
  TextColumn get impactMetric => text()();
  RealColumn get impactQuantity => real().nullable()();
  TextColumn get bibPhotoKey => text().nullable()();
  TextColumn get medalPhotoKey => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Justificatifs, en JSON (liste de [CourseDocument]).
  TextColumn get documents => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Modifiée localement, pas encore confirmée par le serveur.
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

enum PhotoOpKind { upload, delete }

/// Opérations sur le bucket photos en attente d'envoi.
@DataClassName('PhotoOpRow')
class PhotoOps extends Table {
  TextColumn get photoKey => text()();
  TextColumn get kind => textEnum<PhotoOpKind>()();

  @override
  Set<Column> get primaryKey => {photoKey};
}

/// Petites valeurs persistantes (curseur de synchro, dates, drapeaux).
@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get name => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {name};
}

@DriftDatabase(tables: [Courses, PhotoOps, Meta])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Une base par utilisateur : deux comptes sur un même appareil ne se mélangent pas.
  factory AppDatabase.forUser(Directory dir, String userId) =>
      AppDatabase(NativeDatabase.createInBackground(File('${dir.path}${Platform.pathSeparator}elan_$userId.sqlite')));

  factory AppDatabase.inMemory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2 : course à venir, collecte ; suppression du taux d'impact par km.
        // La table est recréée au schéma actuel : toutes les colonnes postérieures à v1 sont nouvelles.
        await m.alterTable(
          TableMigration(
            courses,
            newColumns: [courses.isPlanned, courses.fundraisingCents, courses.documents, courses.multisport],
          ),
        );
      }
      if (from >= 2 && from < 3) {
        // v3 : justificatifs.
        await m.addColumn(courses, courses.documents);
      }
      if (from >= 2 && from < 4) {
        // v4 : épreuves enchaînées (triathlon, duathlon, aquathlon).
        await m.addColumn(courses, courses.multisport);
      }
    },
  );

  // -------------------------------------------------------------------
  // Méta
  // -------------------------------------------------------------------

  Future<String?> readMeta(String name) async =>
      (await (select(meta)..where((m) => m.name.equals(name))).getSingleOrNull())?.value;

  Future<void> writeMeta(String name, String value) =>
      into(meta).insertOnConflictUpdate(MetaCompanion.insert(name: name, value: value));

  // -------------------------------------------------------------------
  // Conversion ligne <-> modèle
  // -------------------------------------------------------------------

  static Course toCourse(CourseRow r) => Course(
    id: r.id,
    title: r.title,
    raceDate: parseIsoDate(r.raceDate),
    type: CourseType.parse(r.courseType),
    isPlanned: r.isPlanned,
    distanceM: r.distanceM,
    durationS: r.durationS,
    elevationGainM: r.elevationGainM,
    multisport: r.multisport == null ? null : Multisport.tryFromJson(jsonDecode(r.multisport!)),
    teamSize: r.teamSize,
    challengeDistanceM: r.challengeDistanceM,
    isCharity: r.isCharity,
    associationId: r.associationId,
    associationName: r.associationName,
    associationCause: CauseType.tryParse(r.associationCause),
    associationDescription: r.associationDescription,
    sponsorCentsPerKm: r.sponsorCentsPerKm,
    registrationDonationCents: r.registrationDonationCents,
    fundraisingCents: r.fundraisingCents,
    impactMetric: ImpactMetric.parse(r.impactMetric),
    impactQuantity: r.impactQuantity,
    bibPhotoKey: r.bibPhotoKey,
    medalPhotoKey: r.medalPhotoKey,
    notes: r.notes,
    documents: CourseDocument.listFromJson(jsonDecode(r.documents)),
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    deletedAt: r.deletedAt,
  );

  static CoursesCompanion toRow(Course c, {required bool pending}) => CoursesCompanion.insert(
    id: c.id,
    title: c.title,
    raceDate: formatIsoDate(c.raceDate),
    courseType: c.type.name,
    isPlanned: Value(c.isPlanned),
    distanceM: c.distanceM,
    durationS: c.durationS,
    elevationGainM: Value(c.elevationGainM),
    multisport: Value(c.multisport == null ? null : jsonEncode(c.multisport!.toJson())),
    teamSize: Value(c.teamSize),
    challengeDistanceM: Value(c.challengeDistanceM),
    isCharity: c.isCharity,
    associationId: Value(c.associationId),
    associationName: Value(c.associationName),
    associationCause: Value(c.associationCause?.name),
    associationDescription: Value(c.associationDescription),
    sponsorCentsPerKm: c.sponsorCentsPerKm,
    registrationDonationCents: c.registrationDonationCents,
    fundraisingCents: Value(c.fundraisingCents),
    impactMetric: c.impactMetric.name,
    impactQuantity: Value(c.impactQuantity),
    bibPhotoKey: Value(c.bibPhotoKey),
    medalPhotoKey: Value(c.medalPhotoKey),
    notes: Value(c.notes),
    documents: Value(jsonEncode([for (final d in c.documents) d.toJson()])),
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
    deletedAt: Value(c.deletedAt),
    pending: Value(pending),
  );
}
