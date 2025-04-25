class UserModel {
  final String name;
  final String profileImageUrl;
  final String userType;

  UserModel({
    required this.name,
    required this.profileImageUrl,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      profileImageUrl: json['profile_image'],
      userType: json['user_type'] ?? 'normal',
    );
  }
}
