import 'library_item.dart';

class Habit implements LibraryItem {
  @override
  final String id;
  @override
  final String title;

  const Habit({required this.id, required this.title});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        title: json['title'] as String,
      );
}
