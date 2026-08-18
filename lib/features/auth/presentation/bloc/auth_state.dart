part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

/// Which button started the request. Both sign-in paths share one cubit, so
/// without this a tap on "Davom etish" spins the Google button too and the
/// person cannot tell which one they actually pressed. Named [AuthMethod]
/// rather than the obvious AuthProvider, which firebase_auth already exports.
enum AuthMethod { email, google }

class AuthLoading extends AuthState {
  AuthLoading([this.method = AuthMethod.email]);

  final AuthMethod method;
}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// Non-error notice — e.g. "password reset link sent".
class AuthInfo extends AuthState {
  final String message;
  AuthInfo(this.message);
}

class AuthDeleted extends AuthState {}
