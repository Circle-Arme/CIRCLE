

import '../../../data/models/community_model.dart';

class CommunityState {
  final bool isLoading;
  final List<CommunityModel> communities;
  final String? error;

  CommunityState({
    this.isLoading = false,
    this.communities = const [],
    this.error,
  });

  CommunityState copyWith({
    bool? isLoading,
    List<CommunityModel>? communities,
    String? error,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      communities: communities ?? this.communities,
      error: error,
    );
  }
}