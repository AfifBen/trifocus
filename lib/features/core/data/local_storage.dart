import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../goals/domain/models/goal.dart';
import '../../library/domain/models/project.dart';
import '../../library/domain/models/habit.dart';
import '../../library/domain/models/path.dart';
import '../../history/domain/models/focus_log.dart';
import '../../templates/domain/models/goal_template.dart';

class LocalStorage {
  static const _goalsKey = 'trifocus_goals';
  static const _statsKey = 'trifocus_stats';
  static const _projectsKey = 'trifocus_projects';
  static const _habitsKey = 'trifocus_habits';
  static const _pathsKey = 'trifocus_paths';
  static const _goalsDayKey = 'trifocus_goals_day';
  static const _focusDurationKey = 'trifocus_focus_duration';
  static const _breakDurationKey = 'trifocus_break_duration';
  static const _reminderEnabledKey = 'trifocus_reminder_enabled';
  static const _logsKey = 'trifocus_focus_logs';
  static const _todayViewModeKey = 'trifocus_today_view_mode';
  static const _nextGoalReminderEnabledKey = 'trifocus_next_goal_reminder';
  static const _nextGoalReminderLeadMinKey = 'trifocus_next_goal_lead_min';
  static const _templatesKey = 'trifocus_goal_templates';
  static const _hideDoneGoalsKey = 'trifocus_hide_done_goals';
  static const _cloudUpdatedAtKey = 'trifocus_cloud_updated_at';
  static const _reminderHourKey = 'trifocus_reminder_hour';
  static const _reminderMinuteKey = 'trifocus_reminder_minute';

