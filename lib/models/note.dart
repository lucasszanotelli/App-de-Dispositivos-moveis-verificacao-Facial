class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;

  String get displayTitle => title.isEmpty ? 'Sem título' : title;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
