class AreaModel {
  final int id;
  final String title;
  final String subtitle;
  final String? image;

  AreaModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.image,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      subtitle: json['description'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': subtitle,
      'image': image,
    };
  }
}
