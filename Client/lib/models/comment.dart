class Comment {
  final int id;
  final int userId;
  final String author;
  final String content;
  final String? createdAt;

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
      userId: json['userId'] ?? 0,
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'],
    );
  }
}
