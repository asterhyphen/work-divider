import 'package:shared_preferences/shared_preferences.dart';

/// Simple storage wrapper around SharedPreferences.
class Storage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('Storage not initialized');
    return _prefs!;
  }

  // Current user
  static String? getCurrentUser() => prefs.getString('current_user');
  static Future<void> setCurrentUser(String user) =>
      prefs.setString('current_user', user);
  static Future<void> clearCurrentUser() => prefs.remove('current_user');

  // Task status: 'none', 'pending_approval', 'approved', 'rejected'
  static String getTaskStatus(int week, String user, String task) {
    return prefs.getString('task_${week}_${user}_$task') ?? 'none';
  }

  static Future<void> setTaskStatus(
      int week, String user, String task, String status) {
    return prefs.setString('task_${week}_${user}_$task', status);
  }

  // Streak counter
  static int getStreak(String user) {
    return prefs.getInt('streak_$user') ?? 0;
  }

  static Future<void> setStreak(String user, int value) {
    return prefs.setInt('streak_$user', value);
  }

  // Track which week we last processed (for streak logic)
  static int getLastProcessedWeek() {
    return prefs.getInt('last_processed_week') ?? 0;
  }

  static Future<void> setLastProcessedWeek(int week) {
    return prefs.setInt('last_processed_week', week);
  }
}
