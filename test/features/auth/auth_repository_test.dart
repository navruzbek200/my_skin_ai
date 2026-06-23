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

  // ── login — success ──────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'login success → [Loading, Authenticated]',
    build: () {
      when(() => ds.signIn(any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.login('a@b.com', 'pass123'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
  );

  // ── login — empty fields ─────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'login empty fields → single AuthError, no Loading',
    build: () => AuthCubit(ds),
    act: (c) => c.login('', ''),
    expect: () => [
      isA<AuthError>()
          .having((e) => e.message, 'msg', "Email va parol to'ldiring"),
    ],
  );

  // ── login — FirebaseAuthException code mapping ────────────────────────

  final errorCases = {
    'wrong-password': "Parol noto'g'ri",
    'invalid-credential': "Parol noto'g'ri",
    'user-not-found': 'Email topilmadi',
    'email-already-in-use': "Bu email allaqachon ro'yxatdan o'tgan",
    'weak-password': "Parol kamida 6 belgidan iborat bo'lishi kerak",
    'invalid-email': "Email format noto'g'ri",
    'network-request-failed': "Internet aloqasi yo'q",
    'too-many-requests': "Ko'p urinish. Biroz kutib qaytib keling",
    'unknown-code': "Xato yuz berdi. Qaytadan urinib ko'ring",
  };

  for (final entry in errorCases.entries) {
    blocTest<AuthCubit, AuthState>(
      'login code="${entry.key}" → Uzbek message "${entry.value}"',
      build: () {
        when(() => ds.signIn(any(), any()))
            .thenThrow(FirebaseAuthException(code: entry.key));
        return AuthCubit(ds);
      },
      act: (c) => c.login('x@y.com', 'pass'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((e) => e.message, 'msg', entry.value),
      ],
    );
  }

  // ── logout — success ─────────────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'logout success → [AuthInitial]',
    build: () {
      when(() => ds.signOut()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.logout(),
    expect: () => [isA<AuthInitial>()],
  );

  // ── logout — signOut throws → local state still cleared ──────────────

  blocTest<AuthCubit, AuthState>(
    'logout when signOut throws → still emits AuthInitial',
    build: () {
      when(() => ds.signOut()).thenThrow(Exception('network'));
      return AuthCubit(ds);
    },
    act: (c) => c.logout(),
    expect: () => [isA<AuthInitial>()],
  );
}
