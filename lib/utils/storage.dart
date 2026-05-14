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
    int week,
    String user,
    String task,
    String status,
  ) {
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

  static bool getHasPendingSync() {
    return prefs.getBool('has_pending_sync') ?? false;
  }

  static Future<void> setHasPendingSync(bool value) {
    return prefs.setBool('has_pending_sync', value);
  }

  static Map<String, Object?> getSharedState() {
    final state = <String, Object?>{};
    for (final key in prefs.getKeys()) {
      if (_isSharedKey(key)) {
        state[key] = prefs.get(key);
      }
    }
    return state;
  }

  static Future<bool> applySharedState(Map<String, Object?> state) async {
    var changed = false;

    for (final entry in state.entries) {
      if (!_isSharedKey(entry.key)) continue;

      final current = prefs.get(entry.key);
      final value = entry.value;
      if (current == value) continue;

      changed = true;
      if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is String) {
        await prefs.setString(entry.key, value);
      } else if (value is List) {
        await prefs.setStringList(
          entry.key,
          value.map((item) => item.toString()).toList(),
        );
      }
    }

    return changed;
  }

  static bool _isSharedKey(String key) {
    return key.startsWith('task_') ||
        key.startsWith('streak_') ||
        key == 'last_processed_week';
  }
}
