// All hardcoded schedule data for HouseCycle.
// Leader is ALWAYS the person assigned to Outside 2.
// Main Bathroom rotates ONLY: Amaan, Ahmed, Shaaz, Ayanuddin
// Other Bathroom rotates ONLY: Wasiq, Asfan, Ayaan

class ScheduleData {
  static const List<String> allUsers = [
    'Asfan',
    'Ahmed',
    'Ayanuddin',
    'Ayaan',
    'Amaan',
    'Shaaz',
    'Wasiq',
  ];

  static const List<String> taskNames = [
    'Main Bathroom',
    'Other Bathroom',
    'Big Hall',
    'Side Hall',
    'Kitchen',
    'Outside 1',
    'Outside 2',
  ];

  static const Map<String, String> completionMessages = {
    'Main Bathroom': 'Bathroom survived another war.',
    'Other Bathroom': 'Fresh and clean. Victory!',
    'Big Hall': 'Hall shining like moonlight.',
    'Side Hall': 'Side hall? More like SHINE hall.',
    'Kitchen': 'Kitchen conquered.',
    'Outside 1': 'The great outdoors cleaned.',
    'Outside 2': 'Leading AND cleaning. Respect.',
  };

  /// Each week: leader + 6 task assignments.
  /// The leader is automatically assigned Outside 2.
  static const List<Map<String, String>> weeklySchedules = [
    // Week 1
    {
      'leader': 'Ayaan',
      'Main Bathroom': 'Amaan',
      'Other Bathroom': 'Wasiq',
      'Big Hall': 'Ahmed',
      'Side Hall': 'Shaaz',
      'Kitchen': 'Ayanuddin',
      'Outside 1': 'Asfan',
    },
    // Week 2
    {
      'leader': 'Wasiq',
      'Main Bathroom': 'Ahmed',
      'Other Bathroom': 'Asfan',
      'Big Hall': 'Shaaz',
      'Side Hall': 'Ayanuddin',
      'Kitchen': 'Amaan',
      'Outside 1': 'Ayaan',
    },
    // Week 3
    {
      'leader': 'Asfan',
      'Main Bathroom': 'Shaaz',
      'Other Bathroom': 'Ayaan',
      'Big Hall': 'Ayanuddin',
      'Side Hall': 'Amaan',
      'Kitchen': 'Ahmed',
      'Outside 1': 'Wasiq',
    },
    // Week 4
    {
      'leader': 'Ayanuddin',
      'Main Bathroom': 'Ayanuddin',
      'Other Bathroom': 'Wasiq',
      'Big Hall': 'Amaan',
      'Side Hall': 'Ahmed',
      'Kitchen': 'Shaaz',
      'Outside 1': 'Asfan',
    },
    // Week 5
    {
      'leader': 'Ahmed',
      'Main Bathroom': 'Amaan',
      'Other Bathroom': 'Asfan',
      'Big Hall': 'Ahmed',
      'Side Hall': 'Shaaz',
      'Kitchen': 'Ayanuddin',
      'Outside 1': 'Ayaan',
    },
    // Week 6
    {
      'leader': 'Shaaz',
      'Main Bathroom': 'Ahmed',
      'Other Bathroom': 'Ayaan',
      'Big Hall': 'Shaaz',
      'Side Hall': 'Ayanuddin',
      'Kitchen': 'Amaan',
      'Outside 1': 'Wasiq',
    },
    // Week 7
    {
      'leader': 'Amaan',
      'Main Bathroom': 'Shaaz',
      'Other Bathroom': 'Wasiq',
      'Big Hall': 'Ayanuddin',
      'Side Hall': 'Amaan',
      'Kitchen': 'Ahmed',
      'Outside 1': 'Asfan',
    },
  ];

  /// Get current week number (1-7) based on rotating schedule.
  /// Uses a reference Monday and cycles every 7 weeks.
  static int getCurrentWeekNumber() {
    final reference = DateTime(2026, 5, 4); // Monday, May 4, 2026
    final now = DateTime.now();
    final daysDiff = now.difference(reference).inDays;
    final weekIndex = (daysDiff ~/ 7) % 7;
    return weekIndex + 1; // 1-based
  }

  /// Get the schedule for a given week (1-7).
  static Map<String, String> getWeekSchedule(int weekNumber) {
    return weeklySchedules[weekNumber - 1];
  }

  /// Get the leader for a given week.
  static String getLeader(int weekNumber) {
    return weeklySchedules[weekNumber - 1]['leader']!;
  }

  /// Get all tasks assigned to a user for a given week.
  static List<String> getUserTasks(String userName, int weekNumber) {
    final schedule = weeklySchedules[weekNumber - 1];
    final tasks = <String>[];

    for (final taskName in taskNames) {
      if (taskName == 'Outside 2') {
        if (schedule['leader'] == userName) {
          tasks.add('Outside 2');
        }
      } else {
        if (schedule[taskName] == userName) {
          tasks.add(taskName);
        }
      }
    }
    return tasks;
  }

  /// Check if a user is the leader for a given week.
  static bool isLeader(String userName, int weekNumber) {
    return weeklySchedules[weekNumber - 1]['leader'] == userName;
  }

  /// Get all assignments for a week as task->person map (including Outside 2).
  static Map<String, String> getFullAssignments(int weekNumber) {
    final schedule = Map<String, String>.from(weeklySchedules[weekNumber - 1]);
    schedule['Outside 2'] = schedule['leader']!;
    schedule.remove('leader');
    return schedule;
  }

  /// Get deadline info based on current day.
  static String getDeadlineStatus() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon, 7=Sun
    final hour = now.hour;

    if (weekday < 5) return 'Due Sunday Evening';
    if (weekday == 5 && hour < 18) return 'Due Sunday Evening';
    if (weekday == 5) return 'Weekend started - get it done!';
    if (weekday == 6 && hour < 14) return 'Saturday - time to clean!';
    if (weekday == 6) return 'Saturday afternoon - hurry up!';
    if (weekday == 7 && hour < 9) return 'Sunday morning - last chance!';
    if (weekday == 7 && hour < 18) return 'Sunday - deadline approaching!';
    if (weekday == 7 && hour < 22) return 'FINAL HOURS!';
    return 'OVERDUE';
  }

  /// Check if the task is overdue (past Sunday 10 PM).
  static bool isOverdue() {
    final now = DateTime.now();
    return now.weekday == DateTime.sunday && now.hour >= 22;
  }

  /// Get a reminder level (0 = no reminder, 1-4 = escalating urgency).
  static int getReminderLevel() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final hour = now.hour;

    if (weekday == 5 && hour >= 18) return 1; // Friday evening
    if (weekday == 6 && hour >= 14) return 2; // Saturday afternoon
    if (weekday == 7 && hour >= 9 && hour < 18) return 3; // Sunday morning
    if (weekday == 7 && hour >= 18) return 4; // Sunday evening
    return 0;
  }
}
