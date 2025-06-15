

abstract class CommunityEvent {}

class FetchCommunities extends CommunityEvent {
  final int? fieldId; // NEW: Optional fieldId to fetch communities for a specific field

  FetchCommunities({this.fieldId});
}

class CreateCommunity extends CommunityEvent {
  final int fieldId;
  final String name;
  final String? imagePath;

  CreateCommunity(this.fieldId, this.name, this.imagePath);
}

class UpdateCommunity extends CommunityEvent {
  final int id;
  final int fieldId;
  final String name;
  final String? imagePath;
  final bool   clearImage;

  UpdateCommunity(this.id, this.fieldId, this.name, this.imagePath,{this.clearImage = false,});
}

class DeleteCommunity extends CommunityEvent {
  final int id;

  DeleteCommunity(this.id);
}