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

    // The screen's validator rejects these too; this is the guard for every
    // other way into the cubit — a test, a deep link, a future screen. An
    // address on a ten-minute inbox or a reserved domain can never receive the
    // confirmation link, so the account must not be created at all.
    if (EmailRules.isDisposable(address)) {
      emit(AuthError(AuthMessage.disposableEmail));
      return;
    }
    if (EmailRules.isUnreachable(address)) {
      emit(AuthError(AuthMessage.unreachableEmail));
      return;
    }
    if (!EmailRules.isWellFormed(address)) {
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
      // Deliberately outside the try that decides sign-up vs sign-in. The
      // account already exists and the user is already signed in by this
      // point, so a mail failure (rate limit, SMTP hiccup) must not be
      // reported as a failed sign-up — the verify screen has its own resend.
      unawaited(_trySendVerification());
      emit(AuthAuthenticated());
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        emit(AuthError(_mapError(e.code)));
        return;
      }
    } on TimeoutException {
      emit(AuthError(AuthMessage.timedOut));
      return;
    } catch (_) {
      emit(AuthError(AuthMessage.generic));
      return;
    }

    try {
      await _ds.signIn(address, password).timeout(_timeout);
      await LocalStore.instance.markHasAccount();
      emit(AuthAuthenticated());
    } on TimeoutException {
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
      emit(AuthError(wrongPassword
          ? AuthMessage.wrongPasswordOrGoogle
          : _mapError(e.code)));
    } catch (_) {
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Mails the verification link and swallows anything that goes wrong.
  /// Nothing downstream depends on it having arrived — the verify screen shows
  /// its own resend button, which does report failures.
  Future<void> _trySendVerification() async {
    try {
      await _ds.sendEmailVerification();
    } catch (e, st) {
      AppLogger.error('Verification email not sent', e, st);
    }
  }

  Future<void> logout() async {
    try {
      await _ds.signOut();
    } catch (e, st) {
      AppLogger.error('signOut failed', e, st);
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
    try {
      await _ds.deleteAccount();
    } catch (e, st) {
      AppLogger.error('Could not delete unverified account', e, st);
      try {
        await _ds.signOut();
      } catch (e, st) {
        AppLogger.error('signOut after failed delete', e, st);
      }
    }
    // The record is gone (or at least abandoned), so its gate marker would
    // otherwise sit on the device for ever.
    if (uid != null) await LocalStore.instance.clearGatedSignup(uid);
    emit(AuthInitial());
  }

  Future<void> deleteAccount() async {
    try {
      await _ds.deleteAccount();
    } on FirebaseAuthException catch (e) {
      // Any failure must stop here — signing the user out locally while the
      // Auth record still exists would report a deletion that never happened.
      emit(AuthError(e.code == 'requires-recent-login'
          ? AuthMessage.requiresRecentLogin
          : _mapError(e.code)));
      return;
    }
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

    try {
      try {
        await _ds.reauthenticate(password);
      } on FirebaseAuthException catch (e) {
        if (!_staleSessionCodes.contains(e.code) || email == null) rethrow;
        AppLogger.info('Delete: session stale, signing in to re-confirm');
        await _ds.signIn(email, password);
      }

      await _ds.deleteAccount();
      await LocalStore.instance.clearHasAccount();
      AppLogger.info('Account deleted');
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Account deletion failed', e);
      emit(AuthError(_mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('Account deletion failed', e, st);
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Google users re-authenticate through the picker instead of a password.
  Future<void> reauthenticateWithGoogleAndDelete() async {
    if (state is AuthLoading) return;
    emit(AuthLoading(AuthMethod.google));
    try {
      final confirmed = await _ds.reauthenticateWithGoogle();
      if (!confirmed) {
        emit(AuthInitial());
        return;
      }
      await _ds.deleteAccount();
      await LocalStore.instance.clearHasAccount();
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
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
    try {
      // No timeout: the call is blocked on the account picker, which the user
      // may sit in front of for as long as they like. Cutting it off after 25
      // seconds would cancel a sign-in that is going perfectly well.
      final success = await _ds.signInWithGoogle();
      if (!success) {
        // User dismissed the account picker — not an error, just reset.
        emit(AuthInitial());
        return;
      }
      await LocalStore.instance.markHasAccount();
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError(AuthMessage.googleFailed));
    }
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
    try {
      await _ds.sendEmailVerification().timeout(_timeout);
      emit(AuthInfo(AuthMessage.verificationSent));
    } on TimeoutException {
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
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
      emit(verified
          ? AuthInfo(AuthMessage.emailVerified)
          : AuthError(AuthMessage.notVerifiedYet));
    } on TimeoutException {
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
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
    try {
      await _ds.sendPasswordReset(address).timeout(_timeout);
      emit(AuthInfo(AuthMessage.resetLinkSent));
    } on TimeoutException {
      emit(AuthError(AuthMessage.timedOut));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError(AuthMessage.generic));
    }
  }

  /// Back to a clean slate, so a screen that showed an error does not show it
  /// again when it is next opened.
  void reset() => emit(AuthInitial());

  /// Firebase's error codes, narrowed to the ones this app can say something
  /// useful about. Anything else is a bug or an outage, and both read the same
  /// from the outside: try again.
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
