import 'package:flutter/material.dart'; // استيراد Locale

abstract class LanguageEvent {}

class LoadLanguageEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final Locale locale;
  ChangeLanguageEvent(this.locale);
}