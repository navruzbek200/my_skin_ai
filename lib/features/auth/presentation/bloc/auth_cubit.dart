import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/data/auth_data_source.dart';
import 'package:real_beauty_ai/features/auth/data/email_rules.dart';
import 'package:real_beauty_ai/services/local_store.dart';

part 'auth_state.dart';

/// Drives the sign-in screens. Session *state* lives in `AuthBloc`; this cubit
/// only models the attempt.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit([AuthDataSource? dataSource])
      : _ds = dataSource ?? FirebaseAuthDataSource(),
        super(AuthInitial());

  final AuthDataSource _ds;

  /// Ceiling on any single auth call.
  ///
  /// Firebase does not always fail fast — a stalled reCAPTCHA or App Check
  /// handshake can leave `createUserWithEmailAndPassword` pending for ever.
  /// Combined with the `state is AuthLoading` re-entry guards below, a hang
  /// like that leaves the button spinning with no way out of the screen. This
  /// turns an indefinite hang into an ordinary error the user can retry.
  static const _timeout = Duration(seconds: 25);

  /// True once anyone has signed in on this device, which is all the sign-in
  /// screen needs to greet a returning user with "welcome back". The address
  /// itself is deliberately not stored — see [LocalStore.hasAccount].
  bool get hasAccountOnDevice => LocalStore.instance.hasAccount;

  /// Signs in or signs up from the same pair of fields, so the user never has
  /// to answer "do you already have an account".
  ///
  /// Creating comes first because its failure is unambiguous:
  /// `email-already-in-use` means the address is taken and the password should
  /// be checked against it. The reverse order cannot work — with email
  /// enumeration protection a failed sign-in returns `invalid-credential`
  /// whether the account is missing or the password is simply wrong, so there
  /// would be no way to tell "sign me up" from "you typed it wrong".
  Future<void> continueWithEmail(String email, String password) async {
    // A second tap while the first request is in flight would register the
    // same address twice: the first call has not returned yet, so the second
    // still sees a free address and races it. Both then fail in ways that make
    // no sense to the person who simply pressed "done" on the keyboard twice.
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.email));
    final address = EmailRules.normalise(email);
    AppLogger.info('[Auth] continueWithEmail: trying register for $address');

    // The screen's validator rejects these too; this is the guard for every
    // other way into the cubit — a test, a deep link, a future screen. An
    // address on a ten-minute inbox or a reserved domain can never receive the
    // confirmation link, so the account must not be created at all.
    if (EmailRules.isDisposable(address)) {
      AppLogger.info('[Auth] continueWithEmail: rejected — disposable address');
      emit(AuthError(AuthMessage.disposableEmail));
      return;
    }
    if (EmailRules.isUnreachable(address)) {
      AppLogger.info('[Auth] continueWithEmail: rejected — unreachable domain');
      emit(AuthError(AuthMessage.unreachableEmail));
      return;
    }
    if (!EmailRules.isWellFormed(address)) {
      AppLogger.info('[Auth] continueWithEmail: rejected — malformed address');
      emit(AuthError(AuthMessage.invalidEmail));
      return;
    }

    try {
      // No display name is collected — the account screen falls back to the
      // email address for the avatar initial and contact label.
      await _ds.register(address, password, null).timeout(_timeout);
      await LocalStore.instance.markHasAccount();
      // Marks this account as one *this* build created, so the verification
      // gate holds it whatever its creation date says — see
      // [AuthSessionState.needsVerificationGate].
      final uid = _ds.currentUid;
      if (uid != null) await LocalStore.instance.markGatedSignup(uid);
      AppLogger.info('[Auth] continueWithEmail: register succeeded, uid=$uid');
      // Deliberately outside the try that decides sign-up vs sign-in. The
      // account already exists and the user is already signed in by this
      // point, so a mail failure (rate limit, SMTP hiccup) must not be
      // reported as a failed sign-up — the verify screen has its own resend.
      unawaited(_trySendVerification());
      emit(AuthAuthenticated());
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        AppLogger.info('[Auth] continueWithEmail: register failed (${e.code})');
        emit(AuthError(_mapError(e.code)));
        return;
      }
      AppLogger.info('[Auth] continueWithEmail: address exists, trying sign-in');
    } on TimeoutException {
      AppLogger.info('[Auth] continueWithEmail: register timed out');
      emit(AuthError(AuthMessage.timedOut));
      return;
    } catch (e, st) {
      AppLogger.error('[Auth] continueWithEmail: register threw unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
      return;
    }

    try {
      await _ds.signIn(address, password).timeout(_timeout);
      await LocalStore.instance.markHasAccount();
      AppLogger.info('[Auth] continueWithEmail: sign-in succeeded, uid=${_ds.currentUid}');
      emit(AuthAuthenticated());
    } on TimeoutException {
      AppLogger.info('[Auth] continueWithEmail: sign-in timed out');
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      // Reaching here means the address is taken but the password did not
      // match it. The ordinary cause is a typo, but it is also exactly what a
      // Google-only account looks like — it has no password to match, and
      // enumeration protection means the codes are identical either way, so
      // the message has to cover both. Without the second sentence a Google
      // user is locked out for good: a reset link is never delivered to an
      // account that has no password provider.
      final wrongPassword =
          e.code == 'wrong-password' || e.code == 'invalid-credential';
      AppLogger.info('[Auth] continueWithEmail: sign-in failed (${e.code})');
      emit(AuthError(wrongPassword
          ? AuthMessage.wrongPasswordOrGoogle
          : _mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('[Auth] continueWithEmail: sign-in threw unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Mails the verification link and swallows anything that goes wrong.
  /// Nothing downstream depends on it having arrived — the verify screen shows
  /// its own resend button, which does report failures.
  Future<void> _trySendVerification() async {
    try {
      await _ds.sendEmailVerification();
      AppLogger.info('[Auth] verification email sent');
    } catch (e, st) {
      AppLogger.error('[Auth] verification email not sent', e, st);
    }
  }

  Future<void> logout() async {
    AppLogger.info('[Auth] logout: signing out (was uid=${_ds.currentUid})');
    try {
      await _ds.signOut();
      AppLogger.info('[Auth] logout: signed out');
    } catch (e, st) {
      AppLogger.error('[Auth] logout: signOut failed', e, st);
    }
    emit(AuthInitial());
  }

  /// Throws away a sign-up whose address was mistyped, from the verify screen.
  ///
  /// Deleting rather than signing out matters: the record holds an address
  /// nobody can read, and left behind it both blocks that address for ever and
  /// adds an account nobody can reach. The session is minutes old here, so
  /// `delete()` needs no re-authentication — but if it fails for any reason,
  /// sign out anyway. Stranding someone on a screen they cannot pass is worse
  /// than leaving one stale record on the server.
  Future<void> abandonUnverifiedAccount() async {
    final uid = _ds.currentUid;
    AppLogger.info('[Auth] abandonUnverifiedAccount: deleting uid=$uid');
    try {
      await _ds.deleteAccount();
      AppLogger.info('[Auth] abandonUnverifiedAccount: deleted');
    } catch (e, st) {
      AppLogger.error('[Auth] abandonUnverifiedAccount: delete failed', e, st);
      try {
        await _ds.signOut();
      } catch (e, st) {
        AppLogger.error('[Auth] abandonUnverifiedAccount: signOut after failed delete', e, st);
      }
    }
    // The record is gone (or at least abandoned), so its gate marker would
    // otherwise sit on the device for ever.
    if (uid != null) await LocalStore.instance.clearGatedSignup(uid);
    emit(AuthInitial());
  }

  Future<void> deleteAccount() async {
    AppLogger.info('[Auth] deleteAccount: deleting uid=${_ds.currentUid}');
    try {
      await _ds.deleteAccount();
    } on FirebaseAuthException catch (e) {
      AppLogger.info('[Auth] deleteAccount: failed (${e.code})');
      // Any failure must stop here — signing the user out locally while the
      // Auth record still exists would report a deletion that never happened.
      emit(AuthError(e.code == 'requires-recent-login'
          ? AuthMessage.requiresRecentLogin
          : _mapError(e.code)));
      return;
    }
    AppLogger.info('[Auth] deleteAccount: deleted');
    await LocalStore.instance.clearHasAccount();
    emit(AuthDeleted());
  }

  /// Codes that all mean the same thing: the session we were going to
  /// re-authenticate is no longer usable. Completing a password reset produces
  /// this, because Firebase revokes the refresh token when the password
  /// changes — so the "I forgot it, send me a link" path lands here by design,
  /// not by accident.
  static const _staleSessionCodes = {
    'no-current-user',
    'user-token-expired',
    'invalid-user-token',
    'user-mismatch',
  };

  /// Email of the signed-in account. Read through the data source so nothing
  /// above this layer has to touch `FirebaseAuth.instance` — the account
  /// screen needs it to address the reset link.
  String? get currentEmail => _ds.currentEmail;

  /// Re-authenticates with the account password, then deletes. A wrong password
  /// surfaces as [AuthError] and no deletion happens.
  ///
  /// Accepts a freshly reset password too. Someone who forgot theirs sets a new
  /// one through the emailed link, which kills the session this method was
  /// going to re-authenticate; rather than dead-ending there, it signs in with
  /// the new password instead. That is the same proof of ownership by a
  /// different route, so nothing is weakened — and without it the one person
  /// who most needs to delete their account is the one who cannot.
  Future<void> reauthenticateAndDelete(String password) async {
    if (state is AuthLoading) return;
    if (password.isEmpty) {
      emit(AuthError(AuthMessage.passwordRequired));
      return;
    }
    emit(AuthLoading(AuthMethod.email));
    // Captured up front: the fallback below needs the address, and by the time
    // re-authentication has failed the session that carried it may be gone.
    final email = currentEmail;
    AppLogger.info('[Auth] reauthenticateAndDelete: re-authenticating $email');

    try {
      try {
        await _ds.reauthenticate(password);
        AppLogger.info('[Auth] reauthenticateAndDelete: re-auth ok');
      } on FirebaseAuthException catch (e) {
        if (!_staleSessionCodes.contains(e.code) || email == null) rethrow;
        AppLogger.info('[Auth] reauthenticateAndDelete: session stale (${e.code}), signing in to re-confirm');
        await _ds.signIn(email, password);
        AppLogger.info('[Auth] reauthenticateAndDelete: re-confirmed via sign-in');
      }

      await _ds.deleteAccount();
      await LocalStore.instance.clearHasAccount();
      AppLogger.info('[Auth] reauthenticateAndDelete: account deleted');
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] reauthenticateAndDelete: failed (${e.code})', e);
      emit(AuthError(_mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('[Auth] reauthenticateAndDelete: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Google users re-authenticate through the picker instead of a password.
  Future<void> reauthenticateWithGoogleAndDelete() async {
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.google));
    AppLogger.info('[Auth] reauthenticateWithGoogleAndDelete: opening picker');
    try {
      final confirmed = await _ds.reauthenticateWithGoogle();
      if (!confirmed) {
        AppLogger.info('[Auth] reauthenticateWithGoogleAndDelete: picker dismissed');
        emit(AuthInitial());
        return;
      }
      AppLogger.info('[Auth] reauthenticateWithGoogleAndDelete: re-auth ok, deleting');
      await _ds.deleteAccount();
      await LocalStore.instance.clearHasAccount();
      AppLogger.info('[Auth] reauthenticateWithGoogleAndDelete: account deleted');
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] reauthenticateWithGoogleAndDelete: failed (${e.code})', e);
      emit(AuthError(_mapProviderError(e.code, AuthMessage.googleFailed)));
    } catch (e, st) {
      AppLogger.error('[Auth] reauthenticateWithGoogleAndDelete: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// True when the current user signed in via Google — they re-authenticate
  /// through the Google picker, not a password.
  bool get isGoogleOnlyUser => _ds.isGoogleOnly;

  Future<void> signInWithGoogle() async {
    // Same reason as continueWithEmail: two pickers racing each other.
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.google));
    AppLogger.info('[Auth] signInWithGoogle: opening picker');
    try {
      // No timeout: the call is blocked on the account picker, which the user
      // may sit in front of for as long as they like. Cutting it off after 25
      // seconds would cancel a sign-in that is going perfectly well.
      final success = await _ds.signInWithGoogle();
      if (!success) {
        // User dismissed the account picker — not an error, just reset.
        AppLogger.info('[Auth] signInWithGoogle: picker dismissed');
        emit(AuthInitial());
        return;
      }
      await LocalStore.instance.markHasAccount();
      AppLogger.info('[Auth] signInWithGoogle: succeeded, uid=${_ds.currentUid}');
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] signInWithGoogle: failed (${e.code})', e);
      emit(AuthError(_mapProviderError(e.code, AuthMessage.googleFailed)));
    } catch (e, st) {
      AppLogger.error('[Auth] signInWithGoogle: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.googleFailed));
    }
  }

  // ── Sign in with Apple ────────────────────────────────────────

  /// Whether the Apple button should be built at all. Asked once by the sign-in
  /// screen: on Android and on anything below iOS 13 the answer is no, and an
  /// Apple button that cannot open a sheet is worse than no button.
  Future<bool> isAppleSignInAvailable() => _ds.isAppleSignInAvailable();

  /// True when the current user signed in via Apple — they re-authenticate
  /// through the Apple sheet, not a password.
  bool get isAppleOnlyUser => _ds.isAppleOnly;

  Future<void> signInWithApple() async {
    // Same reason as continueWithEmail: two sheets racing each other.
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.apple));
    AppLogger.info('[Auth] signInWithApple: opening sheet');
    try {
      // No timeout, for the same reason as Google: the call is blocked on a
      // system sheet the user may sit in front of for as long as they like.
      final success = await _ds.signInWithApple();
      if (!success) {
        // Sheet dismissed — a decision, not an error.
        AppLogger.info('[Auth] signInWithApple: sheet dismissed');
        emit(AuthInitial());
        return;
      }
      await LocalStore.instance.markHasAccount();
      AppLogger.info('[Auth] signInWithApple: succeeded, uid=${_ds.currentUid}');
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      // Only reachable when the person chose "Share My Email" *and* that
      // address already has a Google or password account. Firebase refuses to
      // merge them on its own, and linking here would mean proving ownership
      // of the other account first — which is exactly what signing in with it
      // is. So they are sent back to the door they already have a key to,
      // rather than left with "something went wrong".
      //
      // Choosing "Hide My Email" cannot land here at all: the relay address is
      // unique to this app, so it collides with nothing.
      AppLogger.error('[Auth] signInWithApple: FirebaseAuthException (${e.code})', e);
      if (e.code == 'account-exists-with-different-credential') {
        emit(AuthError(AuthMessage.accountExistsWithOtherProvider));
        return;
      }
      emit(AuthError(_mapProviderError(e.code, AuthMessage.appleFailed)));
    } catch (e, st) {
      // Reachable for a real Apple-side fault (missing entitlement, profile
      // without the capability) — see AuthorizationErrorCode.unknown in
      // FirebaseAuthDataSource.signInWithApple. This is the single most
      // useful line in this file for diagnosing "the button does nothing" —
      // e.toString() carries Apple's own error code.
      AppLogger.error('[Auth] signInWithApple: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.appleFailed));
    }
  }

  /// Apple users re-authenticate through the Apple sheet, then the app tells
  /// Apple to forget it before the record goes.
  ///
  /// The revocation is not optional politeness. App Store Review Guideline
  /// 5.1.1(v) requires an app offering Sign in with Apple to revoke the token
  /// when the account is deleted — otherwise the app keeps sitting in Settings
  /// → Apple ID → Sign in with Apple long after the account it belonged to has
  /// gone.
  Future<void> reauthenticateWithAppleAndDelete() async {
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.apple));
    AppLogger.info('[Auth] reauthenticateWithAppleAndDelete: opening sheet, uid=${_ds.currentUid}');
    try {
      final authorizationCode = await _ds.reauthenticateWithApple();
      if (authorizationCode == null) {
        // Sheet dismissed. Nothing has happened yet, so nothing to undo.
        AppLogger.info('[Auth] reauthenticateWithAppleAndDelete: sheet dismissed');
        emit(AuthInitial());
        return;
      }
      AppLogger.info('[Auth] reauthenticateWithAppleAndDelete: re-auth ok, revoking token');

      // Before delete(), deliberately: revoking needs a live session, and the
      // code expires within minutes. If it fails the deletion still goes ahead
      // — stranding somebody with an account they have asked twice to be rid
      // of is worse than leaving a stale entry in their Apple ID settings, and
      // that entry is something they can clear themselves.
      try {
        await _ds.revokeAppleToken(authorizationCode);
        AppLogger.info('[Auth] reauthenticateWithAppleAndDelete: token revoked — should now be gone from Settings → Apple Account → Sign in with Apple');
      } catch (e, st) {
        AppLogger.error('[Auth] reauthenticateWithAppleAndDelete: token revocation failed, deleting anyway', e, st);
      }

      await _ds.deleteAccount();
      await LocalStore.instance.clearHasAccount();
      await LocalStore.instance.clearAppleUserId();
      AppLogger.info('[Auth] reauthenticateWithAppleAndDelete: account deleted');
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] reauthenticateWithAppleAndDelete: failed (${e.code})', e);
      emit(AuthError(_mapProviderError(e.code, AuthMessage.appleFailed)));
    } catch (e, st) {
      AppLogger.error('[Auth] reauthenticateWithAppleAndDelete: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// True when the person has revoked this app in iOS Settings since they last
  /// opened it. Checked on resume by [App]; nothing is pushed to the device
  /// when a revocation happens, so it has to be asked for.
  Future<bool> isAppleCredentialRevoked() async {
    final revoked = await _ds.isAppleCredentialRevoked();
    AppLogger.info('[Auth] isAppleCredentialRevoked: $revoked');
    return revoked;
  }

  /// True when the account screen should offer to confirm the address.
  bool get needsEmailVerification => _ds.needsEmailVerification;

  /// Re-sends the confirmation link, from the verify screen or the account
  /// screen.
  ///
  /// Both callers exist because the gate only covers sign-ups made after
  /// [AuthSessionState.verificationRequiredFrom]. Older accounts are let
  /// straight in and reach this through the account-screen card, which is
  /// where someone thinking about their account will look — and a confirmed
  /// address is what makes a forgotten password recoverable at all.
  Future<void> sendEmailVerification() async {
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.email));
    AppLogger.info('[Auth] sendEmailVerification: sending to $currentEmail');
    try {
      await _ds.sendEmailVerification().timeout(_timeout);
      AppLogger.info('[Auth] sendEmailVerification: sent');
      emit(AuthInfo(AuthMessage.verificationSent));
    } on TimeoutException {
      AppLogger.info('[Auth] sendEmailVerification: timed out');
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] sendEmailVerification: failed (${e.code})', e);
      emit(AuthError(_mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('[Auth] sendEmailVerification: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Re-reads the account from Firebase after the link has been opened.
  ///
  /// Nothing pushes that change to the phone: the link is followed in a mail
  /// client or a browser, and the SDK keeps serving the cached user — which
  /// still says "unverified" — until someone asks it to reload.
  Future<void> refreshVerification() async {
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.email));
    try {
      final verified = await _ds.refreshEmailVerified().timeout(_timeout);
      AppLogger.info('[Auth] refreshVerification: emailVerified=$verified');
      emit(verified
          ? AuthInfo(AuthMessage.emailVerified)
          : AuthError(AuthMessage.notVerifiedYet));
    } on TimeoutException {
      AppLogger.info('[Auth] refreshVerification: timed out');
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] refreshVerification: failed (${e.code})', e);
      emit(AuthError(_mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('[Auth] refreshVerification: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (state is AuthLoading) return;
    final address = EmailRules.normalise(email);
    if (!EmailRules.isWellFormed(address)) {
      emit(AuthError(AuthMessage.invalidEmail));
      return;
    }
    emit(AuthLoading(AuthMethod.email));
    AppLogger.info('[Auth] sendPasswordReset: sending to $address');
    try {
      await _ds.sendPasswordReset(address).timeout(_timeout);
      AppLogger.info('[Auth] sendPasswordReset: sent');
      emit(AuthInfo(AuthMessage.resetLinkSent));
    } on TimeoutException {
      AppLogger.info('[Auth] sendPasswordReset: timed out');
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[Auth] sendPasswordReset: failed (${e.code})', e);
      emit(AuthError(_mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('[Auth] sendPasswordReset: failed unexpectedly', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Back to a clean slate, so a screen that showed an error does not show it
  /// again when it is next opened.
  void reset() => emit(AuthInitial());

  /// Firebase's error codes, narrowed to the ones this app can say something
  /// useful about. Anything else is a bug or an outage, and both read the same
  /// from the outside: try again.
  /// Same mapping, minus the assumption that a credential failure means a
  /// mistyped password.
  ///
  /// Firebase reports a rejected Apple or Google token as `invalid-credential`
  /// — the same code a wrong password produces. On a provider sign-in there is
  /// no password to be wrong, so [_mapError] would tell somebody to check one
  /// they never typed; the real cause is the token exchange itself failing,
  /// which is what [fallback] says.
  static AuthMessage _mapProviderError(String code, AuthMessage fallback) =>
      code == 'invalid-credential' ? fallback : _mapError(code);

  static AuthMessage _mapError(String code) => switch (code) {
        'user-not-found' => AuthMessage.userNotFound,
        'wrong-password' || 'invalid-credential' => AuthMessage.wrongPassword,
        'email-already-in-use' => AuthMessage.emailInUse,
        'weak-password' => AuthMessage.weakPassword,
        'invalid-email' => AuthMessage.invalidEmail,
        'network-request-failed' => AuthMessage.network,
        'too-many-requests' => AuthMessage.tooManyRequests,
        'requires-recent-login' => AuthMessage.requiresRecentLogin,
        'no-current-user' ||
        'user-token-expired' ||
        'invalid-user-token' =>
          AuthMessage.sessionExpired,
        _ => AuthMessage.generic,
      };
}
