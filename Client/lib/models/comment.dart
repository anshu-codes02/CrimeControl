class Comment {
  final String id;
  final String userId;
  final String author;
  final String content;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'] ?? '',
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
