


import '../../../data/models/area_model.dart';

class FieldState {
  final bool isLoading;
  final List<AreaModel> fields;
  final String? error;

  FieldState({
    this.isLoading = false,
    this.fields = const [],
    this.error,
  });

  FieldState copyWith({
    bool? isLoading,
    List<AreaModel>? fields,
    String? error,
  }) {
    return FieldState(
      isLoading: isLoading ?? this.isLoading,
      fields: fields ?? this.fields,
      error: error,
    );
  }
}