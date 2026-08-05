part of 'auth_bloc.dart';

sealed class AuthSessionState extends Equatable {
  const AuthSessionState();

  bool get isAuthenticated => this is AuthAuthenticatedSession;

  /// Google accounts arrive already verified; email/password ones do not until
  /// the link is clicked. Guards use this to keep unverified sign-ups out of
  /// the app, so an address nobody owns cannot be used to get in.
  bool get isEmailVerified =>
      this is AuthAuthenticatedSession &&
      (this as AuthAuthenticatedSession).emailVerified;

  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthSessionState {
  const AuthUnauthenticated();
}

class AuthAuthenticatedSession extends AuthSessionState {
  AuthAuthenticatedSession(this.user) : emailVerified = user.emailVerified;

  final User user;

  /// Snapshotted at construction rather than read through [user]. `reload()`
  /// mutates the User in place, so a lazily-read flag would change inside the
  /// *previous* state object too — Equatable would then see the old and new
  /// states as equal and Bloc would swallow the emit, leaving a verified user
  /// stuck on the verify screen forever.
  final bool emailVerified;

  @override
  List<Object?> get props => [user.uid, emailVerified];
}
