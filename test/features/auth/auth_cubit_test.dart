import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/data/auth_data_source.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDs extends Mock implements AuthDataSource {}

void main() {
  late _MockDs ds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    ds = _MockDs();
    // Every successful sign-up mails the verification link; stubbed here so
    // individual tests only declare the call they are actually about.
    when(() => ds.sendEmailVerification()).thenAnswer((_) async {});
    // The signed-in address. The delete flow reads it up front so it can fall
    // back to a sign-in when the session turns out to be stale.
    when(() => ds.currentEmail).thenReturn('a@b.com');
  });

  // ── One form for both sign-up and sign-in ────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'unknown address → account created and verification mailed',
    build: () {
      when(() => ds.register(any(), any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.continueWithEmail('a@b.com', 'secret123'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    verify: (_) {
      verify(() => ds.sendEmailVerification()).called(1);
      // Creating succeeded, so there was nothing to sign in to.
      verifyNever(() => ds.signIn(any(), any()));
    },
  );

  blocTest<AuthCubit, AuthState>(
    'known address with the right password → signed in, no second account',
    build: () {
      when(() => ds.register(any(), any(), any()))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      when(() => ds.signIn(any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.continueWithEmail('a@b.com', 'secret123'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    verify: (_) {
      verify(() => ds.signIn('a@b.com', 'secret123')).called(1);
      // The address was already verified by whoever registered it.
      verifyNever(() => ds.sendEmailVerification());
    },
  );

  blocTest<AuthCubit, AuthState>(
    'known address with the wrong password → error, not a new account',
    build: () {
      when(() => ds.register(any(), any(), any()))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      when(() => ds.signIn(any(), any()))
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      return AuthCubit(ds);
    },
    act: (c) => c.continueWithEmail('a@b.com', 'nope123'),
    expect: () => [
      isA<AuthLoading>(),
      // The message also has to cover a Google-only account, which produces
      // this exact code and cannot be told apart from a mistyped password.
      isA<AuthError>().having(
        (e) => e.message,
        'msg',
        allOf(
          startsWith("Parol noto'g'ri"),
          contains('Google'),
        ),
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'a real sign-up failure surfaces instead of falling through to sign-in',
    build: () {
      when(() => ds.register(any(), any(), any()))
          .thenThrow(FirebaseAuthException(code: 'weak-password'));
      return AuthCubit(ds);
    },
    act: (c) => c.continueWithEmail('a@b.com', '123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>().having(
        (e) => e.message,
        'msg',
        "Parol kamida 6 belgidan iborat bo'lishi kerak",
      ),
    ],
    verify: (_) {
      verifyNever(() => ds.signIn(any(), any()));
      verifyNever(() => ds.sendEmailVerification());
    },
  );

  // ── Google ───────────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'signInWithGoogle success → [Loading, Authenticated]',
    build: () {
      when(() => ds.signInWithGoogle()).thenAnswer((_) async => true);
      return AuthCubit(ds);
    },
    act: (c) => c.signInWithGoogle(),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
  );

  blocTest<AuthCubit, AuthState>(
    'signInWithGoogle cancelled → [Loading, Initial]',
    build: () {
      when(() => ds.signInWithGoogle()).thenAnswer((_) async => false);
      return AuthCubit(ds);
    },
    act: (c) => c.signInWithGoogle(),
    expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
  );

  // ── Password reset ───────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'sendPasswordReset success → [Info]',
    build: () {
      when(() => ds.sendPasswordReset(any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.sendPasswordReset('a@b.com'),
    expect: () => [isA<AuthInfo>()],
  );

  // ── Delete via password re-auth ──────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'reauthenticateAndDelete success → [Loading, Deleted]',
    build: () {
      when(() => ds.reauthenticate(any())).thenAnswer((_) async {});
      when(() => ds.deleteAccount()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.reauthenticateAndDelete('secret123'),
    expect: () => [isA<AuthLoading>(), isA<AuthDeleted>()],
    verify: (_) => verify(() => ds.deleteAccount()).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'reauthenticateAndDelete wrong password → [Loading, Error] and no delete',
    build: () {
      when(() => ds.reauthenticate(any()))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
      return AuthCubit(ds);
    },
    act: (c) => c.reauthenticateAndDelete('nope'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>().having((e) => e.message, 'msg', "Parol noto'g'ri"),
    ],
    verify: (_) => verifyNever(() => ds.deleteAccount()),
  );

  // ── Delete after a forgotten password ────────────────────────────────
  //
  // Completing a reset link revokes the refresh token, so by the time the
  // user comes back with their new password the session we would have
  // re-authenticated is gone. These pin the recovery path.

  blocTest<AuthCubit, AuthState>(
    'stale session → signs in with the new password, then deletes',
    build: () {
      when(() => ds.reauthenticate(any()))
          .thenThrow(FirebaseAuthException(code: 'no-current-user'));
      when(() => ds.signIn(any(), any())).thenAnswer((_) async {});
      when(() => ds.deleteAccount()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.reauthenticateAndDelete('brandNew123'),
    expect: () => [isA<AuthLoading>(), isA<AuthDeleted>()],
    verify: (_) {
      // The new password proved ownership through a fresh sign-in instead of
      // through a re-auth on a session that no longer exists.
      verify(() => ds.signIn('a@b.com', 'brandNew123')).called(1);
      verify(() => ds.deleteAccount()).called(1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'a stale session never reports a deletion that did not happen',
    build: () {
      // The regression this guards: reauthenticate() and deleteAccount() both
      // used to return quietly when there was no signed-in user, so the cubit
      // emitted AuthDeleted, the app wiped local data and told the user their
      // account was gone — while the Auth record sat untouched on the server.
      when(() => ds.currentEmail).thenReturn(null); // session already gone
      when(() => ds.reauthenticate(any()))
          .thenThrow(FirebaseAuthException(code: 'no-current-user'));
      when(() => ds.deleteAccount())
          .thenThrow(FirebaseAuthException(code: 'no-current-user'));
      return AuthCubit(ds);
    },
    act: (c) => c.reauthenticateAndDelete('whatever'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>().having(
        (e) => e.message,
        'msg',
        contains('Sessiya tugadi'),
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'delete still fails loudly when the fallback sign-in is refused',
    build: () {
      when(() => ds.reauthenticate(any()))
          .thenThrow(FirebaseAuthException(code: 'user-token-expired'));
      when(() => ds.signIn(any(), any()))
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      return AuthCubit(ds);
    },
    act: (c) => c.reauthenticateAndDelete('stillWrong'),
    expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    verify: (_) => verifyNever(() => ds.deleteAccount()),
  );

  // ── logout ───────────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'logout success → [Initial]',
    build: () {
      when(() => ds.signOut()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.logout(),
    expect: () => [isA<AuthInitial>()],
  );

  blocTest<AuthCubit, AuthState>(
    'logout when signOut throws → still emits Initial',
    build: () {
      when(() => ds.signOut()).thenThrow(Exception('network'));
      return AuthCubit(ds);
    },
    act: (c) => c.logout(),
    expect: () => [isA<AuthInitial>()],
  );

  // ── which button is loading ──────────────────────────────────────────

  // Both buttons read one shared cubit, so an untagged AuthLoading made the
  // Google button spin when someone pressed "Davom etish".
  blocTest<AuthCubit, AuthState>(
    'the email path claims the loading state for itself',
    build: () {
      when(() => ds.register(any(), any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.continueWithEmail('a@b.com', 'secret123'),
    expect: () => [
      isA<AuthLoading>().having((s) => s.method, 'method', AuthMethod.email),
      isA<AuthAuthenticated>(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'the Google path claims it instead',
    build: () {
      when(() => ds.signInWithGoogle()).thenAnswer((_) async => true);
      return AuthCubit(ds);
    },
    act: (c) => c.signInWithGoogle(),
    expect: () => [
      isA<AuthLoading>().having((s) => s.method, 'method', AuthMethod.google),
      isA<AuthAuthenticated>(),
    ],
  );

  // ── mistyped address at sign-up ──────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'abandoning a mistyped sign-up deletes it rather than leaving it behind',
    build: () {
      when(() => ds.deleteAccount()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.abandonUnverifiedAccount(),
    expect: () => [isA<AuthInitial>()],
    verify: (_) {
      verify(() => ds.deleteAccount()).called(1);
      // delete() ends the session on its own; a signOut on top would be noise.
      verifyNever(() => ds.signOut());
    },
  );

  blocTest<AuthCubit, AuthState>(
    'a failed delete still signs out — nobody is left stuck on the gate',
    build: () {
      when(() => ds.deleteAccount())
          .thenThrow(FirebaseAuthException(code: 'requires-recent-login'));
      when(() => ds.signOut()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.abandonUnverifiedAccount(),
    expect: () => [isA<AuthInitial>()],
    verify: (_) => verify(() => ds.signOut()).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'both calls failing still lands on Initial instead of hanging',
    build: () {
      when(() => ds.deleteAccount()).thenThrow(Exception('offline'));
      when(() => ds.signOut()).thenThrow(Exception('offline'));
      return AuthCubit(ds);
    },
    act: (c) => c.abandonUnverifiedAccount(),
    expect: () => [isA<AuthInitial>()],
  );
}
