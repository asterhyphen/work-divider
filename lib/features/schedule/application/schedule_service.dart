import 'package:meowdabattery/features/schedule/data/schedule_data.dart';
import 'package:meowdabattery/features/schedule/domain/week_rotation.dart';

class ScheduleService {
  final WeekRotation weekRotation;

  const ScheduleService({required this.weekRotation});

  static final ScheduleService instance = ScheduleService(
    weekRotation: WeekRotation(
      anchorWeek: ScheduleData.anchorWeek,
      anchorMonday: ScheduleData.anchorMonday,
      weekCount: ScheduleData.weeklySchedules.length,
    ),
  );

  List<String> get allUsers => ScheduleData.allUsers;
  String get adminUser => ScheduleData.adminUser;
  Map<String, String> get completionMessages => ScheduleData.completionMessages;

  int currentWeekNumber({DateTime? now}) => weekRotation.currentWeek(now: now);

  Map<String, String> getWeekSchedule(int weekNumber) {
    return ScheduleData.weeklySchedules[weekNumber - 1];
  }

  String getLeader(int weekNumber) {
    return getWeekSchedule(weekNumber)['leader']!;
  }

  List<String> getUserTasks(String userName, int weekNumber) {
    final schedule = getWeekSchedule(weekNumber);
    final tasks = <String>[];

    for (final taskName in ScheduleData.taskNames) {
      if (taskName == 'Outside 2') {
        if (schedule['leader'] == userName) {
          tasks.add('Outside 2');
        }
      } else if (schedule[taskName] == userName) {
        tasks.add(taskName);
      }
    }
    return tasks;
  }

  bool isLeader(String userName, int weekNumber) {
    return userName == adminUser;
  }

  bool isPasswordValid(String userName, String password) {
    return ScheduleData.passwords[userName] == password.trim();
  }

  Map<String, String> getFullAssignments(int weekNumber) {
    final schedule = Map<String, String>.from(getWeekSchedule(weekNumber));
    schedule['Outside 2'] = schedule['leader']!;
    schedule.remove('leader');
    return schedule;
  }

  String getDeadlineStatus({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final weekday = currentTime.weekday;
    final hour = currentTime.hour;

    if (weekday < DateTime.friday) return 'Due Sunday Evening';
    if (weekday == DateTime.friday && hour < 18) return 'Due Sunday Evening';
    if (weekday == DateTime.friday) return 'Weekend started - get it done!';
    if (weekday == DateTime.saturday && hour < 14) {
      return 'Saturday - time to clean!';
    }
    if (weekday == DateTime.saturday) return 'Saturday afternoon - hurry up!';
    if (weekday == DateTime.sunday && hour < 9) {
      return 'Sunday morning - last chance!';
    }
    if (weekday == DateTime.sunday && hour < 18) {
      return 'Sunday - deadline approaching!';
    }
    if (weekday == DateTime.sunday && hour < 22) return 'FINAL HOURS!';
    return 'OVERDUE';
  }

  bool isOverdue({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return currentTime.weekday == DateTime.sunday && currentTime.hour >= 22;
  }

  int getReminderLevel({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final weekday = currentTime.weekday;
    final hour = currentTime.hour;

    if (weekday == DateTime.friday && hour >= 18) return 1;
    if (weekday == DateTime.saturday && hour >= 14) return 2;
    if (weekday == DateTime.sunday && hour >= 9 && hour < 18) return 3;
    if (weekday == DateTime.sunday && hour >= 18) return 4;
    return 0;
  }
}
