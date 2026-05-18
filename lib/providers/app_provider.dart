import 'package:flutter/material.dart';
import 'package:meowdabattery/features/schedule/application/schedule_service.dart';
import 'package:meowdabattery/models/task_status.dart';
import 'package:meowdabattery/utils/remote_sync.dart';
import 'package:meowdabattery/utils/storage.dart';

/// Central state management for HouseCycle.
class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  String? _currentUser;
  int _currentWeek = 1;
  final RemoteSync _remoteSync = RemoteSync();
  final ScheduleService _scheduleService;

  AppProvider({ScheduleService? scheduleService})
    : _scheduleService = scheduleService ?? ScheduleService.instance;

  String? get currentUser => _currentUser;
  int get currentWeek => _currentWeek;
  int get currentWeekNumber => _currentWeek;
  List<String> get allUsers => _scheduleService.allUsers;

  bool get isLeader =>
      _currentUser != null &&
      _scheduleService.isLeader(_currentUser!, _currentWeek);

  String get leaderName => _scheduleService.getLeader(_currentWeek);
  String get adminName => _scheduleService.adminUser;

  /// Initialize from storage.
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _currentUser = Storage.getCurrentUser();
    _currentWeek = _scheduleService.currentWeekNumber();
    await syncNow();
    _remoteSync.startPolling(syncNow);
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
    return _scheduleService.getUserTasks(_currentUser!, _currentWeek);
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
    await _pushLocalChanges();
    notifyListeners();
  }

  /// Leader approves a task.
  Future<void> approveTask(String user, String task) async {
    await Storage.setTaskStatus(_currentWeek, user, task, 'approved');

    // Update streak
    final tasks = _scheduleService.getUserTasks(user, _currentWeek);
    final allApproved = tasks.every(
      (t) => getTaskStatus(user, t) == TaskStatus.approved,
    );
    if (allApproved) {
      final currentStreak = Storage.getStreak(user);
      await Storage.setStreak(user, currentStreak + 1);
    }

    await _pushLocalChanges();
    notifyListeners();
  }

  /// Leader rejects a task.
  Future<void> rejectTask(String user, String task) async {
    await Storage.setTaskStatus(_currentWeek, user, task, 'rejected');
    await _pushLocalChanges();
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
    await _pushLocalChanges();
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
    await _pushLocalChanges();
    notifyListeners();
  }

  /// Admin clears all task statuses for the active week.
  Future<void> resetWeekTasks() async {
    for (final entry in fullAssignments.entries) {
      await Storage.setTaskStatus(_currentWeek, entry.value, entry.key, 'none');
    }
    await _pushLocalChanges();
    notifyListeners();
  }

  /// Local-first sync: push unsent local edits, then pull latest shared state.
  Future<void> syncNow() async {
    if (!_remoteSync.isEnabled) return;

    if (Storage.getHasPendingSync()) {
      final pushed = await _remoteSync.push();
      if (!pushed) {
        notifyListeners();
        return;
      }
      await Storage.setHasPendingSync(false);
    }

    final changed = await _remoteSync.pull();
    if (changed) notifyListeners();
  }

  Future<void> _pushLocalChanges() async {
    await Storage.setHasPendingSync(true);
    final pushed = await _remoteSync.push();
    if (pushed) {
      await Storage.setHasPendingSync(false);
    }
  }

  /// Get full assignments for the current week.
  Map<String, String> get fullAssignments =>
      _scheduleService.getFullAssignments(_currentWeek);

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

  bool isPasswordValid(String userName, String password) {
    return _scheduleService.isPasswordValid(userName, password);
  }

  String completionMessageFor(String taskName) {
    return _scheduleService.completionMessages[taskName] ?? 'Task completed!';
  }

  /// Whether it's overdue.
  bool get isOverdue => _scheduleService.isOverdue();

  /// Get reminder level.
  int get reminderLevel => _scheduleService.getReminderLevel();

  /// Deadline status string.
  String get deadlineStatus => _scheduleService.getDeadlineStatus();

  /// Refresh week number (in case day changed while app is open).
  void refreshWeek() {
    final currentWeek = _scheduleService.currentWeekNumber();
    if (_currentWeek == currentWeek) return;
    _currentWeek = currentWeek;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _remoteSync.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshWeek();
      syncNow();
    }
  }
}
