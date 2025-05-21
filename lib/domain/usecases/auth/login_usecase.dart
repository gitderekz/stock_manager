import 'package:stock_manager/domain/repositories/auth_repository.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String username, String password) async {
    try {
      return await repository.login(username, password);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Login failed: ${e.toString()}');
    }
  }
}