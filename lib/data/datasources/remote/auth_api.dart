import 'package:dio/dio.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';
import 'package:stock_manager/utils/constants/environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '${dotenv.get(Environment.apiUrl)}/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      return User.fromJson(response.data['user']);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw InvalidCredentialsException();
      } else if (e.response?.statusCode == 403) {
        throw AccountDisabledException();
      } else {
        throw AuthException(message: 'Login failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException(message: 'Login failed: ${e.toString()}');
    }
  }
}