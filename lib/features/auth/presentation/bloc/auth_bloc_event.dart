part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Emitted by the `authStateChanges()` subscription — not dispatched by UI.
class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user?.uid];
}
