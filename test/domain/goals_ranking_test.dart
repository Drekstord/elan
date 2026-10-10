import 'package:app_course/app/labels.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/courses/domain/course_stats.dart';
import 'package:app_course/features/widget/home_screen_widget.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';

Course race(
  String id, {
  int distanceM = 10000,
  int durationS = 2900,
  int? target,
  Ranking? ranking,
  bool planned = false,
  DateTime? date,
}) => Course(
  id: id,
  title: id,
  raceDate: date ?? calendarDate(2026, 5, 17),
  distanceM: distanceM,
  durationS: planned ? 0 : durationS,
  isPlanned: planned,
  targetDurationS: target,
  ranking: ranking,
);

void main() {
  final t = AppLocalizationsFr();

  group('temps visé', () {
    test('écart au temps visé : battu, manqué, atteint', () {
      expect(race('a', target: 3000).targetDeltaS, -100);
      expect(race('b', target: 2800).targetDeltaS, 100);
      expect(race('c', target: 2900).targetDeltaS, 0);
      expect(race('d').targetDeltaS, isNull);
      expect(race('e', target: 3000, planned: true).targetDeltaS, isNull, reason: 'pas encore courue');
    });

    test('libellés', () {
      expect(targetLabel(race('a', target: 3000), t), 'Objectif battu de 1:40');
      expect(targetLabel(race('b', target: 2800), t), 'Objectif manqué de 1:40');
      expect(targetLabel(race('c', target: 2900), t), 'Objectif atteint');
      expect(targetLabel(race('e', target: 3000, planned: true), t), 'Objectif 50:00');
      expect(targetLabel(race('f', durationS: 13500, target: 12600), t), 'Objectif manqué de 15:00');
      expect(targetLabel(race('g', durationS: 9000, target: 12700), t), 'Objectif battu de 1:01:40');
      expect(targetLabel(race('d'), t), isNull);
    });

    test('un temps visé nul ou négatif ne compte pas', () {
      expect(race('a', target: 0).targetDurationS, isNull);
      expect(race('a', target: 0).detailsJson, isNull);
    });
  });

  group('classement', () {
    const ranking = Ranking(overall: 142, finishers: 980, category: 12, categoryFinishers: 85, categoryName: 'SEH');

    test('part des arrivants', () {
      expect(ranking.overallPercent, closeTo(14.49, 0.01));
      expect(ranking.categoryPercent, closeTo(14.12, 0.01));
      expect(const Ranking(overall: 5).overallPercent, isNull);
      expect(const Ranking(overall: 50, finishers: 40).overallPercent, isNull, reason: 'place incohérente');
    });

    test('libellés : 1er, 2e, avec ou sans le nombre d\'arrivants', () {
      expect(rankLabel(1, 980, t).replaceAll(RegExp('[\u00a0\u202f]'), ' '), '1er sur 980');
      expect(rankLabel(142, null, t), '142e');
      expect(rankingSummary(ranking, t).replaceAll(RegExp('[\u00a0\u202f]'), ' '), '142e sur 980 · SEH 12e sur 85');
      expect(rankingSummary(const Ranking(categoryName: 'M1'), t), 'M1');
    });

    test('aller-retour serveur : objectif et classement dans « details »', () {
      final course = race('a', target: 3000, ranking: ranking);
      final json = course.toRemoteJson();
      expect(json['details'], {
        'target_s': 3000,
        'ranking': {'overall': 142, 'finishers': 980, 'category': 12, 'category_finishers': 85, 'category_name': 'SEH'},
      });
      final back = Course.fromRemoteJson(json);
      expect(back.targetDurationS, 3000);
      expect(back.ranking, ranking);
    });

    test('rien de saisi : « details » vide ; ancien serveur sans la colonne : rien ne casse', () {
      expect(race('a').toRemoteJson()['details'], isNull);
      expect(race('a', ranking: const Ranking()).ranking, isNull);
      final json = race('a').toRemoteJson()..remove('details');
      expect(Course.fromRemoteJson(json).ranking, isNull);
      expect(Ranking.tryFromJson({'overall': 0, 'category_name': '  '}), isNull);
    });
  });

  group('objectif annuel', () {
    final courses = [
      race('a', distanceM: 120000, date: calendarDate(2026, 3, 1)),
      race('b', distanceM: 87000, date: calendarDate(2026, 6, 1)),
      race('avant', distanceM: 50000, date: calendarDate(2025, 6, 1)),
      race('a-venir', distanceM: 42195, planned: true, date: calendarDate(2026, 11, 1)),
    ];

    test('avancement : année en cours seulement, courses terminées seulement', () {
      final p = goalProgress(courses, calendarDate(2026, 7, 2), 500000);
      expect(p.doneM, 207000);
      // 2 juillet : 183e jour sur 365, soit la moitié de l'année.
      expect(p.expectedM, closeTo(250685, 1));
      expect(p.aheadM, lessThan(0));
      expect(p.ratio, closeTo(0.414, 0.001));
      expect(p.reached, isFalse);
    });

    test('objectif dépassé : la jauge reste pleine', () {
      final p = goalProgress(courses, calendarDate(2026, 12, 31), 200000);
      expect(p.reached, isTrue);
      expect(p.ratio, 1);
      expect(p.expectedM, 200000);
    });

    test('widget Android : « 207 / 500 » avec un objectif, « 207 » sans', () {
      final today = calendarDate(2026, 7, 2);
      expect(homeWidgetData(courses, today, goalM: 500000).yearKm, '207 / 500');
      expect(homeWidgetData(courses, today).yearKm, '207');
      expect(homeWidgetData(courses, today, goalM: 500000) == homeWidgetData(courses, today), isFalse);
    });
  });
}
