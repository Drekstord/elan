import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/data/course_repository.dart';
import '../../features/courses/domain/course.dart';
import '../media/media_store.dart';

/// Reprise unique des données de la v1 (cache SharedPreferences, photos
/// référencées par chemin local) dans le compte du premier utilisateur
/// qui se connecte sur cet appareil. L'ancien cache est conservé en secours.
class LegacyImport {
  static const String _legacyKey = 'app_course_saved_runs';
  static const String _doneKey = 'legacy_v1_imported_to';

  static Future<int> runIfNeeded({required CourseRepository repository, required MediaStore media}) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_doneKey) != null) return 0;

    final raw = prefs.getString(_legacyKey);
    final courses = <Course>[];
    if (raw != null && raw.isNotEmpty) {
      for (final item in jsonDecode(raw) as List<dynamic>) {
        final json = item as Map<String, dynamic>;
        courses.add(
          fromV1(
            json,
            bibPhotoKey: await _importPhoto(media, json['bib_photo_path'] as String?),
            medalPhotoKey: await _importPhoto(media, json['medal_photo_path'] as String?),
          ),
        );
      }
    }
    final count = await repository.importCourses(courses);
    await prefs.setString(_doneKey, media.userId);
    return count;
  }

  static Future<String?> _importPhoto(MediaStore media, String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      return await media.importPhoto(file);
    } catch (_) {
      return null;
    }
  }

  /// Conversion d'une course v1 (euros et km en décimaux) vers le modèle actuel,
  /// avec les corrections de données que la v1 appliquait à chaque démarrage.
  static Course fromV1(Map<String, dynamic> json, {String? bibPhotoKey, String? medalPhotoKey}) {
    double? dbl(String key) => (json[key] as num?)?.toDouble();
    int cents(String key) => ((dbl(key) ?? 0) * 100).round();
    String? str(String key) => json[key] as String?;

    final isCharity = json['is_charity'] as bool? ?? true;
    final type = CourseType.parse(str('course_type'));
    final isTeam = json['is_team'] as bool? ?? false;
    final challengeKm = dbl('total_challenge_distance_km');
    final cause = CauseType.tryParse(str('association_cause'));
    final associationName = str('association_name');
    final description = str('association_description');
    // Les équivalences v1 calculées au km étaient fictives : seules les quantités
    // déclarées (ex. défi The Conqueror) sont conservées.
    var quantity = dbl('custom_impact_quantity');
    var metric = quantity == null ? ImpactMetric.euroDirect : ImpactMetric.parse(str('impact_metric'));

    // Pas d'équivalence « arbres » hors programme officiel de plantation.
    if (type != CourseType.theConqueror && str('association_id') != 'the-conqueror' && metric == ImpactMetric.trees) {
      metric = ImpactMetric.euroDirect;
      quantity = null;
    }

    final title = str('title') ?? 'Course';

    final created = DateTime.tryParse(str('created_at') ?? '');
    return Course(
      id: json['id'] as String,
      title: title,
      raceDate: parseIsoDate(json['date'] as String),
      type: type,
      distanceM: ((dbl('distance_km') ?? 0) * 1000).round(),
      durationS: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      elevationGainM: (json['elevation_gain'] as num?)?.toInt(),
      teamSize: isTeam ? (json['team_size'] as num?)?.toInt() : null,
      challengeDistanceM: challengeKm == null ? null : (challengeKm * 1000).round(),
      isCharity: isCharity,
      associationId: str('association_id'),
      associationName: associationName,
      associationCause: cause,
      associationDescription: description,
      sponsorCentsPerKm: cents('sponsored_euro_per_km'),
      registrationDonationCents: cents('registration_fee_donated'),
      impactMetric: metric,
      impactQuantity: quantity,
      bibPhotoKey: bibPhotoKey,
      medalPhotoKey: medalPhotoKey,
      notes: str('notes'),
      createdAt: created,
      updatedAt: DateTime.now(),
    );
  }
}
