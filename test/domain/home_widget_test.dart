import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/widget/home_screen_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  final today = calendarDate(2026, 10, 10);
  Course race(String id, DateTime date, int m, {bool planned = false, int time = 3000}) =>
      Course(id: id, title: 'Course $id', raceDate: date, distanceM: m, durationS: time, isPlanned: planned);

  test('prochaine course la plus proche, km des courses terminées de l\'année', () {
    final data = homeWidgetData([
      race('loin', calendarDate(2027, 4, 11), 42195, planned: true),
      race('proche', calendarDate(2026, 10, 22), 21097, planned: true),
      race('fait', calendarDate(2026, 3, 8), 1210500),
      race('avant', calendarDate(2025, 12, 31), 10000),
    ], today);
    expect(data.nextTitle, 'Course proche');
    expect(data.nextDate, calendarDate(2026, 10, 22));
    expect(data.yearKm, '1\u202f211');
    expect(data.toMap()['nextEpochDay'], calendarDate(2026, 10, 22).millisecondsSinceEpoch ~/ 86400000);
    expect(data.toMap()['year'], 2026);
  });

  test('sans course à venir', () {
    final data = homeWidgetData([race('fait', calendarDate(2026, 3, 8), 10000)], today);
    expect(data.nextTitle, isNull);
    expect(data.toMap()['nextEpochDay'], isNull);
    expect(data.yearKm, '10');
  });
}
