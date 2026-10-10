import 'dart:io';

import 'package:app_course/app/format.dart';
import 'package:app_course/core/sync/sync_engine.dart';
import 'package:app_course/features/courses/courses_providers.dart';
import 'package:app_course/features/documents/presentation/document_widgets.dart';
import 'package:app_course/features/impact/data/association_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../helpers.dart';

/// Laisse le temps à l'accord avec le serveur (lancé en arrière-plan) de se terminer.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  setUpAll(TestEnv.init);

  group('objectif annuel entre appareils', () {
    test('fixé ici : gardé sur l\'appareil et envoyé au serveur', () async {
      final env = TestEnv();
      addTearDown(env.db.close);
      expect(await env.container.read(yearGoalProvider.future), isNull);

      await env.container.read(yearGoalProvider.notifier).set(500000);
      expect(env.container.read(yearGoalProvider).value, 500000);
      expect(await env.db.readMeta('goal.year_m'), '500000');
      expect(env.backend.preferences!['goal_year_m'], 500000);
      expect(env.backend.preferences!['goal_updated_ms'], isPositive);
    });

    test('fixé sur un autre appareil : retrouvé ici à l\'ouverture', () async {
      final env = TestEnv();
      addTearDown(env.db.close);
      env.backend.preferences = {'goal_year_m': 750000, 'goal_updated_ms': 1790000000000, 'autre': 'gardé'};

      expect(await env.container.read(yearGoalProvider.future), isNull, reason: 'd\'abord la copie de l\'appareil');
      await settle();
      expect(env.container.read(yearGoalProvider).value, 750000);
      expect(await env.db.readMeta('goal.year_m'), '750000');
    });

    test('le changement le plus récent l\'emporte, dans les deux sens', () async {
      final env = TestEnv();
      addTearDown(env.db.close);
      await env.db.writeMeta('goal.year_m', '300000');
      await env.db.writeMeta('goal.updated_ms', '1790000000500');
      env.backend.preferences = {'goal_year_m': 750000, 'goal_updated_ms': 1790000000000, 'autre': 'gardé'};

      expect(await env.container.read(yearGoalProvider.future), 300000);
      await settle();
      // L'appareil était plus récent : le serveur est mis à jour, sans perdre ses autres préférences.
      expect(env.container.read(yearGoalProvider).value, 300000);
      expect(env.backend.preferences, {'goal_year_m': 300000, 'goal_updated_ms': 1790000000500, 'autre': 'gardé'});
    });

    test('objectif retiré ailleurs : retiré ici aussi', () async {
      final env = TestEnv();
      addTearDown(env.db.close);
      await env.db.writeMeta('goal.year_m', '300000');
      await env.db.writeMeta('goal.updated_ms', '1790000000000');
      env.backend.preferences = {'goal_year_m': 0, 'goal_updated_ms': 1790000000900};

      expect(await env.container.read(yearGoalProvider.future), 300000);
      await settle();
      expect(env.container.read(yearGoalProvider).value, isNull);
    });

    test('serveur qui ne garde pas les préférences : l\'objectif reste sur l\'appareil', () async {
      final env = TestEnv();
      addTearDown(env.db.close);
      env.backend.failPreferences = true;
      expect(await env.container.read(yearGoalProvider.future), isNull);
      await env.container.read(yearGoalProvider.notifier).set(400000);
      expect(env.container.read(yearGoalProvider).value, 400000);
      expect(await env.db.readMeta('goal.year_m'), '400000');
    });
  });

  group('derniers textes en anglais', () {
    setUp(() {
      formatLocale = 'en';
      Intl.defaultLocale = 'en';
    });
    tearDown(() {
      formatLocale = 'fr';
      Intl.defaultLocale = null;
    });

    test('erreurs de synchronisation', () {
      expect(describeSyncError(const SocketException('x')), startsWith('No connection.'));
    });

    test('taille des fichiers', () {
      expect(formatBytes(180 * 1024), '180 KB');
      expect(formatBytes(1258291), '1.2 MB');
    });

    test('associations du catalogue : description traduite ; saisie libre : inchangée', () {
      expect(
        associationDescription(id: 'restos-du-coeur', stored: 'Aider les personnes démunies.', language: 'en'),
        'Helping people in need, in particular through free meals.',
      );
      expect(associationDescription(id: '', stored: 'Texte saisi.', language: 'en'), 'Texte saisi.');
      expect(associationDescription(id: 'restos-du-coeur', stored: null, language: 'en'), isNull);
      // Chaque association du catalogue a sa description anglaise.
      for (final a in associationCatalog) {
        expect(
          associationDescription(id: a.id, stored: a.description, language: 'en'),
          isNot(a.description),
          reason: a.id,
        );
      }
    });
  });

  test('en français, rien ne change', () {
    expect(describeSyncError(const SocketException('x')), startsWith('Pas de connexion.'));
    expect(formatBytes(1258291), '1,2 Mo');
    expect(
      associationDescription(id: 'restos-du-coeur', stored: 'Aider les personnes démunies.', language: 'fr'),
      'Aider les personnes démunies.',
    );
  });
}
