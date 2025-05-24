// lib/utils/auth_helper.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  static Future<void> saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    return userString != null ? json.decode(userString) : null;
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

// // Update all other API calls to include the token
// Future<http.Response> _authenticatedGet(String endpoint) async {
//   final token = await AuthHelper.getToken();
//   return await http.get(
//     Uri.parse('$baseUrl/$endpoint'),
//     headers: {'Authorization': 'Bearer $token'},
//   );
// }