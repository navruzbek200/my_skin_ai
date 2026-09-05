part of 'auth_cubit.dart';

/// What the auth screens have to say, as a code rather than a sentence.
///
/// The cubit knows *what* happened; only the widget layer knows which language
/// to say it in. Emitting a finished string here would nail every message to
/// one language and make [AuthCubit] depend on `AppLocalizations`, which is a
/// Flutter type — see `AuthMessageText` for the other half of this.
enum AuthMessage {
  // ── Failures ──
  generic,
  timedOut,
  userNotFound,
  wrongPassword,

  /// The address exists and the password did not match — which is also exactly
  /// what a Google-only account looks like, so the copy has to cover both.
  wrongPasswordOrGoogle,
  emailInUse,
  weakPassword,
  invalidEmail,
  network,
  tooManyRequests,
  requiresRecentLogin,
  sessionExpired,
  googleFailed,
  appleFailed,

  /// Apple returned an address that already belongs to an account created with
  /// a different provider. Firebase refuses to sign in rather than silently
  /// merging the two, so the person is pointed back at the way in they already
  /// have — see [AuthCubit.signInWithApple].
  accountExistsWithOtherProvider,
  passwordRequired,
  notVerifiedYet,

  /// A throwaway inbox. Refused before the account is created — see
  /// [EmailRules].
  disposableEmail,

  /// A domain that can never receive mail (`.test`, `example.com`).
  unreachableEmail,

  // ── Notices ──
  resetLinkSent,
  verificationSent,
  profileUpdated,
  emailVerified,
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

/// Which button started the request. Both sign-in paths share one cubit, so
/// without this a tap on "Davom etish" spins the Google button too and the
/// person cannot tell which one they actually pressed. Named [AuthMethod]
/// rather than the obvious AuthProvider, which firebase_auth already exports.
enum AuthMethod { email, google, apple }

class AuthLoading extends AuthState {
  AuthLoading([this.method = AuthMethod.email]);

  final AuthMethod method;
}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.message);

  final AuthMessage message;
}

/// Neutral notice — a reset link went out, an address was confirmed. Shown in
/// the same place as an error but in the accent colour, never in red.
class AuthInfo extends AuthState {
  AuthInfo(this.message);

  final AuthMessage message;
}

class AuthDeleted extends AuthState {}
