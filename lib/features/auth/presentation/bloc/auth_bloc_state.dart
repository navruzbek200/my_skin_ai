part of 'auth_bloc.dart';

sealed class AuthSessionState extends Equatable {
  const AuthSessionState();

  /// Accounts made before this shipped never saw a verification step, so some
  /// of them hold addresses their owner cannot read. Gating those would lock
  /// the person out for good — the link can never arrive — so the cut-off
  /// grandfathers them in and they get the nag card on the account screen
  /// instead. Only sign-ups from here on have to confirm before entering.
  ///
  /// Set a week past the build date on purpose. Play review and a staged
  /// rollout mean this ships to people over days, and anyone who signs up on
  /// the old build in that window would otherwise be gated the moment they
  /// update. Being late here costs nothing — those sign-ups behave exactly as
  /// they do today — while being early is a lockout no client can undo.
  static final DateTime verificationRequiredFrom = DateTime.utc(2026, 8, 25);

  bool get isAuthenticated => this is AuthAuthenticatedSession;

  /// Google accounts arrive already verified; email/password ones do not until
  /// the link is clicked.
  bool get isEmailVerified =>
      this is AuthAuthenticatedSession &&
      (this as AuthAuthenticatedSession).emailVerified;

  /// True when this session has to confirm its address before the app opens.
  /// Guards read this rather than [isEmailVerified] so the cut-off above is
  /// applied in one place and cannot be forgotten at a call site.
  bool get needsVerificationGate {
    final session = this;
    if (session is! AuthAuthenticatedSession) return false;
    if (session.emailVerified) return false;
    final created = session.createdAt;
    // A null creationTime should not happen, but if it ever does, letting the
    // person in is the safe way to be wrong — the alternative is a lockout we
    // cannot undo from the client.
    if (created == null) return false;
    return !created.isBefore(verificationRequiredFrom);
  }

  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthSessionState {
  const AuthUnauthenticated();
}

class AuthAuthenticatedSession extends AuthSessionState {
  AuthAuthenticatedSession(this.user)
      : emailVerified = user.emailVerified,
        createdAt = user.metadata.creationTime;

  final User user;

  /// When the Auth record was created. Read once here for the same reason as
  /// [emailVerified]: `reload()` mutates [user] in place.
  final DateTime? createdAt;

  /// Snapshotted at construction rather than read through [user]. `reload()`
  /// mutates the User in place, so a lazily-read flag would change inside the
  /// *previous* state object too — Equatable would then see the old and new
  /// states as equal and Bloc would swallow the emit, leaving a verified user
  /// stuck on the verify screen forever.
  final bool emailVerified;

  @override
  List<Object?> get props => [user.uid, emailVerified];
}
