part of 'auth_bloc.dart';

sealed class AuthSessionState extends Equatable {
  const AuthSessionState();

  bool get isAuthenticated => this is AuthAuthenticatedSession;

  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthSessionState {
  const AuthUnauthenticated();
}

class AuthAuthenticatedSession extends AuthSessionState {
  const AuthAuthenticatedSession(this.user);

  final User user;

  @override
  List<Object?> get props => [user.uid];
}
