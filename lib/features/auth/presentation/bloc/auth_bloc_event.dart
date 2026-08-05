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
  List<Object?> get props => [user?.uid, user?.emailVerified];
}

/// Re-reads the current user from the server. `authStateChanges()` never fires
/// when someone clicks the verification link in their mail client — the flag
/// only changes on the Auth record — so the verify screen polls with this.
class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}
