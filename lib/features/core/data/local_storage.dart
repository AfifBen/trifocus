import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../goals/domain/models/goal.dart';

class LocalStorage {
  static const _goalsKey = 'trifocus_goals';
  static const _statsKey = 'trifocus_stats';

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
}
