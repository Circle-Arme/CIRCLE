class AreaModel {
  final String title;
  final String subtitle;
  final String imageUrl;

  AreaModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['image_url'],
    );
  }
}