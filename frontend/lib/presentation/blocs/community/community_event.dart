

abstract class CommunityEvent {}

class FetchCommunities extends CommunityEvent {}

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

  UpdateCommunity(this.id, this.fieldId, this.name, this.imagePath);
}

class DeleteCommunity extends CommunityEvent {
  final int id;

  DeleteCommunity(this.id);
}