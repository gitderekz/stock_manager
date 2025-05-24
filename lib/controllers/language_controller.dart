// controllers/language_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final SharedPreferences prefs;

  LanguageCubit(this.prefs)
      : super(LanguageState(
    locale: Locale(prefs.getString('language') ?? 'en'),
  ));

  void changeLanguage(String languageCode) {
    prefs.setString('language', languageCode);
    emit(LanguageState(locale: Locale(languageCode)));
  }
}

class LanguageState {
  final Locale locale;

  LanguageState({required this.locale});
}