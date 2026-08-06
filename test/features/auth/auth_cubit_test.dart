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
      isA<AuthError>().having((e) => e.message, 'msg', "Parol noto'g'ri"),
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
}
