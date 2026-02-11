class HiringPost {
  final String? id;
  final String recruiterId;
  final double hourlyRate;
  final String caseType;
  final String overview;
  final String location;
  final DateTime? createdAt;
  final String? status;

  HiringPost({
    this.id,
    required this.recruiterId,
    required this.hourlyRate,
    required this.caseType,
    required this.overview,
    required this.location,
    this.createdAt,
    this.status,
  });

  factory HiringPost.fromJson(Map<String, dynamic> json) => HiringPost(
    id: json['_id'],
    recruiterId: json['recruiter'],
    hourlyRate: (json['hourlyRate'] as num).toDouble(),
    caseType: json['caseType'],
    overview: json['overview'],
    location: json['location'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'recruiter': recruiterId,
    'hourlyRate': hourlyRate,
    'caseType': caseType,
    'overview': overview,
    'location': location,
  };
}
