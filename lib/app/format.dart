import 'package:intl/intl.dart';

/// Formats d'affichage communs (français, chiffres lisibles).

/// Distance sans zéros superflus : « 42,2 km », « 10 km », « 21,18 km ».
String formatKm(int meters, {int decimals = 2}) =>
    '${NumberFormat(decimals == 0 ? '#,##0' : '#,##0.${'#' * decimals}', 'fr').format(meters / 1000)} km';

String formatDuration(int seconds) {
  if (seconds <= 0) return '--:--';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Durée longue : « 12 h 05 min ».
String formatLongDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  return h > 0 ? '$h h ${m.toString().padLeft(2, '0')} min' : '$m min';
}

/// Allure : « 4'16" /km ».
String formatPace(double? secondsPerKm) {
  if (secondsPerKm == null || secondsPerKm <= 0) return '--';
  final total = secondsPerKm.round();
  return '${total ~/ 60}\'${(total % 60).toString().padLeft(2, '0')}" /km';
}

String formatSpeed(double? kmh) => kmh == null ? '--' : '${NumberFormat('0.0', 'fr').format(kmh)} km/h';

String formatMeters(int meters) => '${NumberFormat('#,##0', 'fr').format(meters)} m';

String formatEuros(int cents) =>
    NumberFormat.currency(locale: 'fr', symbol: '€', decimalDigits: cents % 100 == 0 ? 0 : 2).format(cents / 100);

/// Montant sans le symbole, pour les chiffres héros où « € » est affiché à part : « 1 240 ».
String formatEurosAmount(int cents) => formatEuros(cents).replaceAll(RegExp(r'\s?€'), '');

/// Quantité déclarée : entière si possible.
String formatQuantity(double value) => value == value.roundToDouble()
    ? NumberFormat('#,##0', 'fr').format(value)
    : NumberFormat('#,##0.#', 'fr').format(value);

String formatDay(DateTime date) => DateFormat('d MMM y', 'fr').format(date);

String formatLongDay(DateTime date) => DateFormat('EEEE d MMMM y', 'fr').format(date);

// ---------------------------------------------------------------------
// Saisie
// ---------------------------------------------------------------------

/// `1:23:45`, `45:10` ou `45` (minutes). Null si illisible.
int? parseDuration(String input) {
  final parts = input.trim().split(':');
  if (parts.isEmpty || parts.length > 3 || parts.any((p) => int.tryParse(p) == null)) return null;
  final values = parts.map(int.parse).toList();
  if (values.skip(1).any((v) => v >= 60)) return null;
  return switch (values.length) {
    1 => values[0] * 60,
    2 => values[0] * 60 + values[1],
    _ => values[0] * 3600 + values[1] * 60 + values[2],
  };
}

/// Nombre décimal saisi avec virgule ou point. Null si vide ou illisible.
double? parseDecimal(String input) {
  final cleaned = input.trim().replaceAll(' ', '').replaceAll(',', '.');
  return cleaned.isEmpty ? null : double.tryParse(cleaned);
}

/// Montant en euros saisi -> centimes. Vide = 0.
int? parseEurosToCents(String input) {
  if (input.trim().isEmpty) return 0;
  final value = parseDecimal(input);
  return value == null ? null : (value * 100).round();
}

/// Valeur de champ pour un montant en centimes (vide si 0).
String centsToInput(int cents) => cents == 0 ? '' : NumberFormat('0.##', 'fr').format(cents / 100);

/// Valeur de champ pour une distance en mètres.
String metersToKmInput(int meters) => meters == 0 ? '' : NumberFormat('0.###', 'fr').format(meters / 1000);

const _monthShort = ['JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUIN', 'JUIL', 'AOÛT', 'SEP', 'OCT', 'NOV', 'DÉC'];

/// Mois abrégé pour les axes : « JAN », « FÉV », « JUIN », « JUIL »…
String formatMonthShort(DateTime d) => _monthShort[d.month - 1];

/// Mois en toutes lettres : « Avril 2026 ».
String formatMonthYear(DateTime d) => toBeginningOfSentenceCase(DateFormat('MMMM y', 'fr').format(d));
