import 'package:flutter_test/flutter_test.dart';
import 'package:meowdabattery/data/schedule_data.dart';

void main() {
  group('ScheduleData.getCurrentWeekNumber', () {
    test('uses Week 2 for the Monday anchor date', () {
      expect(ScheduleData.getCurrentWeekNumber(now: DateTime(2026, 5, 18)), 2);
    });

    test('keeps the same week through Sunday', () {
      expect(
        ScheduleData.getCurrentWeekNumber(now: DateTime(2026, 5, 24, 23, 59)),
        2,
      );
    });

    test('switches to the next week on Monday', () {
      expect(ScheduleData.getCurrentWeekNumber(now: DateTime(2026, 5, 25)), 3);
    });

    test('wraps from Week 7 back to Week 1', () {
      expect(ScheduleData.getCurrentWeekNumber(now: DateTime(2026, 6, 22)), 7);
      expect(ScheduleData.getCurrentWeekNumber(now: DateTime(2026, 6, 29)), 1);
    });
  });
}
