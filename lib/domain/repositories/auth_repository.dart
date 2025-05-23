import 'package:dio/dio.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';
import 'package:stock_manager/domain/entities/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String username, String password);
  Future<User> offlineLogin(String username, String passwordHash);
  Future<void> logout();
  Future<User?> getCachedUser();
  Future<void> clearUser();
  Future<bool> isAuthenticated();
  Future<void> persistUserSession(User user, String token);
}
// abstract class AuthRepository {
//   Future<User> login(String username, String password);
//   Future<void> logout();
//   Future<User?> getCachedUser();
//   Future<void> clearUser();
//   Future<User> offlineLogin(String username, String passwordHash);
//   Future<bool> isAuthenticated();
// }