import 'package:app_course/features/courses/domain/course.dart';
import 'package:app_course/features/reminders/domain/race_reminders.dart';
import 'package:flutter_test/flutter_test.dart';

Course course(String id, DateTime date, {bool planned = true, DateTime? deletedAt}) => Course(
  id: id,
  title: 'Course $id',
  raceDate: date,
  distanceM: 10000,
  durationS: planned ? 0 : 3000,
  isPlanned: planned,
  deletedAt: deletedAt,
);

void main() {
  final now = DateTime(2026, 10, 8, 14, 30);

  test('un rappel par course à venir, le jour J à l\'heure choisie, les plus proches d\'abord', () {
    final reminders = raceReminders(
      [
        course('paris', calendarDate(2027, 4, 11)),
        course('lyon', calendarDate(2026, 10, 18)),
        course('fait', calendarDate(2026, 10, 20), planned: false),
        course('efface', calendarDate(2026, 10, 25), deletedAt: DateTime.utc(2026, 10, 1)),
      ],
      now: now,
      hour: 20,
      minute: 0,
    );
    expect(reminders.map((r) => r.courseId), ['lyon', 'paris']);
    expect(reminders.first.at, DateTime(2026, 10, 18, 20));
    expect(reminders.first.courseTitle, 'Course lyon');
  });

  test('le jour J : rappel encore à venir le matin, plus rien une fois l\'heure passée', () {
    final today = [course('jour-j', calendarDate(2026, 10, 8))];
    expect(raceReminders(today, now: now, hour: 20, minute: 0), hasLength(1));
    expect(raceReminders(today, now: DateTime(2026, 10, 8, 21), hour: 20, minute: 0), isEmpty);
    expect(raceReminders(today, now: now, hour: 9, minute: 0), isEmpty);
  });

  test('heure locale respectée, même le jour du changement d\'heure', () {
    // 25 octobre 2026 : passage à l'heure d'hiver en France.
    final r = raceReminders([course('hiver', calendarDate(2026, 10, 25))], now: now, hour: 19, minute: 30).single;
    expect((r.at.hour, r.at.minute), (19, 30));
    expect(r.at.isUtc, isFalse);
  });

  test('identifiant de notification stable et positif', () {
    expect(reminderId('abc'), reminderId('abc'));
    expect(reminderId('abc'), isNot(reminderId('abd')));
    expect(reminderId('550e8400-e29b-41d4-a716-446655440000'), greaterThanOrEqualTo(0));
  });

  test('pas plus de $kMaxReminders rappels à la fois', () {
    final many = [for (var i = 0; i < 80; i++) course('c$i', calendarDate(2026, 11, 1).add(Duration(days: i)))];
    expect(raceReminders(many, now: now, hour: 20, minute: 0), hasLength(kMaxReminders));
  });
}
