import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/data/auth_data_source.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit([AuthDataSource? dataSource])
      : _ds = dataSource ?? FirebaseAuthDataSource(),
        super(AuthInitial());

  final AuthDataSource _ds;

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
    emit(AuthLoading());
    final address = email.trim();

    try {
      // No display name is collected — the account screen falls back to the
      // email address for the avatar initial and contact label.
      await _ds.register(address, password, null);
      // Deliberately outside the try that decides sign-up vs sign-in. The
      // account already exists and the user is already signed in by this
      // point, so a mail failure (rate limit, SMTP hiccup) must not be
      // reported as a failed sign-up — it would show an error over a session
      // that actually succeeded. A verified address only matters later, for
      // password recovery.
      unawaited(_trySendVerification());
      emit(AuthAuthenticated());
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        emit(AuthError(_mapError(e.code)));
        return;
      }
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
      return;
    }

    try {
      await _ds.signIn(address, password);
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      // Reaching here means the address is taken but the password did not
      // match it. The ordinary cause is a typo, but it is also exactly what a
      // Google-only account looks like — it has no password to match, and
      // enumeration protection means the codes are identical either way, so
      // the message has to cover both. Without the second sentence a Google
      // user is locked out for good: a reset link is never delivered to an
      // account that has no password provider.
      emit(AuthError(
        e.code == 'wrong-password' || e.code == 'invalid-credential'
            ? "Parol noto'g'ri. Agar Google orqali ro'yxatdan o'tgan bo'lsangiz, "
                "pastdagi Google tugmasi bilan kiring"
            : _mapError(e.code),
      ));
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
    }
  }

  /// Mails the verification link and swallows anything that goes wrong.
  /// Nothing downstream depends on it having arrived.
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
  /// Deleting rather than signing out matters: the record holds the wrong
  /// address, and left behind it both blocks that address forever and adds an
  /// account nobody can ever reach. The session is minutes old here, so
  /// `delete()` needs no re-authentication — but if it fails for any reason,
  /// sign out anyway. Stranding someone on a screen they cannot pass is worse
  /// than leaving one stale record on the server.
  Future<void> abandonUnverifiedAccount() async {
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
    emit(AuthInitial());
  }

  Future<void> deleteAccount() async {
    try {
      await _ds.deleteAccount();
    } on FirebaseAuthException catch (e) {
      // Any failure must stop here — signing the user out locally while the
      // Auth record still exists would report a deletion that never happened.
      emit(AuthError(e.code == 'requires-recent-login'
          ? "Akkauntni o'chirish uchun qayta kiring"
          : _mapError(e.code)));
      return;
    }
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
    emit(AuthLoading());
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
      AppLogger.info('Account deleted');
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Account deletion failed', e);
      emit(AuthError(_mapError(e.code)));
    } catch (e, st) {
      AppLogger.error('Account deletion failed', e, st);
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
    }
  }

  /// Google users re-authenticate through the picker instead of a password.
  Future<void> reauthenticateWithGoogleAndDelete() async {
    emit(AuthLoading(AuthMethod.google));
    try {
      final confirmed = await _ds.reauthenticateWithGoogle();
      if (!confirmed) {
        emit(AuthInitial());
        return;
      }
      await _ds.deleteAccount();
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
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
      final success = await _ds.signInWithGoogle();
      if (!success) {
        // User dismissed the account picker — not an error, just reset.
        emit(AuthInitial());
        return;
      }
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Google orqali kirishda xato yuz berdi"));
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
    try {
      await _ds.sendEmailVerification();
      emit(AuthInfo(
        "Tasdiqlash havolasi yuborildi (spam papkasini ham tekshiring)",
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _ds.sendPasswordReset(email.trim());
      emit(AuthInfo(
        "Parolni tiklash havolasi emailingizga yuborildi (spam papkasini ham tekshiring)",
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
    }
  }

  static String _mapError(String code) => switch (code) {
        'user-not-found' => 'Email topilmadi',
        'wrong-password' || 'invalid-credential' => "Parol noto'g'ri",
        'email-already-in-use' => "Bu email allaqachon ro'yxatdan o'tgan",
        'weak-password' => "Parol kamida 6 belgidan iborat bo'lishi kerak",
        'invalid-email' => "Email format noto'g'ri",
        'network-request-failed' => "Internet aloqasi yo'q",
        'too-many-requests' => "Ko'p urinish. Biroz kutib qaytib keling",
        'no-current-user' ||
        'user-token-expired' ||
        'invalid-user-token' =>
          "Sessiya tugadi. Ilovaga qaytadan kiring",
        _ => "Xato yuz berdi. Qaytadan urinib ko'ring",
      };
}
