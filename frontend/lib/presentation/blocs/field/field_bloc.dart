import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/field_service.dart';
import 'package:frontend/data/models/area_model.dart';

import 'field_state.dart';

import 'field_event.dart';

class FieldBloc extends Bloc<FieldEvent, FieldState> {
  final FieldService fieldService;

  FieldBloc(this.fieldService) : super(FieldState()) {
    on<FetchFields>(_onFetchFields);
    on<CreateField>(_onCreateField);
    on<UpdateField>(_onUpdateField);
    on<DeleteField>(_onDeleteField);
  }

  Future<void> _onFetchFields(FetchFields event, Emitter<FieldState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final fields = await FieldService.fetchFields();
      emit(state.copyWith(isLoading: false, fields: fields, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateField(CreateField event, Emitter<FieldState> emit) async {
    if (event.name.isEmpty || event.description.isEmpty) {
      emit(state.copyWith(isLoading: false, error: 'الاسم أو الوصف فارغ'));
      return;
    }
    developer.log('Creating field with name: ${event.name}, description: ${event.description}, image: ${event.imagePath}');
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(isLoading: true));
    try {
      await FieldService.createField(event.name, event.description, event.imagePath);
      final fields = await FieldService.fetchFields(); // إعادة جلب البيانات
      emit(state.copyWith(isLoading: false, fields: fields, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateField(UpdateField event, Emitter<FieldState> emit) async {
    if (event.name.isEmpty || event.description.isEmpty) {
      emit(state.copyWith(isLoading: false, error: 'الاسم أو الوصف فارغ'));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      await FieldService.updateField(event.id, event.name, event.description, event.imagePath);
      final fields = await FieldService.fetchFields();
      emit(state.copyWith(isLoading: false, fields: fields, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteField(DeleteField event, Emitter<FieldState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await FieldService.deleteField(event.id);
      final fields = await FieldService.fetchFields();
      emit(state.copyWith(isLoading: false, fields: fields, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}