// controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;

  ThemeCubit(this.prefs) : super(ThemeState(
      isDarkMode: prefs.getBool('isDarkMode') ?? false
  ));

  void toggleTheme() {
    final newState = ThemeState(isDarkMode: !state.isDarkMode);
    prefs.setBool('isDarkMode', newState.isDarkMode);
    emit(newState);
  }
}

class ThemeState {
  final bool isDarkMode;

  ThemeState({required this.isDarkMode});
}