  static Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => Goal.fromJson(item)).toList();
  }

  static Future<String?> loadTodayViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_todayViewModeKey);
  }

  static Future<void> saveTodayViewMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todayViewModeKey, mode);
  }

  static Future<List<GoalTemplate>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_templatesKey);
    if (raw == null) return [];
    return GoalTemplate.decodeList(raw);
  }

  static Future<void> saveTemplates(List<GoalTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_templatesKey, GoalTemplate.encodeList(templates));
  }

  static Future<bool> loadHideDoneGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideDoneGoalsKey) ?? false;
  }

  static Future<void> saveHideDoneGoals(bool hide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideDoneGoalsKey, hide);
  }

  static Future<String?> loadCloudUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cloudUpdatedAtKey);
  }

  static Future<void> saveCloudUpdatedAt(String iso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cloudUpdatedAtKey, iso);
  }

  static Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(goals.map((g) => g.toJson()).toList());
    await prefs.setString(_goalsKey, payload);
  }

  static Future<String?> loadGoalsDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_goalsDayKey);
  }

  static Future<void> saveGoalsDay(String day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsDayKey, day);
  }

  static Future<int?> loadFocusDurationSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_focusDurationKey);
  }

  static Future<void> saveFocusDurationSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusDurationKey, seconds);
  }

  static Future<int?> loadBreakDurationSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_breakDurationKey);
  }

  static Future<void> saveBreakDurationSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_breakDurationKey, seconds);
  }

  static Future<bool> loadReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  static Future<void> saveReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
  }

  static Future<int?> loadReminderHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderHourKey);
  }

  static Future<int?> loadReminderMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderMinuteKey);
  }

  static Future<void> saveReminderTime({
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }

  static Future<bool> loadNextGoalReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_nextGoalReminderEnabledKey) ?? false;
  }

  static Future<void> saveNextGoalReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nextGoalReminderEnabledKey, enabled);
  }

  static Future<int> loadNextGoalReminderLeadMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_nextGoalReminderLeadMinKey) ?? 0;
  }

  static Future<void> saveNextGoalReminderLeadMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_nextGoalReminderLeadMinKey, minutes);
  }

  static Future<Map<String, dynamic>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveStats(Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats));
  }

  static Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_projectsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => Project.fromJson(item)).toList();
  }

  static Future<void> saveProjects(List<Project> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _projectsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_habitsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => Habit.fromJson(item)).toList();
  }

  static Future<void> saveHabits(List<Habit> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _habitsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<Path>> loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pathsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => Path.fromJson(item)).toList();
  }

  static Future<void> savePaths(List<Path> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pathsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<FocusLog>> loadFocusLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_logsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => FocusLog.fromJson(e)).toList();
  }

  static Future<void> saveFocusLogs(List<FocusLog> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _logsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalsKey);
    await prefs.remove(_statsKey);
    await prefs.remove(_projectsKey);
    await prefs.remove(_habitsKey);
    await prefs.remove(_pathsKey);
    await prefs.remove(_goalsDayKey);
    await prefs.remove(_focusDurationKey);
    await prefs.remove(_breakDurationKey);
    await prefs.remove(_reminderEnabledKey);
    await prefs.remove(_reminderHourKey);
    await prefs.remove(_reminderMinuteKey);
    await prefs.remove(_logsKey);
    await prefs.remove(_todayViewModeKey);
    await prefs.remove(_nextGoalReminderEnabledKey);
    await prefs.remove(_nextGoalReminderLeadMinKey);
    await prefs.remove(_templatesKey);
    await prefs.remove(_hideDoneGoalsKey);
    await prefs.remove(_cloudUpdatedAtKey);
  }

  static Future<Map<String, dynamic>> exportAll() async {
    final prefs = await SharedPreferences.getInstance();

    // We export already-serialized payloads for simplicity.
    return {
      'version': 1,
      'goals': prefs.getString(_goalsKey),
      'stats': prefs.getString(_statsKey),
      'projects': prefs.getString(_projectsKey),
      'habits': prefs.getString(_habitsKey),
      'paths': prefs.getString(_pathsKey),
      'goalsDay': prefs.getString(_goalsDayKey),
      'focusDuration': prefs.getInt(_focusDurationKey),
      'breakDuration': prefs.getInt(_breakDurationKey),
      'reminderEnabled': prefs.getBool(_reminderEnabledKey),
      'reminderHour': prefs.getInt(_reminderHourKey),
      'reminderMinute': prefs.getInt(_reminderMinuteKey),
      'focusLogs': prefs.getString(_logsKey),
      'todayViewMode': prefs.getString(_todayViewModeKey),
      'nextGoalReminderEnabled': prefs.getBool(_nextGoalReminderEnabledKey),
      'nextGoalReminderLeadMin': prefs.getInt(_nextGoalReminderLeadMinKey),
      'templates': prefs.getString(_templatesKey),
      'hideDoneGoals': prefs.getBool(_hideDoneGoalsKey),
      'cloudUpdatedAt': prefs.getString(_cloudUpdatedAtKey),
    };
  }

  static Future<void> importAll(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    Future<void> setString(String key, dynamic value) async {
      if (value == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, value as String);
      }
    }

    Future<void> setInt(String key, dynamic value) async {
      if (value == null) {
        await prefs.remove(key);
      } else {
        await prefs.setInt(key, (value as num).toInt());
      }
    }

    Future<void> setBool(String key, dynamic value) async {
      if (value == null) {
        await prefs.remove(key);
      } else {
        await prefs.setBool(key, value as bool);
      }
    }

    await setString(_goalsKey, data['goals']);
    await setString(_statsKey, data['stats']);
    await setString(_projectsKey, data['projects']);
    await setString(_habitsKey, data['habits']);
    await setString(_pathsKey, data['paths']);
    await setString(_goalsDayKey, data['goalsDay']);

    await setInt(_focusDurationKey, data['focusDuration']);
    await setInt(_breakDurationKey, data['breakDuration']);

    await setBool(_reminderEnabledKey, data['reminderEnabled']);
    await setInt(_reminderHourKey, data['reminderHour']);
    await setInt(_reminderMinuteKey, data['reminderMinute']);

    await setString(_logsKey, data['focusLogs']);
    await setString(_todayViewModeKey, data['todayViewMode']);
    await setBool(_nextGoalReminderEnabledKey, data['nextGoalReminderEnabled']);
    await setInt(_nextGoalReminderLeadMinKey, data['nextGoalReminderLeadMin']);
    await setString(_templatesKey, data['templates']);
    await setBool(_hideDoneGoalsKey, data['hideDoneGoals']);
    await setString(_cloudUpdatedAtKey, data['cloudUpdatedAt']);
  }
}
