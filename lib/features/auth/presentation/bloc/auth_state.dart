part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthInfo extends AuthState {
  final String message;
  AuthInfo(this.message);
}

class AuthDeleted extends AuthState {}
