import 'package:intl/intl.dart';

import '../features/courses/domain/multisport.dart';

/// Formats d'affichage communs (français, chiffres lisibles).

/// Langue des nombres et des dates affichés : celle de l'app (« fr » ou « en »).
/// Réglée par l'app au démarrage et à chaque changement de langue.
String formatLocale = 'fr';

/// Distance sans zéros superflus : « 42,2 km », « 10 km », « 21,18 km ».
String formatKm(int meters, {int decimals = 2}) =>
    '${NumberFormat(decimals == 0 ? '#,##0' : '#,##0.${'#' * decimals}', formatLocale).format(meters / 1000)} km';

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

/// Allure de natation : « 2'05" /100 m ».
String formatSwimPace(double? secondsPer100m) {
  if (secondsPer100m == null || secondsPer100m <= 0) return '--';
  final total = secondsPer100m.round();
  return '${total ~/ 60}\'${(total % 60).toString().padLeft(2, '0')}" /100 m';
}

/// Distance d'une discipline : en mètres pour la natation (« 750 m »), en kilomètres sinon.
String formatLegDistance(Leg leg) => leg.sport == Sport.swim ? formatMeters(leg.distanceM) : formatKm(leg.distanceM);

/// Rythme d'une discipline dans son unité habituelle : /100 m en natation, km/h à vélo, /km à pied.
String formatLegPace(Leg leg) => switch (leg.sport) {
  Sport.swim => formatSwimPace(leg.secondsPer100m),
  Sport.bike => formatSpeed(leg.speedKmh),
  Sport.run => formatPace(leg.secondsPerKm),
};

String formatSpeed(double? kmh) => kmh == null ? '--' : '${NumberFormat('0.0', formatLocale).format(kmh)} km/h';

String formatMeters(int meters) => '${NumberFormat('#,##0', formatLocale).format(meters)} m';

String formatEuros(int cents) => NumberFormat.currency(
  locale: formatLocale,
  symbol: '€',
  decimalDigits: cents % 100 == 0 ? 0 : 2,
).format(cents / 100);

/// Montant sans le symbole, pour les chiffres héros où « € » est affiché à part : « 1 240 ».
String formatEurosAmount(int cents) => formatEuros(cents).replaceAll(RegExp(r'\s?€'), '');

/// Quantité déclarée : entière si possible.
String formatQuantity(double value) => value == value.roundToDouble()
    ? NumberFormat('#,##0', formatLocale).format(value)
    : NumberFormat('#,##0.#', formatLocale).format(value);

String formatDay(DateTime date) => DateFormat('d MMM y', formatLocale).format(date);

String formatLongDay(DateTime date) => DateFormat('EEEE d MMMM y', formatLocale).format(date);

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
String centsToInput(int cents) => cents == 0 ? '' : NumberFormat('0.##', formatLocale).format(cents / 100);

/// Valeur de champ pour une distance en mètres.
String metersToKmInput(int meters) => meters == 0 ? '' : NumberFormat('0.###', formatLocale).format(meters / 1000);

const _monthShort = ['JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUIN', 'JUIL', 'AOÛT', 'SEP', 'OCT', 'NOV', 'DÉC'];
const _monthShortEn = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

/// Mois abrégé pour les axes : « JAN », « FÉV », « JUIN », « JUIL »…
String formatMonthShort(DateTime d) => (formatLocale == 'en' ? _monthShortEn : _monthShort)[d.month - 1];

/// Mois en toutes lettres : « Avril 2026 ».
String formatMonthYear(DateTime d) => toBeginningOfSentenceCase(DateFormat('MMMM y', formatLocale).format(d));
