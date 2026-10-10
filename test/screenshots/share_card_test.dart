// Cartes de partage : flutter test test/screenshots --tags screenshots --run-skipped --update-goldens
@Tags(['screenshots'])
library;

import 'package:app_course/app/theme/app_theme.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/presentation/share_card.dart';
import 'package:app_course/features/evolution/domain/year_recap.dart';
import 'package:app_course/features/evolution/presentation/year_recap_card.dart';
import 'package:app_course/features/report/domain/engagement_report.dart';
import 'package:app_course/features/report/presentation/report_card.dart';
import 'package:app_course/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import 'capture_test.dart' show loadTestFonts;

void main() {
  setUpAll(() async {
    await TestEnv.init();
    await loadTestFonts();
  });

  Future<void> card(WidgetTester tester, String name, Course course) async {
    final env = TestEnv();
    tester.view.physicalSize = kShareCardSize * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: env.container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Material(child: ShareCard(course: course)),
        ),
      ),
    );
    await env.settle(tester);
    await expectLater(find.byType(ShareCard), matchesGoldenFile('out/$name.png'));
    await env.dispose(tester);
  }

  testWidgets('bilan annuel', (tester) async {
    final env = TestEnv();
    tester.view.physicalSize = kShareCardSize * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final recap = YearRecap.of([
      Course(
        id: 'a',
        title: '10 km de Valfleuri',
        raceDate: calendarDate(2026, 5, 17),
        distanceM: 10000,
        durationS: 2900,
      ),
      Course(
        id: 'b',
        title: '10 km de Bois-Joli',
        raceDate: calendarDate(2025, 10, 12),
        distanceM: 10000,
        durationS: 3010,
      ),
      Course(
        id: 'c',
        title: 'Trail des Monts Imaginaires',
        raceDate: calendarDate(2026, 6, 14),
        distanceM: 173400,
        durationS: 31260,
        elevationGainM: 730,
        isCharity: true,
        associationName: 'Les Amis de Démoville',
        registrationDonationCents: 24500,
      ),
      Course(
        id: 'd',
        title: 'Semi de Démoville',
        raceDate: calendarDate(2026, 3, 8),
        distanceM: 21100,
        durationS: 6130,
      ),
    ], 2026);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: env.container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Material(child: YearRecapCard(recap: recap)),
        ),
      ),
    );
    await env.settle(tester);
    await expectLater(find.byType(YearRecapCard), matchesGoldenFile('out/bilan_annee.png'));
    await env.dispose(tester);
  });

  testWidgets(
    'carte solidaire',
    (t) => card(
      t,
      'partage_solidaire',
      Course(
        id: 'rett',
        title: 'Octobre Solidaire',
        raceDate: calendarDate(2026, 10, 4),
        distanceM: 7300,
        durationS: 3013,
        isCharity: true,
        associationName: 'Association Exemple Handicap',
        associationCause: CauseType.handicap,
        registrationDonationCents: 1000,
        fundraisingCents: 34000,
      ),
    ),
  );
  testWidgets(
    'carte défi avec équivalence',
    (t) => card(
      t,
      'partage_defi',
      Course(
        id: 'tc',
        title: 'The Conqueror · Grand Défi',
        type: CourseType.theConqueror,
        raceDate: calendarDate(2026, 8, 30),
        distanceM: 72500,
        isCharity: true,
        associationName: 'The Conqueror (Eden Reforestation)',
        associationCause: CauseType.environnement,
        registrationDonationCents: 5000,
        impactMetric: ImpactMetric.trees,
        impactQuantity: 4,
      ),
    ),
  );
  testWidgets(
    'carte officielle',
    (t) => card(
      t,
      'partage_officielle',
      Course(
        id: 'semi',
        title: 'Semi-marathon de Démoville',
        raceDate: calendarDate(2026, 3, 8),
        distanceM: 21180,
        durationS: 6130,
        elevationGainM: 90,
      ),
    ),
  );

  testWidgets('image du bilan : toutes les associations', (tester) async {
    final env = TestEnv();
    tester.view.physicalSize = const Size(kReportCardWidth, 700) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Course charity(
      String id,
      String asso,
      CauseType cause,
      int cents, {
      CourseType type = CourseType.officialRace,
      int km = 10,
      ImpactMetric metric = ImpactMetric.euroDirect,
      double? quantity,
    }) => Course(
      id: id,
      title: id,
      type: type,
      raceDate: calendarDate(2026, 3, 1),
      distanceM: km * 1000,
      durationS: type == CourseType.officialRace ? 3000 : 0,
      isCharity: true,
      associationName: asso,
      associationCause: cause,
      registrationDonationCents: cents,
      impactMetric: metric,
      impactQuantity: quantity,
    );
    final report = EngagementReport.of(
      [
        charity('rett', 'Association Exemple Handicap (AEH)', CauseType.handicap, 35000),
        charity('restos', 'Les Restos du Cœur', CauseType.precarite, 15000),
        charity(
          'tc',
          'The Conqueror (Eden Reforestation)',
          CauseType.environnement,
          3500,
          type: CourseType.theConqueror,
          km: 72,
          metric: ImpactMetric.trees,
          quantity: 4,
        ),
        charity(
          'tc2',
          'The Conqueror (Plastic Bank)',
          CauseType.environnement,
          5000,
          type: CourseType.theConqueror,
          km: 56,
          metric: ImpactMetric.oceanBottles,
          quantity: 40,
        ),
        charity('telethon', 'AFM-Téléthon', CauseType.sante, 2000),
        charity('spa', 'SPA de Paris', CauseType.animaux, 1000),
      ],
      from: calendarDate(2025, 9, 1),
      to: calendarDate(2026, 8, 31),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: env.container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Material(
            child: Align(
              alignment: Alignment.topLeft,
              child: ReportCard(report: report),
            ),
          ),
        ),
      ),
    );
    await env.settle(tester);
    await expectLater(find.byType(ReportCard), matchesGoldenFile('out/bilan_image.png'));
    await env.dispose(tester);
  });
}
