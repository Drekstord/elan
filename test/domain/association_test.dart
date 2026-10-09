import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/impact/association_text.dart';
import 'package:app_course/features/impact/domain/association_summary.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Course race(
  String id,
  String? asso,
  DateTime date, {
  int cents = 0,
  bool charity = true,
  bool planned = false,
  CauseType cause = CauseType.environnement,
  ImpactMetric metric = ImpactMetric.euroDirect,
  double? quantity,
}) => Course(
  id: id,
  title: 'Course $id',
  raceDate: date,
  distanceM: 10000,
  durationS: planned ? 0 : 3000,
  isPlanned: planned,
  isCharity: charity,
  associationName: asso,
  associationCause: cause,
  registrationDonationCents: cents,
  impactMetric: metric,
  impactQuantity: quantity,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  final courses = [
    race('a', 'LES COQUELICOTS DE DÉMOVILLE', calendarDate(2026, 4, 1), cents: 800),
    race(
      'b',
      'Les Coquelicots de Démoville',
      calendarDate(2026, 10, 4),
      cents: 1200,
      metric: ImpactMetric.trees,
      quantity: 3,
    ),
    race('c', 'AEH', calendarDate(2026, 10, 5), cents: 3500, cause: CauseType.handicap),
    race('d', 'AEH', calendarDate(2027, 3, 1), cents: 9999, planned: true),
    race('e', 'Club', calendarDate(2026, 1, 1), charity: false),
  ];

  test('une association malgré la casse, la plus soutenue d\'abord, à venir et non solidaires exclues', () {
    final list = associationSummaries(courses);
    expect(list.map((a) => a.name), ['AEH', 'Les Coquelicots de Démoville']);
    final coquelicots = list.last;
    expect(coquelicots.courses.map((c) => c.id), ['a', 'b']);
    expect(coquelicots.donationCents, 2000);
    expect(coquelicots.distanceM, 20000);
    expect(coquelicots.causes, [CauseType.environnement]);
    expect(coquelicots.declared, {ImpactMetric.trees: 3});
    expect(list.first.courses.single.id, 'c');
    expect(associationSummary(courses, 'les coquelicots de démoville')!.courses, hasLength(2));
    expect(associationSummary(courses, 'Inconnue'), isNull);
  });

  test('texte du récapitulatif', () {
    final t = AppLocalizationsFr();
    final text = associationText(
      associationSummary(courses, 'Les Coquelicots de Démoville')!,
      t,
    ).replaceAll('\u202f', ' ').replaceAll('\u00a0', ' ');
    expect(text, startsWith('Récapitulatif ÉLAN : Les Coquelicots de Démoville'));
    expect(
      text,
      contains("2 courses solidaires du 1er avril 2026 au 4 octobre 2026, soit 20 km courus pour l'association."),
    );
    expect(text, contains('20 € engagés'));
    expect(text, contains('Cause soutenue : Environnement & climat.'));
    expect(text, contains('3 arbres plantés'));
    final one = associationText(associationSummary(courses, 'AEH')!, t).replaceAll('\u00a0', ' ');
    expect(one, contains("1 course solidaire le 5 octobre 2026, soit 10 km courus pour l'association."));
  });
}
