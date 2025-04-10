class UserProfileModel {
  final int id;
  final String name;
  final String workEducation;
  final String position;
  final String description;
  final String email;
  final List<String> communities;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.workEducation,
    required this.position,
    required this.description,
    required this.email,
    required this.communities,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'], // ✅ نحوله إلى String في كل الحالات
      name: json['name'] ?? '',
      workEducation: json['work_education'] ?? '',
      position: json['position'] ?? '',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      communities: List<String>.from(json['communities'] ?? []),
    );
  }

  UserProfileModel copyWith({
    int? id,
    String? name,
    String? workEducation,
    String? position,
    String? description,
    String? email,
    List<String>? communities,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      workEducation: workEducation ?? this.workEducation,
      position: position ?? this.position,
      description: description ?? this.description,
      email: email ?? this.email,
      communities: communities ?? this.communities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'work_education': workEducation,
      'position': position,
      'description': description,
      'email': email,
      'communities': communities,
    };
  }

  bool get isNewUser {
    return name.isEmpty &&
        workEducation.isEmpty &&
        position.isEmpty &&
        description.isEmpty &&
        email.isEmpty &&
        communities.isEmpty;
  }
}
