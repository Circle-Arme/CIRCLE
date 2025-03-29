class UserModel {
  final String name;
  final String profileImageUrl;

  UserModel({
    required this.name,
    required this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      profileImageUrl: json['profile_image'],
    );
  }
}
