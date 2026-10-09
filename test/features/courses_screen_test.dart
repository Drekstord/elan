import 'package:app_course/app/format.dart';
import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/app/widgets/date_picker.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/impact/presentation/impact_screen.dart';
import 'package:app_course/features/documents/presentation/document_widgets.dart';
import 'package:app_course/features/records/presentation/gallery_screen.dart';
import 'package:app_course/features/records/presentation/records_screen.dart';
import 'package:app_course/features/report/presentation/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Course race(
  String id,
  String title, {
  DateTime? date,
  int distanceM = 10000,
  int durationS = 3000,
  bool planned = false,
  bool charity = false,
  int registrationCents = 0,
  ImpactMetric metric = ImpactMetric.euroDirect,
  double? quantity,
  CauseType? cause,
  String? association,
}) => Course(
  id: id,
  title: title,
  raceDate: date ?? calendarDate(2026, 9, 1),
  distanceM: distanceM,
  durationS: durationS,
  isPlanned: planned,
  isCharity: charity,
  registrationDonationCents: registrationCents,
  impactMetric: metric,
  impactQuantity: quantity,
  associationCause: cause,
  associationName: association,
);

void main() {
  setUpAll(TestEnv.init);

  testWidgets('liste : totaux, rappel des résultats à saisir, courses à venir', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      race('a', 'Trail des Monts Imaginaires', distanceM: 15200, durationS: 4560),
      race('b', 'Semi de Paris', planned: true, durationS: 0, date: calendarDate(2026, 10, 4)),
      race('c', 'Marathon de Mont-Fictif', planned: true, durationS: 0, date: calendarDate(2026, 11, 2)),
    ]);
    await env.pump(tester);

    expect(find.text('TRAIL DES MONTS IMAGINAIRES'), findsOneWidget);
    expect(find.textContaining('15,2 km'), findsWidgets);
    expect(find.text('1 COURSE ATTEND TON RÉSULTAT'), findsOneWidget);
    expect(find.text('À SAISIR'), findsOneWidget);
    expect(find.text('À VENIR'), findsWidgets);
    expect(find.text('J-25'), findsWidgets); // liste + « Prochaine course » en disposition large
    // Les courses à venir ne comptent pas : seule la course terminée est totalisée.
    expect(find.text('15'), findsWidgets); // chiffre héros (et barre du mois en disposition large)

    await env.dispose(tester);
  });

  testWidgets('filtres : type + volet solidaire, résumés en une phrase', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      race('a', 'Semi de Paris'),
      race('b', 'Course du Cœur', charity: true, cause: CauseType.precarite),
      Course(
        id: 'c',
        title: 'Grand Défi',
        type: CourseType.theConqueror,
        raceDate: calendarDate(2026, 8, 1),
        distanceM: 72500,
        isCharity: true,
        associationCause: CauseType.environnement,
      ),
      Course(
        id: 'd',
        title: 'Hobbit',
        type: CourseType.theConqueror,
        raceDate: calendarDate(2026, 7, 1),
        distanceM: 50000,
      ),
    ]);
    await env.pump(tester);

    await tester.tap(find.text('Défis'));
    await tester.pump();
    expect(find.text('2 défis'), findsOneWidget);

    await tester.tap(find.text('Solidaires ou non'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solidaires uniquement').last);
    await tester.pumpAndSettle();
    expect(find.text('1 défi solidaire'), findsOneWidget);
    expect(find.text('GRAND DÉFI'), findsOneWidget);
    expect(find.text('HOBBIT'), findsNothing);

    await tester.tap(find.text('Officielles'));
    await tester.pump();
    expect(find.text('1 course officielle solidaire'), findsOneWidget);
    expect(find.text('COURSE DU CŒUR'), findsOneWidget);

    await tester.tap(find.text('Effacer les filtres'));
    await tester.pump();
    expect(find.text('SEMI DE PARIS'), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('formulaire : validation puis enregistrement d\'une course à venir', (tester) async {
    final env = TestEnv();
    await env.pump(tester, location: '/courses/nouvelle');

    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    expect(find.text('Donne un nom à la course.'), findsWidgets);

    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), 'Marathon de Port-Imaginaire');
    await tester.enterText(find.widgetWithText(TextField, 'Distance (km)'), '42,195');
    await tester.tap(find.text('Course à venir'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Temps (h:mm:ss)'), findsNothing);

    await tester.tap(find.text('Enregistrer'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single;
    expect(saved.title, 'Marathon de Port-Imaginaire');
    expect(saved.distanceM, 42195);
    expect(saved.isPlanned, isTrue);
    expect(saved.durationS, 0);
    await env.dispose(tester);
  });

  testWidgets('formulaire : course solidaire avec dons', (tester) async {
    final env = TestEnv();
    await env.pump(tester, location: '/courses/nouvelle');

    await tester.enterText(find.widgetWithText(TextField, 'Nom de la course'), 'Course du Cœur');
    await tester.enterText(find.widgetWithText(TextField, 'Distance (km)'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Temps (h:mm:ss)'), '52:30');
    await tester.tap(find.text('Course solidaire'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Parrainage (€ par km)'), '1,5');
    await tester.enterText(find.widgetWithText(TextField, 'Don sur l\'inscription (€)'), '15');
    await tester.pump();
    expect(findText('Total engagé : 30 €'), findsOneWidget);

    await tester.tap(find.text('Enregistrer'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single;
    expect(saved.isCharity, isTrue);
    expect(saved.durationS, 3150);
    expect(saved.donationCents, 3000);
    expect(saved.isPlanned, isFalse);
    await env.dispose(tester);
  });

  testWidgets('fiche : saisie du résultat d\'une course passée', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      race('b', 'Semi de Paris', planned: true, durationS: 0, distanceM: 21097, date: calendarDate(2026, 10, 4)),
    ]);
    await env.pump(tester, location: '/courses/b');

    expect(find.text('Saisir mon résultat'), findsOneWidget);
    await tester.tap(find.text('Saisir mon résultat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.widgetWithText(TextField, 'Temps (h:mm:ss)'), '1:45:10');
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await env.settle(tester);
    await tester.pump(const Duration(milliseconds: 300));

    final done = (await env.stored(tester)).single;
    expect(done.isPlanned, isFalse);
    expect(done.durationS, 6310);
    expect(find.text('Saisir mon résultat'), findsNothing);
    expect(find.text(formatDuration(6310)), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('impact : euros réels et équivalences déclarées', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      race(
        'a',
        'Téléthon',
        charity: true,
        registrationCents: 2000,
        cause: CauseType.sante,
        association: 'AFM-Téléthon',
      ),
      race(
        'b',
        'The Conqueror',
        charity: true,
        metric: ImpactMetric.trees,
        quantity: 4,
        cause: CauseType.environnement,
      ),
    ]);
    await env.pump(tester, home: const ImpactScreen());
    await tester.pump(const Duration(seconds: 2)); // fin du défilement des chiffres

    expect(findText('20 €'), findsWidgets);
    expect(find.text('ARBRES PLANTÉS'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('AFM-Téléthon'), findsOneWidget);
    await env.dispose(tester);
  });

  testWidgets('records : podium par distance de référence', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      race('a', '10 km de Valfleuri', distanceM: 10050, durationS: 2950),
      race('b', '10 km de Bois-Joli', distanceM: 10000, durationS: 2800),
    ]);
    await env.pump(tester, home: const RecordsScreen());

    expect(find.text('10 KM'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('10 KM DE BOIS-JOLI').first).dy,
      lessThan(tester.getTopLeft(find.text('10 KM DE VALFLEURI').first).dy),
    );
    await env.dispose(tester);
  });

  testWidgets('bilan : période, texte et tableau prêts à copier', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      race('a', 'Course du Cœur', charity: true, registrationCents: 1500, association: 'Les Restos du Cœur'),
      race('b', 'Semi de Paris', date: calendarDate(2026, 9, 20)),
    ]);
    await env.pump(tester, home: const ReportScreen());

    expect(find.textContaining('Bilan ÉLAN du 1er septembre 2026 au 31 août 2027'), findsOneWidget);
    expect(find.textContaining('Les Restos du Cœur'), findsWidgets);
    final table = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text('Copier le tableau'), matching: find.bySubtype<ButtonStyleButton>()),
    );
    expect(table.onPressed, isNotNull);
    await env.dispose(tester);
  });

  testWidgets("calendrier : le bouton Aujourd'hui revient au jour même", (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await pickDate(
              context,
              initialDate: DateTime(2020, 5, 17),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            child: const Text('ouvrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    expect(find.text('Dimanche 17 mai 2020'), findsOneWidget);
    await tester.tap(find.text("Aujourd'hui"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    expect(picked, DateTime(now.year, now.month, now.day));
  });

  testWidgets('galerie : vignettes par année, avec le nom de la course', (tester) async {
    final env = TestEnv();
    await env.seed(tester, [
      Course(id: 'a', title: 'Trail', raceDate: calendarDate(2025, 5, 1), distanceM: 1, medalPhotoKey: 'u/a.jpg'),
      Course(
        id: 'b',
        title: 'Semi',
        raceDate: calendarDate(2026, 5, 1),
        distanceM: 1,
        medalPhotoKey: 'u/b.jpg',
        bibPhotoKey: 'u/c.jpg',
      ),
    ]);
    await env.pump(tester, home: const GalleryScreen());

    expect(find.text('2026'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);
    expect(find.text('SEMI'), findsNWidgets(2));
    expect(find.text('TRAIL'), findsOneWidget);
    await tester.tap(find.text('Dossards'));
    await tester.pump();
    expect(find.text('SEMI'), findsOneWidget);
    expect(find.text('TRAIL'), findsNothing);
    await env.dispose(tester);
  });

  testWidgets('justificatif : changer le type depuis le menu', (tester) async {
    final env = TestEnv();
    final course = race('a', 'Semi').copyWith(
      documents: [CourseDocument(key: 'u/docs/x.pdf', name: 'scan.pdf', sizeBytes: 2048, addedAt: DateTime.utc(2026))],
    );
    await env.seed(tester, [course]);
    await env.pump(
      tester,
      home: Scaffold(body: CourseDocumentsCard(course: course)),
    );

    expect(find.text('scan.pdf'), findsOneWidget); // sans type : désigné par son nom
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Changer le type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Facture'));
    await env.settle(tester);

    final saved = (await env.stored(tester)).single.documents.single;
    expect(saved.kind, DocumentKind.invoice);
    expect(saved.name, 'scan.pdf');
    await env.dispose(tester);
  });

  test('saisie et formats', () {
    expect(parseDuration('1:05:30'), 3930);
    expect(parseDuration('45:10'), 2710);
    expect(parseDuration('45'), 2700);
    expect(parseDuration('1:75:00'), isNull);
    expect(parseDuration('abc'), isNull);
    expect(formatDuration(3930), '1:05:30');
    expect(formatPace(255.9), '4\'16" /km');
    expect(parseEurosToCents('1,5'), 150);
    expect(formatEurosAmount(124000), '1 240');
    expect(formatEurosAmount(2150).contains('€'), isFalse);
  });
}
