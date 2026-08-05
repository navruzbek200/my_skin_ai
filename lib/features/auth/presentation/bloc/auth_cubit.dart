import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/data/auth_data_source.dart';
import 'package:real_beauty_ai/services/local_store.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit([AuthDataSource? dataSource])
      : _ds = dataSource ?? FirebaseAuthDataSource(),
        super(AuthInitial());

  final AuthDataSource _ds;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _ds.signIn(email.trim(), password);
      await LocalStore.instance.setLoggedIn();
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Kutilmagan xato. Qaytadan urinib ko'ring"));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      // No display name is collected at sign-up — the account screen falls
      // back to the email address for the avatar initial and contact label.
      await _ds.register(email.trim(), password, null);
      await LocalStore.instance.setLoggedIn();
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Ro'yxatdan o'tishda xato. Qaytadan urinib ko'ring"));
    }
  }

  Future<void> logout() async {
    try {
      await _ds.signOut();
    } catch (e, st) {
      AppLogger.error('signOut failed', e, st);
    }
    await LocalStore.instance.setLoggedOut();
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
    await LocalStore.instance.setLoggedOut();
    emit(AuthDeleted());
  }

  /// Re-authenticates with the account password, then deletes. A wrong password
  /// surfaces as [AuthError] and no deletion happens.
  Future<void> reauthenticateAndDelete(String password) async {
    emit(AuthLoading());
    try {
      await _ds.reauthenticate(password);
      await _ds.deleteAccount();
      await LocalStore.instance.setLoggedOut();
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
    }
  }

  /// Google users re-authenticate through the picker instead of a password.
  Future<void> reauthenticateWithGoogleAndDelete() async {
    emit(AuthLoading());
    try {
      final confirmed = await _ds.reauthenticateWithGoogle();
      if (!confirmed) {
        emit(AuthInitial());
        return;
      }
      await _ds.deleteAccount();
      await LocalStore.instance.setLoggedOut();
      emit(AuthDeleted());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Xato yuz berdi. Qaytadan urinib ko'ring"));
    }
  }

  /// True when the current user signed in via Google — they re-authenticate
  /// through the Google picker, not a password.
  bool get isGoogleOnlyUser {
    final providers =
        FirebaseAuth.instance.currentUser?.providerData.map((p) => p.providerId) ??
            const Iterable<String>.empty();
    return providers.contains('google.com') &&
        !providers.contains('password');
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final success = await _ds.signInWithGoogle();
      if (!success) {
        // User dismissed the account picker — not an error, just reset.
        emit(AuthInitial());
        return;
      }
      await LocalStore.instance.setLoggedIn();
      emit(AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
    } catch (_) {
      emit(AuthError("Google orqali kirishda xato yuz berdi"));
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
        _ => "Xato yuz berdi. Qaytadan urinib ko'ring",
      };
}
