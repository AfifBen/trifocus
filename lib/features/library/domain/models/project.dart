import 'library_item.dart';

class Project implements LibraryItem {
  @override
  final String id;
  @override
  final String title;

  const Project({required this.id, required this.title});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        title: json['title'] as String,
      );
}
