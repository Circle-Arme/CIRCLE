import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/data/models/community_model.dart';

import '../../../core/services/CommunityService.dart';
import 'community_event.dart';
import 'community_state.dart';



class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityService communityService;

  CommunityBloc(this.communityService) : super(CommunityState()) {
    on<FetchCommunities>(_onFetchCommunities);
    on<CreateCommunity>(_onCreateCommunity);
    on<UpdateCommunity>(_onUpdateCommunity);
    on<DeleteCommunity>(_onDeleteCommunity);
  }

  Future<void> _onFetchCommunities(FetchCommunities event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final communities = await CommunityService.fetchAdminCommunities();
      emit(state.copyWith(isLoading: false, communities: communities, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateCommunity(CreateCommunity event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await CommunityService.createCommunity(event.fieldId, event.name, event.imagePath);
      final communities = await CommunityService.fetchAdminCommunities();
      emit(state.copyWith(isLoading: false, communities: communities, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateCommunity(UpdateCommunity event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await CommunityService.updateCommunity(event.id, event.fieldId, event.name, event.imagePath);
      final communities = await CommunityService.fetchAdminCommunities();
      emit(state.copyWith(isLoading: false, communities: communities, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteCommunity(DeleteCommunity event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await CommunityService.deleteCommunity(event.id);
      final communities = await CommunityService.fetchAdminCommunities();
      emit(state.copyWith(isLoading: false, communities: communities, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}