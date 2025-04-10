class AreaModel {
  final int id; // ✅ أضف هذا الحقل
  final String title;
  final String subtitle;
  final String image;

  AreaModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'], // ✅ تأكد أنه موجود في JSON القادم من API
      title: json['name'],
      subtitle: json['description'],
      image: json['image'],

    );
  }
}
