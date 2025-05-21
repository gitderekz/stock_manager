import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/data/datasources/local/hive_service.dart';

import '../../../domain/exceptions/auth_exceptions.dart';

class AuthLocal {
  final SharedPreferences sharedPreferences;
  final HiveService hiveService;

  AuthLocal({
    required this.sharedPreferences,
    required this.hiveService,
  });

  Future<void> saveUser(String userJson) async {
    // Save locally
  }

  Future<void> cacheUser(User user) async {
    await hiveService.cacheUser(user);
    await sharedPreferences.setString('auth_token', 'dummy_token');
  }

  Future<User?> getCachedUser() async {
    return await hiveService.getCachedUser();
  }

  Future<void> clearUser() async {
    await hiveService.clearUser();
    await sharedPreferences.remove('auth_token');
  }

  Future<User> offlineLogin(String username, String passwordHash) async {
    final user = await hiveService.getCachedUser();
    if (user == null || user.passwordHash != passwordHash) {
      throw AuthException(message: 'Invalid credentials');
    }
    return user;
  }
}