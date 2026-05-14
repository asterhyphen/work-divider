import 'package:flutter/material.dart';
import 'package:meowdabattery/data/schedule_data.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/utils/remote_sync.dart';
import 'package:meowdabattery/utils/storage.dart';

/// Central state management for HouseCycle.
class AppProvider extends ChangeNotifier {
  String? _currentUser;
  int _currentWeek = 1;
  final RemoteSync _remoteSync = RemoteSync();

  String? get currentUser => _currentUser;
  int get currentWeek => ScheduleData.activeWeek;
  int get currentWeekNumber => ScheduleData.activeWeek;

  bool get isLeader =>
      _currentUser != null &&
      ScheduleData.isLeader(_currentUser!, _currentWeek);

  String get leaderName => ScheduleData.getLeader(_currentWeek);
  String get adminName => ScheduleData.adminUser;

  /// Initialize from storage.
  Future<void> init() async {
    _currentUser = null;
    await Storage.clearCurrentUser();
    _currentWeek = ScheduleData.activeWeek;
    await _remoteSync.pull();
    _remoteSync.startPolling(notifyListeners);
    notifyListeners();
  }

  /// Select a user (from "Who are you?" screen).
  Future<void> selectUser(String userName) async {
    _currentUser = userName;
    await Storage.setCurrentUser(userName);
    notifyListeners();
  }

  /// Log out / switch user.
  Future<void> logout() async {
    _currentUser = null;
    await Storage.clearCurrentUser();
    notifyListeners();
  }

  /// Get all tasks assigned to the current user this week.
  List<String> get myTasks {
    if (_currentUser == null) return [];
    return ScheduleData.getUserTasks(_currentUser!, _currentWeek);
  }

  /// Get task status for a specific user and task.
  TaskStatus getTaskStatus(String user, String task) {
    final raw = Storage.getTaskStatus(_currentWeek, user, task);
    return switch (raw) {
      'pending_approval' => TaskStatus.pendingApproval,
      'approved' => TaskStatus.approved,
      'rejected' => TaskStatus.rejected,
      _ => TaskStatus.none,
    };
  }

  /// User submits their task for approval.
  Future<void> submitTaskForApproval(String task) async {
    if (_currentUser == null) return;
    await Storage.setTaskStatus(
      _currentWeek,
      _currentUser!,
      task,
      'pending_approval',
    );
    await _remoteSync.push();
    notifyListeners();
  }

  /// Leader approves a task.
  Future<void> approveTask(String user, String task) async {
    await Storage.setTaskStatus(_currentWeek, user, task, 'approved');

    // Update streak
    final tasks = ScheduleData.getUserTasks(user, _currentWeek);
    final allApproved = tasks.every(
      (t) => getTaskStatus(user, t) == TaskStatus.approved,
    );
    if (allApproved) {
      final currentStreak = Storage.getStreak(user);
      await Storage.setStreak(user, currentStreak + 1);
    }

    await _remoteSync.push();
    notifyListeners();
  }

  /// Leader rejects a task.
  Future<void> rejectTask(String user, String task) async {
    await Storage.setTaskStatus(_currentWeek, user, task, 'rejected');
    await _remoteSync.push();
    notifyListeners();
  }

  /// Admin approves every task currently waiting for review.
  Future<void> approveAllPending() async {
    final pending = List<Map<String, String>>.from(pendingApprovals);
    for (final approval in pending) {
      await Storage.setTaskStatus(
        _currentWeek,
        approval['user']!,
        approval['task']!,
        'approved',
      );
    }
    await _remoteSync.push();
    notifyListeners();
  }

  /// Admin rejects every task currently waiting for review.
  Future<void> rejectAllPending() async {
    final pending = List<Map<String, String>>.from(pendingApprovals);
    for (final approval in pending) {
      await Storage.setTaskStatus(
        _currentWeek,
        approval['user']!,
        approval['task']!,
        'rejected',
      );
    }
    await _remoteSync.push();
    notifyListeners();
  }

  /// Admin clears all task statuses for the active week.
  Future<void> resetWeekTasks() async {
    for (final entry in fullAssignments.entries) {
      await Storage.setTaskStatus(_currentWeek, entry.value, entry.key, 'none');
    }
    await _remoteSync.push();
    notifyListeners();
  }

  /// Get full assignments for the current week.
  Map<String, String> get fullAssignments =>
      ScheduleData.getFullAssignments(_currentWeek);

  /// Get all pending approvals for the leader.
  List<Map<String, String>> get pendingApprovals {
    final approvals = <Map<String, String>>[];
    final assignments = fullAssignments;

    for (final entry in assignments.entries) {
      final task = entry.key;
      final user = entry.value;
      if (getTaskStatus(user, task) == TaskStatus.pendingApproval) {
        approvals.add({'user': user, 'task': task});
      }
    }
    return approvals;
  }

  /// Calculate completion percentage for the week.
  double get weekCompletionPercent {
    final assignments = fullAssignments;
    if (assignments.isEmpty) return 0.0;
    int approved = 0;
    for (final entry in assignments.entries) {
      if (getTaskStatus(entry.value, entry.key) == TaskStatus.approved) {
        approved++;
      }
    }
    return approved / assignments.length;
  }

  /// Check if ALL tasks are complete this week.
  bool get allTasksComplete => weekCompletionPercent >= 1.0;

  /// Get streak for a user.
  int getStreak(String user) => Storage.getStreak(user);

  /// Whether it's overdue.
  bool get isOverdue => ScheduleData.isOverdue();

  /// Get reminder level.
  int get reminderLevel => ScheduleData.getReminderLevel();

  /// Deadline status string.
  String get deadlineStatus => ScheduleData.getDeadlineStatus();

  /// Refresh week number (in case day changed while app is open).
  void refreshWeek() {
    _currentWeek = ScheduleData.activeWeek;
    notifyListeners();
  }

  @override
  void dispose() {
    _remoteSync.dispose();
    super.dispose();
  }
}
