import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/evolution/domain/evolution_range.dart';
import 'package:flutter_test/flutter_test.dart';

final today = calendarDate(2026, 10, 8);

Course done(String id, DateTime date, {int distanceM = 10000}) =>
    Course(id: id, title: id, raceDate: date, distanceM: distanceM, durationS: 3000);

void main() {
  final courses = [
    done('a', calendarDate(2024, 6, 1)),
    done('b', calendarDate(2025, 3, 1), distanceM: 5000),
    done('c', calendarDate(2025, 11, 20)),
    done('d', calendarDate(2026, 1, 15), distanceM: 21100),
    done('e', calendarDate(2026, 10, 4)),
  ];

  test('12 derniers mois : du mois en cours − 11 au mois en cours', () {
    const range = EvolutionRange(RangeKind.last12Months, year: 2026);
    final totals = range.totals(courses, today);
    expect(totals, hasLength(12));
    expect((totals.first.start.year, totals.first.start.month), (2025, 11));
    expect((totals.last.start.year, totals.last.start.month), (2026, 10));
    expect(range.coursesIn(courses, today).map((c) => c.id), ['c', 'd', 'e']);
    final previous = range.previousWindow(today)!;
    expect(previous.$1, DateTime.utc(2024, 11));
    expect(previous.$2, DateTime.utc(2025, 11));
    expect(previous.$3, CompareKind.previous12Months);
  });

  test('par mois : janvier à décembre de l\'année choisie', () {
    const range = EvolutionRange(RangeKind.year, year: 2025);
    final totals = range.totals(courses, today);
    expect(totals.map((t) => t.start.month), [for (var m = 1; m <= 12; m++) m]);
    expect(totals[2].distanceM, 5000);
    expect(range.previousWindow(today)!.$3, CompareKind.previousYear);
  });

  test('année en cours : comparée à l\'année précédente à la même date', () {
    const range = EvolutionRange(RangeKind.year, year: 2026);
    final (from, to, kind) = range.previousWindow(today)!;
    expect(from, DateTime.utc(2025));
    expect(to, DateTime.utc(2025, 10, 9));
    expect(kind, CompareKind.previousYearToDate);
  });

  test('par année : jusqu\'à l\'année en cours, sans comparaison', () {
    const range = EvolutionRange(RangeKind.allYears, year: 2026);
    expect(range.totals(courses, today).map((t) => t.start.year), [2024, 2025, 2026]);
    expect(range.previousWindow(today), isNull);
    expect(range.coursesIn(courses, today), hasLength(5));
    expect(range.totals([done('x', calendarDate(2023, 1, 1))], today).map((t) => t.start.year), [
      2023,
      2024,
      2025,
      2026,
    ]);
  });

  test('années proposées et variations', () {
    expect(EvolutionRange.availableYears(courses, today), [2024, 2025, 2026]);
    expect(EvolutionRange.availableYears(const [], today), [2026]);
    expect(percentChange(120, 100), 20);
    expect(percentChange(50, 100), -50);
    expect(percentChange(10, 0), isNull);
  });
}
