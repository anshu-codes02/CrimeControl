class User {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? expertise;
  final String? location;
  final String? phoneNumber;
  final String role;
  final List<String> interests;
  final List<String> expertiseAreas;
  final bool organizationVerified;
  final String? organizationType;
  final List<String> badges;
  final double averageRating;
  final int totalRatings;
  final int solvedCasesCount;
  final int activeCasesCount;
  final bool availableForHire;
  final double? hourlyRate;
  final String? investigatorBio;
  final String? experience;
  final String? certifications;
  final List<String> specializationsList;
  final bool emailVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.bio,
    this.expertise,
    this.location,
    this.phoneNumber,
    this.role = 'SOLVER',
    this.interests = const [],
    this.expertiseAreas = const [],
    this.organizationVerified = false,
    this.organizationType,
    this.badges = const [],
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.solvedCasesCount = 0,
    this.activeCasesCount = 0,
    this.availableForHire = false,
    this.hourlyRate,
    this.investigatorBio,
    this.experience,
    this.certifications,
    this.specializationsList = const [],
    this.emailVerified = false,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'];
      } else if (json['id'] is String) {
        parsedId = int.tryParse(json['id']);
      }
    }
    return User(
      id: parsedId,
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      bio: json['bio'],
      expertise: json['expertise'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'SOLVER',
      interests: List<String>.from(json['interests'] ?? []),
      expertiseAreas: List<String>.from(json['expertiseAreas'] ?? []),
      organizationVerified: json['organizationVerified'] ?? false,
      organizationType: json['organizationType'],
      badges: List<String>.from(json['badges'] ?? []),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      solvedCasesCount: json['solvedCasesCount'] ?? 0,
      activeCasesCount: json['activeCasesCount'] ?? 0,
      availableForHire: json['availableForHire'] ?? false,
      hourlyRate: json['hourlyRate']?.toDouble(),
      investigatorBio: json['investigatorBio'],
      experience: json['experience'],
      certifications: json['certifications'],
      specializationsList: List<String>.from(json['specializationsList'] ?? []),
      emailVerified: json['emailVerified'] ?? false,
      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.parse(json['lastLoginAt'])
              : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'expertise': expertise,
      'location': location,
      'phoneNumber': phoneNumber,
      'role': role,
      'interests': interests,
      'expertiseAreas': expertiseAreas,
      'organizationVerified': organizationVerified,
      'organizationType': organizationType,
      'badges': badges,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'solvedCasesCount': solvedCasesCount,
      'activeCasesCount': activeCasesCount,
      'availableForHire': availableForHire,
      'hourlyRate': hourlyRate,
      'investigatorBio': investigatorBio,
      'experience': experience,
      'certifications': certifications,
      'specializationsList': specializationsList,
      'emailVerified': emailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : username ?? '';
}
