import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:app_course/app/format.dart';
import 'package:app_course/app/labels.dart';
import 'package:app_course/app/language.dart';
import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/l10n/app_localizations_en.dart';
import 'package:app_course/l10n/app_localizations_fr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Variables d'un texte : « {count} », « {distance} »… (les mots des pluriels ne comptent pas).
Set<String> _placeholders(String text) => {for (final m in RegExp(r'\{(\w+)[,}]').allMatches(text)) m[1]!};

void main() {
  Map<String, dynamic> arb(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;
  Map<String, String> texts(String code) => {
    for (final e in arb(code).entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };

  test('anglais : chaque texte français a sa traduction, avec les mêmes variables', () {
    final fr = texts('fr');
    final en = texts('en');
    expect(en.keys.toSet().difference(fr.keys.toSet()), isEmpty, reason: 'textes anglais sans équivalent français');
    expect(fr.keys.toSet().difference(en.keys.toSet()), isEmpty, reason: 'textes français non traduits');
    final meta = arb('fr');
    for (final key in fr.keys) {
      expect(en[key]!.trim(), isNotEmpty, reason: key);
      // Variables déclarées pour ce texte : toutes présentes dans la traduction.
      final declared = ((meta['@$key'] as Map?)?['placeholders'] as Map?)?.keys ?? const [];
      for (final name in declared) {
        expect(_placeholders(en[key]!), contains(name), reason: 'variable « $name » de « $key »');
      }
    }
  });

  test('langue affichée : le choix, sinon celle de l\'appareil, sinon le français', () {
    expect(resolveLocale('en', const [Locale('fr', 'FR')]), const Locale('en'));
    expect(resolveLocale(null, const [Locale('en', 'GB')]), const Locale('en'));
    expect(resolveLocale(null, const [Locale('fr', 'CA')]), const Locale('fr'));
    expect(resolveLocale(null, const [Locale('de'), Locale('en')]), const Locale('en'));
    expect(resolveLocale(null, const [Locale('de')]), const Locale('fr'));
    expect(resolveLocale('de', const [Locale('en')]), const Locale('en'), reason: 'choix inconnu ignoré');
  });

  group('affichage en anglais', () {
    setUpAll(initializeDateFormatting);
    setUp(() => formatLocale = 'en');
    tearDown(() => formatLocale = 'fr');

    test('nombres, dates et mois', () {
      expect(formatKm(21180), '21.18 km');
      expect(formatMeters(1250), '1,250 m');
      expect(formatSpeed(11.43), '11.4 km/h');
      expect(formatDay(calendarDate(2026, 9, 20)), '20 Sep 2026');
      expect(formatMonthShort(calendarDate(2026, 2, 1)), 'FEB');
      expect(metersToKmInput(10500), '10.5');
    });

    test('rangs et objectifs', () {
      final t = AppLocalizationsEn();
      expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 103, 111].map((n) => ordinal(n, t)), [
        '1st',
        '2nd',
        '3rd',
        '4th',
        '11th',
        '12th',
        '13th',
        '21st',
        '22nd',
        '103rd',
        '111th',
      ]);
      expect(rankLabel(142, 1250, t), '142nd of 1,250');
      expect(t.rankingTop(15), 'top 15%');
      final race = Course(
        id: 'a',
        title: 'a',
        raceDate: calendarDate(2026, 5, 17),
        distanceM: 10000,
        durationS: 2900,
        targetDurationS: 3000,
      );
      expect(targetLabel(race, t), 'Target beaten by 1:40');
      expect(t.summaryCourses(3), '3 races');
    });
  });

  test('le français reste inchangé', () {
    expect(formatKm(21180), '21,18 km');
    expect(ordinal(1, AppLocalizationsFr()), '1er');
    expect(formatMonthShort(calendarDate(2026, 2, 1)), 'FÉV');
  });
}
