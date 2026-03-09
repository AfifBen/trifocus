class Goal {
  final String id;
  final String title;
  final String categoryType; // project | habit | path | work
  final String categoryItem;
  final String description;
  final int sessionsDone;
  final int sessionsTotal;

  const Goal({
    required this.id,
    required this.title,
    required this.categoryType,
    required this.categoryItem,
    this.description = '',
    this.sessionsDone = 0,
    this.sessionsTotal = 4,
  });

  Goal copyWith({
    String? title,
    String? categoryType,
    String? categoryItem,
    String? description,
    int? sessionsDone,
    int? sessionsTotal,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      categoryType: categoryType ?? this.categoryType,
      categoryItem: categoryItem ?? this.categoryItem,
      description: description ?? this.description,
      sessionsDone: sessionsDone ?? this.sessionsDone,
      sessionsTotal: sessionsTotal ?? this.sessionsTotal,
    );
  }
}
