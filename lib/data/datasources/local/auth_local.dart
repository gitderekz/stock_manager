import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/data/datasources/local/hive_service.dart';

import '../../../domain/exceptions/auth_exceptions.dart';

class AuthLocal {
  final SharedPreferences sharedPreferences;
  final HiveService hiveService;

  static const String _authTokenKey = 'auth_token';

  AuthLocal({
    required this.sharedPreferences,
    required this.hiveService,
  });

  /// Save both user and JWT token
  Future<void> cacheUser(User user, String token) async {
    await hiveService.cacheUser(user);
    await sharedPreferences.setString(_authTokenKey, token);
  }

  /// Only save JWT token (optional if separate)
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(_authTokenKey, token);
  }

  /// Retrieve JWT token
  Future<String?> getToken() async {
    return sharedPreferences.getString(_authTokenKey);
  }

  /// Retrieve user object
  Future<User?> getCachedUser() async {
    return await hiveService.getCachedUser();
  }

  /// Check if JWT token is stored
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear user & token on logout
  Future<void> clearUser() async {
    await hiveService.clearUser();
    await sharedPreferences.remove(_authTokenKey);
  }

  /// For offline login using hashed password
  Future<User> offlineLogin(String username, String passwordHash) async {
    final user = await hiveService.getCachedUser();
    if (user == null || user.username != username || user.passwordHash != passwordHash) {
      throw AuthException(message: 'Invalid credentials');
    }
    return user;
  }
}
// *******************************




// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stock_manager/domain/entities/user.dart';
// import 'package:stock_manager/data/datasources/local/hive_service.dart';
//
// import '../../../domain/exceptions/auth_exceptions.dart';
//
// class AuthLocal {
//   final SharedPreferences sharedPreferences;
//   final HiveService hiveService;
//
//   AuthLocal({
//     required this.sharedPreferences,
//     required this.hiveService,
//   });
//
//   Future<void> saveUser(String userJson) async {
//     // Save locally
//   }
//
//   Future<void> cacheUser(User user) async {
//     await hiveService.cacheUser(user);
//     await sharedPreferences.setString('auth_token', 'dummy_token');
//   }
//
//   Future<User?> getCachedUser() async {
//     return await hiveService.getCachedUser();
//   }
//
//   Future<void> clearUser() async {
//     await hiveService.clearUser();
//     await sharedPreferences.remove('auth_token');
//   }
//
//   Future<User> offlineLogin(String username, String passwordHash) async {
//     final user = await hiveService.getCachedUser();
//     if (user == null || user.passwordHash != passwordHash) {
//       throw AuthException(message: 'Invalid credentials');
//     }
//     return user;
//   }
// }