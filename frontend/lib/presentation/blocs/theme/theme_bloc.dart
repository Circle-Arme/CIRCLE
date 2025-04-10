import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../../core/utils/shared_prefs.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(ThemeMode.system)) {
    on<LoadThemeEvent>((event, emit) async {
      final savedTheme = await SharedPrefs.getTheme();
      emit(ThemeState(savedTheme ?? ThemeMode.system));
    });

    on<ChangeThemeEvent>((event, emit) async {
      await SharedPrefs.saveTheme(event.themeMode);
      emit(ThemeState(event.themeMode));
    });
  }
}