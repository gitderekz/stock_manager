class AuthException implements Exception {
  final String message;
  final int? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException: $message';
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
      : super(message: 'Invalid username or password', code: 401);
}

class AccountDisabledException extends AuthException {
  AccountDisabledException()
      : super(message: 'Account is disabled', code: 403);
}

class TokenExpiredException extends AuthException {
  TokenExpiredException()
      : super(message: 'Session expired', code: 401);
}