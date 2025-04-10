class CommunityModel {
  final int id;
  final String name;
  final String areaId;
  final String? image;

  CommunityModel({
    required this.id,
    required this.name,
    required this.areaId,
    this.image,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'],
      name: json['name'],
      areaId: json['field'].toString(), // اسم الحقل في الـ API
      image: json['image'],
    );
  }
}
