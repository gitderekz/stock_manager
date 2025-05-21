part of 'settings_bloc.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final bool offlineModeEnabled;

  SettingsState({
    required this.themeMode,
    required this.locale,
    required this.offlineModeEnabled,
  });

  factory SettingsState.initial() {
    return SettingsState(
      themeMode: ThemeMode.system,
      locale: const Locale('en'),
      offlineModeEnabled: false,
    );
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? offlineModeEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      offlineModeEnabled: offlineModeEnabled ?? this.offlineModeEnabled,
    );
  }
}