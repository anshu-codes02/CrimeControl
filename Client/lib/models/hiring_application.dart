class HiringApplication {
  final String? id;
  final String postId;
  final String? title;
  final String applicantId;
  final String? applicantFirstName; // Optional field for display purposes
  final String? applicantLastName; // Optional field for display purposes
  final String? applicantEmail; // Optional field for display purposes
  final String? applicantUsername; // Optional field for display purposes
  final String coverLetter;
  final DateTime? createdAt;
  final String? status;

  HiringApplication({
    this.id,
    this.applicantFirstName,
    this.applicantLastName,
    this.applicantEmail,
    this.applicantUsername,
     this.title,
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
        title: json['title'] ?? '', // Fallback to empty string if title is missing
        applicantFirstName: json['applicantFirstName'], // Optional field
        applicantLastName: json['applicantLastName'], // Optional field
        applicantEmail: json['applicantEmail'], // Optional field
        applicantUsername: json['applicantUsername'], // Optional field
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

  String get applicantName {
    return '${applicantFirstName ?? ''} ${applicantLastName ?? ''}'.trim();
  }
}
