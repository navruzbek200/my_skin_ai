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
          (e) => e.message, 'msg', AuthMessage.wrongPasswordOrGoogle),
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
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.weakPassword),
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
    expect: () => [isA<AuthLoading>(), isA<AuthInfo>()],
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
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.wrongPassword),
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
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.sessionExpired),
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

  // ── Addresses that must never reach Firebase ─────────────────────────
  //
  // The verification mail is the real check, but three kinds of address fail
  // it in ways we can see coming: a throwaway inbox that expires, a domain
  // reserved by RFC 2606 that can never receive anything, and a string that is
  // not an address at all. Each one, left to Firebase, produces an account
  // nobody can ever confirm or recover — so none of them may create one.

  blocTest<AuthCubit, AuthState>(
    'a disposable inbox is refused before an account exists',
    build: () => AuthCubit(ds),
    act: (c) => c.continueWithEmail('throwaway@mailinator.com', 'secret123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.disposableEmail),
    ],
    verify: (_) {
      verifyNever(() => ds.register(any(), any(), any()));
      verifyNever(() => ds.signIn(any(), any()));
    },
  );

  blocTest<AuthCubit, AuthState>(
    'a disposable subdomain is refused too',
    build: () => AuthCubit(ds),
    act: (c) => c.continueWithEmail('x@inbox.mailinator.com', 'secret123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.disposableEmail),
    ],
    verify: (_) => verifyNever(() => ds.register(any(), any(), any())),
  );

  blocTest<AuthCubit, AuthState>(
    'a reserved domain that can never receive mail is refused',
    build: () => AuthCubit(ds),
    act: (c) => c.continueWithEmail('someone@example.com', 'secret123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.unreachableEmail),
    ],
    verify: (_) => verifyNever(() => ds.register(any(), any(), any())),
  );

  blocTest<AuthCubit, AuthState>(
    'a malformed address never reaches Firebase',
    build: () => AuthCubit(ds),
    act: (c) => c.continueWithEmail('not-an-email', 'secret123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.invalidEmail),
    ],
    verify: (_) => verifyNever(() => ds.register(any(), any(), any())),
  );

  blocTest<AuthCubit, AuthState>(
    'a bare domain with no dot is refused — "a@localhost" is not reachable',
    build: () => AuthCubit(ds),
    act: (c) => c.continueWithEmail('a@localhost', 'secret123'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>(),
    ],
    verify: (_) => verifyNever(() => ds.register(any(), any(), any())),
  );

  blocTest<AuthCubit, AuthState>(
    'the address is folded to lower case before Firebase sees it',
    build: () {
      when(() => ds.register(any(), any(), any())).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    // Firebase stores addresses lower-cased anyway; normalising here is what
    // keeps "Ali@" and "ali@" from looking like two accounts in our own code.
    act: (c) => c.continueWithEmail('  Ali@Gmail.COM ', 'secret123'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    verify: (_) =>
        verify(() => ds.register('ali@gmail.com', 'secret123', null)).called(1),
  );

  blocTest<AuthCubit, AuthState>(
    'a second tap while a request is in flight is ignored',
    build: () {
      when(() => ds.register(any(), any(), any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      return AuthCubit(ds);
    },
    act: (c) {
      // Without the re-entry guard both calls see a free address and race each
      // other into two registrations, and both fail in ways that make no sense
      // to somebody who simply pressed "done" twice.
      c.continueWithEmail('a@b.com', 'secret123');
      c.continueWithEmail('a@b.com', 'secret123');
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    verify: (_) => verify(() => ds.register(any(), any(), any())).called(1),
  );

  // ── Which button is spinning ─────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'the loading state names the method that started it',
    build: () {
      when(() => ds.signInWithGoogle()).thenAnswer((_) async => true);
      return AuthCubit(ds);
    },
    act: (c) => c.signInWithGoogle(),
    expect: () => [
      // Both sign-in paths share one cubit, so without this a tap on
      // "Continue" spins the Google button too.
      isA<AuthLoading>().having((s) => s.method, 'method', AuthMethod.google),
      isA<AuthAuthenticated>(),
    ],
  );

  // ── Confirming the address ───────────────────────────────────────────

  blocTest<AuthCubit, AuthState>(
    'refreshVerification reports a still-unconfirmed address as a failure',
    build: () {
      when(() => ds.refreshEmailVerified()).thenAnswer((_) async => false);
      return AuthCubit(ds);
    },
    act: (c) => c.refreshVerification(),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.notVerifiedYet),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'refreshVerification reports a confirmed address as a notice',
    build: () {
      when(() => ds.refreshEmailVerified()).thenAnswer((_) async => true);
      return AuthCubit(ds);
    },
    act: (c) => c.refreshVerification(),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthInfo>()
          .having((e) => e.message, 'msg', AuthMessage.emailVerified),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'a resend that is rate-limited says so instead of failing silently',
    build: () {
      when(() => ds.sendEmailVerification())
          .thenThrow(FirebaseAuthException(code: 'too-many-requests'));
      return AuthCubit(ds);
    },
    act: (c) => c.sendEmailVerification(),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthError>()
          .having((e) => e.message, 'msg', AuthMessage.tooManyRequests),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'abandoning a mistyped sign-up deletes the record rather than signing out',
    build: () {
      when(() => ds.deleteAccount()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.abandonUnverifiedAccount(),
    expect: () => [isA<AuthInitial>()],
    verify: (_) {
      // Left behind, the record both holds an unreachable address for ever and
      // blocks that address from being registered again.
      verify(() => ds.deleteAccount()).called(1);
      verifyNever(() => ds.signOut());
    },
  );

  blocTest<AuthCubit, AuthState>(
    'abandoning still gets the user out when the delete fails',
    build: () {
      when(() => ds.deleteAccount())
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      when(() => ds.signOut()).thenAnswer((_) async {});
      return AuthCubit(ds);
    },
    act: (c) => c.abandonUnverifiedAccount(),
    expect: () => [isA<AuthInitial>()],
    verify: (_) {
      // Stranding somebody on a screen they cannot pass is worse than leaving
      // one stale record on the server.
      verify(() => ds.signOut()).called(1);
    },
  );

  // ── Returning-user copy ──────────────────────────────────────────────

  test('the device only remembers that someone signed in, never who', () async {
    when(() => ds.register(any(), any(), any())).thenAnswer((_) async {});
    final cubit = AuthCubit(ds);
    expect(cubit.hasAccountOnDevice, isFalse);

    await cubit.continueWithEmail('a@b.com', 'secret123');
    expect(cubit.hasAccountOnDevice, isTrue);
    // The address itself is deliberately not stored: on a shared phone an
    // email left in a prefilled field is somebody's identity on display.
    expect(
      SharedPreferences.getInstance().then((p) => p.getKeys()),
      completion(isNot(contains('last_email'))),
    );

    await cubit.close();
  });
}
