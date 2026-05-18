class WeekRotation {
  final int anchorWeek;
  final DateTime anchorMonday;
  final int weekCount;

  const WeekRotation({
    required this.anchorWeek,
    required this.anchorMonday,
    required this.weekCount,
  });

  int currentWeek({DateTime? now}) {
    final currentMonday = _mondayFor(now ?? DateTime.now());
    final weekOffset = currentMonday.difference(anchorMonday).inDays ~/ 7;
    final weekIndex = (anchorWeek - 1 + weekOffset) % weekCount;
    return weekIndex + 1;
  }

  DateTime _mondayFor(DateTime date) {
    final dayOnly = DateTime(date.year, date.month, date.day);
    return dayOnly.subtract(Duration(days: dayOnly.weekday - DateTime.monday));
  }
}
