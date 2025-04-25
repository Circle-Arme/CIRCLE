class UserProfileModel {
  final int id;
  final int userId;
  final String name;
  final String workEducation;
  final String position;
  final String description;
  final String email;
  final List<String> communities;
  final String userType;
  final String website;          // مازال non‑nullable

  const UserProfileModel({
    required this.id,
    required this.userId,
    this.name           = '',
    this.workEducation  = '',
    this.position       = '',
    this.description    = '',
    this.email          = '',
    this.communities    = const [],
    this.userType       = 'normal',
    this.website        = '',   // ✅ قيمة افتراضيّة
  });

  factory UserProfileModel.fromJson(Map<String,dynamic> json) {
    final int rawId = json['id'] as int;
    final dynamic maybeUser = json['user']; // قد يكون int أو null
    return UserProfileModel(
      id: rawId,
      userId: (maybeUser ?? rawId) as int,
      name: json['name']            ?? '',
      workEducation: json['work_education'] ?? '',
      position: json['position']    ?? '',
      description: json['description'] ?? '',
      email: json['email']          ?? '',
      website: json['website']      ?? '',
      communities: List<String>.from(json['communities'] ?? []),
      userType: json['user_type']   ?? 'normal',
    );
  }

  UserProfileModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? workEducation,
    String? position,
    String? description,
    String? email,
    List<String>? communities,
    String? userType,
    String? website,
  }) {
    return UserProfileModel(
      id:            id            ?? this.id,
      userId:        userId        ?? this.userId,
      name:          name          ?? this.name,
      workEducation: workEducation ?? this.workEducation,
      position:      position      ?? this.position,
      description:   description   ?? this.description,
      email:         email         ?? this.email,
      communities:   communities   ?? this.communities,
      userType:      userType      ?? this.userType,
      website:       website       ?? this.website,     // ✅ أصلحت الخطأ (كان userType)
    );
  }

  Map<String, dynamic> toJson() => {
    'id'            : id,
    'userId'        : userId,
    'name'          : name,
    'work_education': workEducation,
    'position'      : position,
    'description'   : description,
    'email'         : email,
    'communities'   : communities,
    'user_type'     : userType,
    'website'       : website,
  };

  bool get isNewUser =>
      name.isEmpty &&
          workEducation.isEmpty &&
          position.isEmpty &&
          description.isEmpty &&
          email.isEmpty &&
          website.isEmpty &&
          communities.isEmpty;
}
