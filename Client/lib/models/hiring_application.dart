class HiringApplication {
  final int? id;
  final int postId;
  final int applicantId;
  final String coverLetter;
  final DateTime? createdAt;
  final String? status;

  HiringApplication({
    this.id,
    required this.postId,
    required this.applicantId,
    required this.coverLetter,
    this.createdAt,
    this.status,
  });

  factory HiringApplication.fromJson(Map<String, dynamic> json) =>
      HiringApplication(
        id: json['id'],
        postId: json['postId'],
        applicantId: json['applicantId'],
        coverLetter: json['coverLetter'],
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : null,
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'postId': postId,
    'applicantId': applicantId,
    'coverLetter': coverLetter,
  };
}
