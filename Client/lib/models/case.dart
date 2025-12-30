class Case {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? postedAt;
  final String? imageUrl; // Keep for backward compatibility
  final List<String> imageUrls; // New field for multiple images
  final String? mediaUrl;
  final List<String> tags;
  final String? caseType;
  final String? difficulty;
  final Map<String, dynamic>? postedBy; // User who posted the case
  final String? closedAt;
  final String? deletableAt;

  Case({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.postedAt,
    this.imageUrl,
    this.imageUrls = const [],
    this.mediaUrl,
    this.tags = const [],
    this.caseType,
    this.difficulty,
    this.postedBy,
    this.closedAt,
    this.deletableAt,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      postedAt: json['postedAt'],
      imageUrl: json['imageUrl'],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      mediaUrl: json['mediaUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      caseType: json['caseType'],
      difficulty: json['difficulty'],
      postedBy: json['postedBy'],
      closedAt: json['closedAt'],
      deletableAt: json['deletableAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'postedAt': postedAt,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'mediaUrl': mediaUrl,
      'tags': tags,
      'caseType': caseType,
      'difficulty': difficulty,
      'postedBy': postedBy,
      'closedAt': closedAt,
      'deletableAt': deletableAt,
    };
  }

  /// Check if the case is closed
  bool get isClosed => status.toUpperCase() == 'CLOSED';

  /// Get the poster's user ID if available
  int? get posterId => postedBy?['id'];

  /// Get the poster's username if available
  String? get posterUsername => postedBy?['username'];

  /// Check if the case can potentially be deleted (closed status)
  bool get canPotentiallyBeDeleted => isClosed && deletableAt != null;
}
