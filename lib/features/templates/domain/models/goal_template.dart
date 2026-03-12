import 'dart:convert';

import '../../../goals/domain/models/goal.dart';

class GoalTemplate {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Goal> goals;

  const GoalTemplate({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.goals,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'goals': goals.map((g) => g.toJson()).toList(),
      };

  factory GoalTemplate.fromJson(Map<String, dynamic> json) => GoalTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        goals: (json['goals'] as List<dynamic>)
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static String encodeList(List<GoalTemplate> templates) =>
      jsonEncode(templates.map((t) => t.toJson()).toList());

  static List<GoalTemplate> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => GoalTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
