import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/organization_user_service.dart';
import 'package:frontend/data/models/user_profile_model.dart';

import 'organization_event.dart';
import 'organization_state.dart';



class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  OrganizationBloc() : super(OrganizationInitial()) {
    on<FetchOrganizations>(_onFetchOrganizations);
    on<CreateOrganization>(_onCreateOrganization);
    on<UpdateOrganization>(_onUpdateOrganization);
    on<DeleteOrganization>(_onDeleteOrganization);
  }

  Future<void> _onFetchOrganizations(FetchOrganizations event, Emitter<OrganizationState> emit) async {
    emit(OrganizationLoading());
    try {
      final organizations = await OrganizationUserService.fetchOrganizationUsers();
      emit(OrganizationLoaded(organizations: organizations));
    } catch (e) {
      emit(OrganizationError(error: e.toString()));
    }
  }

  Future<void> _onCreateOrganization(CreateOrganization event, Emitter<OrganizationState> emit) async {
    try {
      await OrganizationUserService.createOrganizationUser(event.profile, event.password);
      final organizations = await OrganizationUserService.fetchOrganizationUsers();
      emit(OrganizationLoaded(organizations: organizations));
    } catch (e) {
      emit(OrganizationError(error: e.toString()));
    }
  }

  Future<void> _onUpdateOrganization(UpdateOrganization event, Emitter<OrganizationState> emit) async {
    try {
      await OrganizationUserService.updateOrganizationUser(event.userId, event.profile);
      final organizations = await OrganizationUserService.fetchOrganizationUsers();
      emit(OrganizationLoaded(organizations: organizations));
    } catch (e) {
      emit(OrganizationError(error: e.toString()));
    }
  }

  Future<void> _onDeleteOrganization(DeleteOrganization event, Emitter<OrganizationState> emit) async {
    try {
      await OrganizationUserService.deleteOrganizationUser(event.userId);
      final organizations = await OrganizationUserService.fetchOrganizationUsers();
      emit(OrganizationLoaded(organizations: organizations));
    } catch (e) {
      emit(OrganizationError(error: e.toString()));
    }
  }
}



