import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/text.dart';
import '../domain/association.dart';
import 'association_catalog.dart';

/// Recherche d'associations : catalogue intégré, puis répertoire officiel
/// SIRENE (recherche-entreprises.api.gouv.fr, gratuit, sans clé).
class AssociationSearch {
  static const Duration _timeout = Duration(seconds: 6);

  final http.Client _client;

  AssociationSearch(this._client);

  /// Correspondances du catalogue, sans réseau.
  static List<Association> searchCatalog(String query) {
    final needle = fold(query.trim());
    if (needle.isEmpty) return associationCatalog;
    return associationCatalog
        .where((a) => fold(a.name).contains(needle) || fold(a.description ?? '').contains(needle))
        .toList();
  }

  /// Associations actives du répertoire officiel. Lève une exception si le service est injoignable.
  Future<List<Association>> searchOfficial(String query, {int limit = 10}) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    final uri = Uri.https('recherche-entreprises.api.gouv.fr', '/search', {
      'q': q,
      'est_association': 'true',
      'etat_administratif': 'A',
      'per_page': '$limit',
    });
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('Recherche indisponible (${response.statusCode})', uri);
    }
    return parseOfficialResults(jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
  }

  static List<Association> parseOfficialResults(Map<String, dynamic> json) {
    final results = <Association>[];
    for (final item in (json['results'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>()) {
      final siren = item['siren'] as String?;
      final rawName = item['nom_complet'] as String? ?? '';
      if (siren == null || rawName.isEmpty) continue;
      final siege = item['siege'] as Map<String, dynamic>? ?? const {};
      final complements = item['complements'] as Map<String, dynamic>? ?? const {};
      final name = formatOfficialName(rawName);
      final city = siege['libelle_commune'] as String?;
      results.add(
        Association(
          id: 'siren-$siren',
          name: name,
          cause: inferCause(name: name, nafCode: siege['activite_principale'] as String?),
          siren: siren,
          rna: complements['identifiant_association'] as String?,
          city: city == null ? null : formatOfficialName(city),
        ),
      );
    }
    return results;
  }
}

final associationSearchProvider = Provider<AssociationSearch>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return AssociationSearch(client);
});
