// controllers/auth_controller.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/utils/auth_helper.dart';
import '../utils/database_helper.dart';

// Update auth_controller.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/database_helper.dart';

class AuthCubit extends Cubit<AuthState> {
  final DatabaseHelper dbHelper;
  static const String baseUrl = 'http://192.168.8.101:5000/api';

  AuthCubit(this.dbHelper) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        // Save user data to local storage
        await AuthHelper.saveAuthData(data['token'], data['user']);
        await dbHelper.saveUserData(data);
        emit(AuthAuthenticated(userData: data));
        return; // Ensure we don't continue after successful auth
      } else {
        emit(AuthError(data['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      print(e.toString());
    }
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}

abstract class AuthState {
  Map<String, dynamic>? get userData => null;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> userData;

  AuthAuthenticated({required this.userData});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}