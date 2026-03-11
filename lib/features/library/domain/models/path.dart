import 'library_item.dart';

class Path implements LibraryItem {
  @override
  final String id;
  @override
  final String title;

  const Path({required this.id, required this.title});

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  factory Path.fromJson(Map<String, dynamic> json) => Path(
        id: json['id'] as String,
        title: json['title'] as String,
      );
}
