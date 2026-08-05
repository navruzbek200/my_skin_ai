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
  });

  // ── Email login ──────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'login success → [Loading, Authenticated]',
    build: () {
      when(() => ds.signIn(any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.login('a@b.com', 'secret123'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
  );

  blocTest<AuthCubit, AuthState>(
    'login wrong password → [Loading, Error]',
    build: () {
      when(() => ds.signIn(any(), any()))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
      return AuthCubit(ds);
    },
    act: (c) => c.login('a@b.com', 'nope'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>().having((e) => e.message, 'msg', "Parol noto'g'ri"),
    ],
  );

  // ── Register ─────────────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'register success → [Loading, Authenticated]',
    build: () {
      when(() => ds.register(any(), any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.register('a@b.com', 'secret123'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
  );

  blocTest<AuthCubit, AuthState>(
    'register email already in use → [Loading, Error]',
    build: () {
      when(() => ds.register(any(), any(), any()))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      return AuthCubit(ds);
    },
    act: (c) => c.register('a@b.com', 'secret123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>().having(
        (e) => e.message,
        'msg',
        "Bu email allaqachon ro'yxatdan o'tgan",
      ),
    ],
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
