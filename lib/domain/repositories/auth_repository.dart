import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<User> offlineLogin(String username, String passwordHash);
  Future<void> logout();
  Future<User?> getCachedUser();
  Future<void> clearUser();
  Future<bool> isAuthenticated();
}
// abstract class AuthRepository {
//   Future<User> login(String username, String password);
//   Future<void> logout();
//   Future<User?> getCachedUser();
//   Future<void> clearUser();
//   Future<User> offlineLogin(String username, String passwordHash);
//   Future<bool> isAuthenticated();
// }