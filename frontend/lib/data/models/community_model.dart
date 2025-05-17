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
      areaId: json['field'].toString(),
      image: json['image'] as String?,
      level: json['level'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'field': int.tryParse(areaId) ?? 0,
    'image': image,
    'level': level,
  };

  /// منشئ فارغ
  factory CommunityModel.empty() {
    return CommunityModel(
      id: 0,
      name: '',
      areaId: '',
      image: null,
      level: null,
    );
  }

  /// copyWith لتحديث الحقول
  CommunityModel copyWith({
    int? id,
    String? name,
    String? areaId,
    String? image,
    String? level,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      areaId: areaId ?? this.areaId,
      image: image ?? this.image,
      level: level ?? this.level,
    );
  }
}

