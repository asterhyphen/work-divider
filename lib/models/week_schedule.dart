/// Weekly schedule model.
class WeekSchedule {
  final int weekNumber;
  final String leader;
  final Map<String, String> assignments; // task -> person

  WeekSchedule({
    required this.weekNumber,
    required this.leader,
    required this.assignments,
  });
}
