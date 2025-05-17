import '../../../data/models/user_profile_model.dart';

abstract class OrganizationState {}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationLoaded extends OrganizationState {
  final List<UserProfileModel> organizations;

  OrganizationLoaded({required this.organizations});
}

class OrganizationError extends OrganizationState {
  final String error;

  OrganizationError({required this.error});
}