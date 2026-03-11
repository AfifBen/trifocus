import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../goals/domain/models/goal.dart';
import '../../library/domain/models/project.dart';
import '../../library/domain/models/habit.dart';
import '../../library/domain/models/path.dart';

class LocalStorage {
  static const _goalsKey = 'trifocus_goals';
  static const _statsKey = 'trifocus_stats';
  static const _projectsKey = 'trifocus_projects';
  static const _habitsKey = 'trifocus_habits';
  static const _pathsKey = 'trifocus_paths';
  static const _goalsDayKey = 'trifocus_goals_day';
  static const _focusDurationKey = 'trifocus_focus_duration';
  static const _breakDurationKey = 'trifocus_break_duration';

  static Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => Goal.fromJson(item)).toList();
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
}
