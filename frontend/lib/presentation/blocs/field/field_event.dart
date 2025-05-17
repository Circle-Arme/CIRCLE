

abstract class FieldEvent {}

class FetchFields extends FieldEvent {}

class CreateField extends FieldEvent {
  final String name;
  final String description;
  final String? imagePath;

  CreateField(this.name, this.description, this.imagePath);
}

class UpdateField extends FieldEvent {
  final int id;
  final String name;
  final String description;
  final String? imagePath;

  UpdateField(this.id, this.name, this.description, this.imagePath);
}

class DeleteField extends FieldEvent {
  final int id;

  DeleteField(this.id);
}