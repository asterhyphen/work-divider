import 'package:flutter_test/flutter_test.dart';
import 'package:meowdabattery/features/schedule/domain/week_rotation.dart';

void main() {
  group('WeekRotation.currentWeek', () {
    final rotation = WeekRotation(
      anchorWeek: 2,
      anchorMonday: DateTime(2026, 5, 18),
      weekCount: 7,
    );

    test('uses Week 2 for the Monday anchor date', () {
      expect(rotation.currentWeek(now: DateTime(2026, 5, 18)), 2);
    });

    test('keeps the same week through Sunday', () {
      expect(rotation.currentWeek(now: DateTime(2026, 5, 24, 23, 59)), 2);
    });

    test('switches to the next week on Monday', () {
      expect(rotation.currentWeek(now: DateTime(2026, 5, 25)), 3);
    });

    test('wraps from Week 7 back to Week 1', () {
      expect(rotation.currentWeek(now: DateTime(2026, 6, 22)), 7);
      expect(rotation.currentWeek(now: DateTime(2026, 6, 29)), 1);
    });
  });
}
