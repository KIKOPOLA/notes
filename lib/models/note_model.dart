class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool isArchived;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.isArchived = false,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
