part of 'auth_bloc.dart';

abstract class AuthState {
  User? get user => null;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User _user;

  AuthAuthenticated(this._user);

  @override
  User? get user => _user;
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
// *************************



// part of 'auth_bloc.dart';
//
// abstract class AuthState {}
//
// class AuthInitial extends AuthState {}
//
// class AuthLoading extends AuthState {}
//
// class AuthAuthenticated extends AuthState {
//   final User user;
//
//   AuthAuthenticated(this.user);
// }
//
// class AuthUnauthenticated extends AuthState {}
//
// class AuthError extends AuthState {
//   final String message;
//
//   AuthError(this.message);
// }