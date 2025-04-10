import 'package:flutter/material.dart';
abstract class ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;
  ChangeThemeEvent(this.themeMode);
}