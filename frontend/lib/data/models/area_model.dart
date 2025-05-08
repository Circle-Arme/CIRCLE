class AreaModel {
  final int id;
  final String title;
  final String subtitle;
  final String? image;

  const AreaModel({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': title,
    'description': subtitle,
    'image': image,
  };

  /// منشئ فارغ
  factory AreaModel.empty() {
    return const AreaModel(
      id: 0,
      title: '',
      subtitle: '',
      image: null,
    );
  }

  /// copyWith لتحديث الحقول بسهولة
  AreaModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? image,
  }) {
    return AreaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
    );
  }
}
