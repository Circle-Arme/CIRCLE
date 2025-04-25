class CommunityModel {
  final int id;
  final String name;
  final String areaId;
  final String? image;
  final String? level;

  CommunityModel({
    required this.id,
    required this.name,
    required this.areaId,
    this.image,
    this.level,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'],
      name: json['name'],
      areaId: json['field'].toString(), // تأكد من اسم الحقل كما في الـ API
      image: json['image'],
      level: json['level'],
    );
  }
}
