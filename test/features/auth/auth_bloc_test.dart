import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockMetadata extends Mock implements UserMetadata {}

class _MockProviderInfo extends Mock implements UserInfo {}

/// A provider entry as `providerData` returns it — 'password' for an email
/// sign-up, 'google.com' for a Google one.
///
/// Built outside any enclosing `when(...)`: mocktail refuses a stub declared
/// while it is recording another one, so this cannot be inlined into the
/// `providerData` stub's argument.
UserInfo _provider(String id) {
  final info = _MockProviderInfo();
  when(() => info.providerId).thenReturn(id);
  return info;
}

void main() {
  late _MockAuth auth;
  late _MockUser user;
  late _MockMetadata metadata;
  // Flipped by reload() to mimic the link being clicked outside the app.
  late bool verified;

  /// A day safely inside the gate's window, so `needsVerificationGate` is
  /// decided by the verification flag rather than by the cut-off.
  final afterCutoff =
      AuthSessionState.verificationRequiredFrom.add(const Duration(days: 1));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    auth = _MockAuth();
    user = _MockUser();
    metadata = _MockMetadata();
    verified = false;

    when(() => user.uid).thenReturn('uid-1');
    when(() => user.email).thenReturn('a@b.com');
    when(() => user.emailVerified).thenAnswer((_) => verified);
    when(() => user.reload()).thenAnswer((_) async => verified = true);
    final passwordProvider = [_provider('password')];
    when(() => user.providerData).thenReturn(passwordProvider);
    when(() => metadata.creationTime).thenReturn(afterCutoff);
    when(() => user.metadata).thenReturn(metadata);
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.userChanges()).thenAnswer((_) => const Stream.empty());
  });

  test('seeds an unverified session synchronously', () {
    final bloc = AuthBloc(firebaseAuth: auth);

    expect(bloc.state.isAuthenticated, isTrue);
    expect(bloc.state.isEmailVerified, isFalse);
    expect(bloc.state.email, 'a@b.com');

    bloc.close();
  });

  test('refresh emits a new state once the address is verified', () async {
    final bloc = AuthBloc(firebaseAuth: auth);

    final next = bloc.stream.first;
    bloc.add(const AuthRefreshRequested());

    final state = await next;
    expect(state.isEmailVerified, isTrue);

    await bloc.close();
  });

  test('refresh on a signed-out user emits unauthenticated', () async {
    when(() => auth.currentUser).thenReturn(null);
    final bloc = AuthBloc(firebaseAuth: auth);

    expect(bloc.state.isAuthenticated, isFalse);

    await bloc.close();
  });

  // ── The gate ────────────────────────────────────────────────────────
  //
  // What decides whether somebody is held on the verify screen. Every branch
  // here is a way into the app, so a mistake in any of them is either a hole
  // (an address nobody owns gets in) or a lockout nobody can undo from the
  // client.

  group('needsVerificationGate', () {
    test('an unconfirmed password sign-up made after the cut-off is gated', () {
      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isTrue);
      bloc.close();
    });

    test('a confirmed address is let straight through', () {
      verified = true;
      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isFalse);
      bloc.close();
    });

    test('a Google account is never gated', () {
      // Google established the address exists and there is no password of ours
      // for a link to protect, so there is nothing here to confirm.
      final googleProvider = [_provider('google.com')];
      when(() => user.providerData).thenReturn(googleProvider);
      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isFalse);
      bloc.close();
    });

    test('an account made before the cut-off is grandfathered in', () {
      // These were created when no verification step existed, so some of them
      // hold addresses their owner cannot read. Gating them is a lockout with
      // no way out.
      when(() => metadata.creationTime).thenReturn(
        AuthSessionState.verificationRequiredFrom
            .subtract(const Duration(days: 1)),
      );
      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isFalse);
      bloc.close();
    });

    test('a missing creation time fails open rather than shut', () {
      // Should not happen, but if it ever does, letting the person in is the
      // safe way to be wrong.
      when(() => metadata.creationTime).thenReturn(null);
      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isFalse);
      bloc.close();
    });

    test('nobody signed in is not gated', () {
      when(() => auth.currentUser).thenReturn(null);
      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isFalse);
      bloc.close();
    });

    test('a sign-up this build made is gated even before the cut-off',
        () async {
      // The cut-off sits a week ahead of the build so a staged rollout cannot
      // catch an old-build sign-up. Without this marker that would also leave
      // a week in which new sign-ups walked straight past the gate — which is
      // exactly the hole the gate exists to close.
      when(() => metadata.creationTime).thenReturn(
        AuthSessionState.verificationRequiredFrom
            .subtract(const Duration(days: 2)),
      );
      await LocalStore.instance.markGatedSignup('uid-1');

      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isTrue);
      await bloc.close();
    });

    test('the marker is per-account, not per-device', () async {
      // Signing out and into an older, grandfathered account on the same phone
      // must not drag that account into the gate.
      await LocalStore.instance.markGatedSignup('someone-else');
      when(() => metadata.creationTime).thenReturn(
        AuthSessionState.verificationRequiredFrom
            .subtract(const Duration(days: 2)),
      );

      final bloc = AuthBloc(firebaseAuth: auth);
      expect(bloc.state.needsVerificationGate, isFalse);
      await bloc.close();
    });

    test('confirming the address retires the marker', () async {
      await LocalStore.instance.markGatedSignup('uid-1');
      verified = true;

      final bloc = AuthBloc(firebaseAuth: auth);
      // The bloc drops it on the first state it sees a verified user in, so
      // it is not re-read on every launch for the rest of the install's life.
      bloc.add(const AuthRefreshRequested());
      await bloc.stream.first;
      await Future<void>.delayed(Duration.zero);

      expect(LocalStore.instance.isGatedSignup('uid-1'), isFalse);
      await bloc.close();
    });
  });
}
