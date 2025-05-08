class ChatRoomModel {
  final int id;
  final int communityId;
  final String name;
  final String type;

  ChatRoomModel({
    required this.id,
    required this.communityId,
    required this.name,
    required this.type,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? 0,
      communityId: json['community'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community': communityId,
      'name': name,
      'type': type,
    };  }
}