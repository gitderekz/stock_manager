import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/data/datasources/remote/auth_api.dart';
import 'package:stock_manager/data/datasources/local/auth_local.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';

import '../../domain/repositories/auth_repository.dart';

// class AuthRepository {
//   final AuthApi _authApi;
//   final AuthLocal _authLocal;
//   final ConnectivityService _connectivityService;
//
//   AuthRepository({
//     required AuthApi authApi,
//     required AuthLocal authLocal,
//     required ConnectivityService connectivityService,
//   })  : _authApi = authApi,
//         _authLocal = authLocal,
//         _connectivityService = connectivityService;
//
//   Future<User> login(String username, String password) async {
//     try {
//       final isOnline = await _connectivityService.isConnected();
//
//       if (isOnline) {
//         final response = await _authApi.login(username, password);
//         await _authLocal.cacheUser(response);
//         return response;
//       } else {
//         final user = await _authLocal.offlineLogin(username, password);
//         return user;
//       }
//     } on AuthException catch (_) {
//       rethrow;
//     } catch (e) {
//       throw AuthException(message: 'Login failed: ${e.toString()}');
//     }
//   }
//
//   Future<void> logout() async {
//     await _authLocal.clearUser();
//   }
//
//   Future<User?> getCachedUser() async {
//     return await _authLocal.getCachedUser();
//   }
//
//   Future<bool> isAuthenticated() async {
//     return await _authLocal.getCachedUser() != null;
//   }
// }
// ***************************************

import 'package:dio/dio.dart';
import 'package:stock_manager/domain/entities/login_response.dart';
import 'package:stock_manager/domain/entities/user.dart';
import 'package:stock_manager/domain/exceptions/auth_exceptions.dart';
import 'package:stock_manager/domain/repositories/auth_repository.dart';
import 'package:stock_manager/data/datasources/remote/auth_api.dart';
import 'package:stock_manager/data/datasources/local/auth_local.dart';
import 'package:stock_manager/utils/services/connectivity_service.dart';

class DataAuthRepository implements AuthRepository {
  final AuthApi authApi;
  final AuthLocal authLocal;
  final ConnectivityService connectivityService;

  DataAuthRepository({
    required this.authApi,
    required this.authLocal,
    required this.connectivityService,
  });

  @override
  Future<LoginResponse> login(String username, String password) async {
    final loginResponse = await authApi.login(username, password);

    // Save user & token locally
    await authLocal.cacheUser(loginResponse.user, loginResponse.token);
    print("IMEFANIKIWA KUINGIA ${loginResponse.user}, ${loginResponse.token}");
    return loginResponse;
  }

  @override
  Future<User> offlineLogin(String username, String passwordHash) async {
    return await authLocal.offlineLogin(username, passwordHash);
  }

  @override
  Future<void> logout() async {
    await authLocal.clearUser();
  }

  @override
  Future<User?> getCachedUser() async {
    return await authLocal.getCachedUser();
  }

  @override
  Future<void> clearUser() async {
    await authLocal.clearUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await authLocal.isAuthenticated();
  }

  @override
  Future<void> persistUserSession(User user, String token) {
    // TODO: implement persistUserSession
    throw UnimplementedError();
  }
}
// *******************************************

// class DataAuthRepository implements AuthRepository {
//   final AuthApi authApi;
//   final AuthLocal authLocal;
//   final ConnectivityService connectivityService;
//
//   DataAuthRepository({
//     required this.authApi,
//     required this.authLocal,
//     required this.connectivityService,
//   });
//
//   @override
//   // TODO: implement _authApi
//   AuthApi get _authApi => throw UnimplementedError();
//
//   @override
//   // TODO: implement _authLocal
//   AuthLocal get _authLocal => throw UnimplementedError();
//
//   @override
//   // TODO: implement _connectivityService
//   ConnectivityService get _connectivityService => throw UnimplementedError();
//
//   @override
//   Future<User?> getCachedUser() {
//     // TODO: implement getCachedUser
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<bool> isAuthenticated() {
//     // TODO: implement isAuthenticated
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<User> login(String username, String password) {
//     // TODO: implement login
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> logout() {
//     // TODO: implement logout
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> clearUser() {
//     // TODO: implement clearUser
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<User> offlineLogin(String username, String passwordHash) {
//     // TODO: implement offlineLogin
//     throw UnimplementedError();
//   }
//
// // Implement AuthRepository methods here
// }
