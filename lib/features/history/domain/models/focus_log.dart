class FocusLog {
  final String id;
  final String? goalId;
  final String? goalTitle;
  final int durationSeconds;
  final DateTime createdAt;

  const FocusLog({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.durationSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'goalTitle': goalTitle,
        'durationSeconds': durationSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FocusLog.fromJson(Map<String, dynamic> json) => FocusLog(
        id: json['id'] as String,
        goalId: json['goalId'] as String?,
        goalTitle: json['goalTitle'] as String?,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
