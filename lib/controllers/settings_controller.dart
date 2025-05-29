import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_manager/utils/api_service.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _prefsKey = 'app_settings';

  SettingsCubit() : super(SettingsLoading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      // Try to load from local cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedSettings = prefs.getString(_prefsKey);

      if (cachedSettings != null) {
        emit(SettingsLoaded(Map<String, String>.from(json.decode(cachedSettings))));
      }

        // Then try to fetch from server
        final response = await ApiService.get('settings');
        if (response.statusCode == 200) {
          final data = json.decode(response.body); // a list
          final settingsList = List<Map<String, dynamic>>.from(data);

          final settings = <String, String>{};
          for (final item in settingsList) {
            settings[item['setting_key']] = item['setting_value'];
          }

          print('SETTINGS=> $settingsList => $settings');
          await prefs.setString(_prefsKey, json.encode(settings));
          emit(SettingsLoaded(settings));
        } else if (cachedSettings == null) {
          // If no cache and server fails, use defaults
          emit(SettingsLoaded({
            'offline_mode': 'false',
            'default_currency': 'Tsh',
            'language': 'en',
            'theme': 'light',
          }));
        }
      } catch (e) {
      emit(SettingsError('Error loading settings: ${e.toString()}'));
    }
  }

  Future<void> updateSetting(String key, String value) async {
    try {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        final currentValue = currentState.settings[key];
        if (currentValue == value) return; // 🔥 Skip update if no change

        final newSettings = Map<String, String>.from(currentState.settings);
        newSettings[key] = value;
        emit(SettingsLoaded(newSettings));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, json.encode(newSettings));

        final response = await ApiService.post('settings', {'key': key, 'value': value});
        if (response.statusCode != 200) {
          emit(currentState);
          throw Exception('Failed to update setting');
        }
      }
    } catch (e) {
      emit(SettingsError('Error updating setting: ${e.toString()}'));
      rethrow;
    }
  }


  Future<void> resetToDefaults() async {
    final defaultSettings = {
      'offline_mode': 'false',
      'default_currency': 'Tsh',
      'language': 'en',
      'theme': 'light',
    };

    emit(SettingsLoaded(defaultSettings));

    // Update both cache and server
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(defaultSettings));

    try {
      await ApiService.post('settings/reset', {});
    } catch (e) {
      // Silent fail - we've already updated locally
    }
  }
}

abstract class SettingsState {
  Map<String, String> get settings => {};
}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState{


// final List<Product> products;
// final List<StockMovement> recentMovements;
// final Map<String, dynamic>? stats;  // Add stats field
//
//
// ProductLoaded({
//   required this.products,
//   this.recentMovements = const [],
//   this.stats,
// });


  final Map<String, String> settings;

  SettingsLoaded(this.settings);

  // @override
  // Map<String, String> get settings => this.settings;
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
// **********************



// import 'dart:convert';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:stock_manager/utils/api_service.dart';
//
// class SettingsCubit extends Cubit<SettingsState> {
//   SettingsCubit() : super(SettingsLoading());
//
//   Future<void> loadSettings() async {
//     try {
//       final response = await ApiService.get('settings');
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final settings = Map<String, String>.from(data['settings']);
//         emit(SettingsLoaded(settings));
//       } else {
//         emit(SettingsError('Failed to load settings'));
//       }
//     } catch (e) {
//       emit(SettingsError('Error loading settings: ${e.toString()}'));
//     }
//   }
//
//   Future<void> updateSetting(String key, String value) async {
//     try {
//       final currentState = state;
//       if (currentState is SettingsLoaded) {
//         final newSettings = Map<String, String>.from(currentState.settings);
//         newSettings[key] = value;
//         emit(SettingsLoaded(newSettings));
//
//         final response = await ApiService.post(
//           'settings/update',
//           {'key': key, 'value': value},
//         );
//
//         if (response.statusCode != 200) {
//           emit(currentState); // Revert if update fails
//           throw Exception('Failed to update setting');
//         }
//       }
//     } catch (e) {
//       emit(SettingsError('Error updating setting: ${e.toString()}'));
//       rethrow;
//     }
//   }
// }
//
// abstract class SettingsState {}
//
// class SettingsLoading extends SettingsState {}
//
// class SettingsLoaded extends SettingsState {
//   final Map<String, String> settings;
//
//   SettingsLoaded(this.settings);
// }
//
// class SettingsError extends SettingsState {
//   final String message;
//
//   SettingsError(this.message);
// }