part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class ThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  ThemeChanged(this.themeMode);
}

class LanguageChanged extends SettingsEvent {
  final String languageCode;

  LanguageChanged(this.languageCode);
}

class OfflineModeToggled extends SettingsEvent {
  final bool enabled;

  OfflineModeToggled(this.enabled);
}