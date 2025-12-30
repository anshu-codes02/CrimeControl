class Rating {
  final int id;
  final int raterId; // User who gave the rating
  final int ratedUserId; // User who received the rating
  final int caseId; // Case this rating is related to
  final int score; // 1-5 stars
  final String? comment;
  final String? raterName;
  final String? raterRole;
  final String? createdAt;

  Rating({
    required this.id,
    required this.raterId,
    required this.ratedUserId,
    required this.caseId,
    required this.score,
    this.comment,
    this.raterName,
    this.raterRole,
    this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] ?? 0,
      raterId: json['raterId'] ?? 0,
      ratedUserId: json['ratedUserId'] ?? 0,
      caseId: json['caseId'] ?? 0,
      score: json['score'] ?? 0,
      comment: json['comment'],
      raterName: json['raterName'],
      raterRole: json['raterRole'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'raterId': raterId,
      'ratedUserId': ratedUserId,
      'caseId': caseId,
      'score': score,
      'comment': comment,
      'raterName': raterName,
      'raterRole': raterRole,
      'createdAt': createdAt,
    };
  }
}
