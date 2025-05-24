// utils/preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  static bool getDarkMode() {
    return _prefs.getBool('darkMode') ?? false;
  }
}