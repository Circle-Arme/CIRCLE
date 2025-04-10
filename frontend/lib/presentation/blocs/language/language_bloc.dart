import 'package:flutter/material.dart'; // استيراد مكتبة flutter لاستخدام Locale
import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_event.dart';
import 'language_state.dart';
import '../../../core/utils/shared_prefs.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageState(const Locale('en'))) {
    on<LoadLanguageEvent>((event, emit) async {
      final savedLanguage = await SharedPrefs.getLanguage();
      emit(LanguageState(Locale(savedLanguage ?? 'en')));
    });

    on<ChangeLanguageEvent>((event, emit) async {
      await SharedPrefs.saveLanguage(event.locale.languageCode); // تصحيح saveL إلى saveLanguage
      emit(LanguageState(event.locale));
    });
  }
}