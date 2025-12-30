class HiringPost {
  final int? id;
  final int recruiterId;
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
    id: json['id'],
    recruiterId: json['recruiterId'],
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
    'recruiterId': recruiterId,
    'hourlyRate': hourlyRate,
    'caseType': caseType,
    'overview': overview,
    'location': location,
  };
}
