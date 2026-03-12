class Goal {
  final String id;
  final String title;
  final String categoryType; // project | habit | path | work
  final String categoryItem;
  final String description;
  final int sessionsDone;
  final int sessionsTotal;
  final int? scheduledMinutes; // minutes from midnight

  const Goal({
    required this.id,
    required this.title,
    required this.categoryType,
    required this.categoryItem,
    this.description = '',
    this.sessionsDone = 0,
    this.sessionsTotal = 4,
    this.scheduledMinutes,
  });

  Goal copyWith({
    String? title,
    String? categoryType,
    String? categoryItem,
    String? description,
    int? sessionsDone,
    int? sessionsTotal,
    int? scheduledMinutes,
    bool clearScheduledMinutes = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      categoryType: categoryType ?? this.categoryType,
      categoryItem: categoryItem ?? this.categoryItem,
      description: description ?? this.description,
      sessionsDone: sessionsDone ?? this.sessionsDone,
      sessionsTotal: sessionsTotal ?? this.sessionsTotal,
      scheduledMinutes:
          clearScheduledMinutes ? null : (scheduledMinutes ?? this.scheduledMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryType': categoryType,
        'categoryItem': categoryItem,
        'description': description,
        'sessionsDone': sessionsDone,
        'sessionsTotal': sessionsTotal,
        'scheduledMinutes': scheduledMinutes,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        categoryType: json['categoryType'] as String,
        categoryItem: json['categoryItem'] as String,
        description: json['description'] as String? ?? '',
        sessionsDone: json['sessionsDone'] as int? ?? 0,
        sessionsTotal: json['sessionsTotal'] as int? ?? 4,
        scheduledMinutes: (json['scheduledMinutes'] as num?)?.toInt(),
      );
}
