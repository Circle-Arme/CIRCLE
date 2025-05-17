import '../../../data/models/user_profile_model.dart';

abstract class OrganizationEvent {}

class FetchOrganizations extends OrganizationEvent {}

class CreateOrganization extends OrganizationEvent {
  final UserProfileModel profile;
  final String password;

  CreateOrganization(this.profile, this.password);
}

class UpdateOrganization extends OrganizationEvent {
  final int userId;
  final UserProfileModel profile;

  UpdateOrganization(this.userId, this.profile);
}

class DeleteOrganization extends OrganizationEvent {
  final int userId;

  DeleteOrganization(this.userId);
}