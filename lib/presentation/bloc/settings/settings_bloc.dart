import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<LanguageChanged>(_onLanguageChanged);
    on<OfflineModeToggled>(_onOfflineModeToggled);
  }

  void _onThemeChanged(ThemeChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onLanguageChanged(LanguageChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(locale: Locale(event.languageCode)));
  }

  void _onOfflineModeToggled(OfflineModeToggled event, Emitter<SettingsState> emit) {
    emit(state.copyWith(offlineModeEnabled: event.enabled));
  }
}