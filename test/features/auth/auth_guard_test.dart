import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/core/router/app_router.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockMetadata extends Mock implements UserMetadata {}

class _MockProviderInfo extends Mock implements UserInfo {}

UserInfo _provider(String id) {
  final info = _MockProviderInfo();
  when(() => info.providerId).thenReturn(id);
  return info;
}

/// Calls the real guard from `app_router.dart` with a real session.
///
/// Deliberately not a copy of the logic: a mirrored guard drifts from the one
/// that ships, and the branch that drifts is the one that lets somebody into
/// the app they should not be in.
String? redirectFor(AuthSessionState session, String path) => authRedirect(
      loggedIn: session.isAuthenticated,
      gated: session.needsVerificationGate,
      path: path,
    );

void main() {
  late _MockAuth auth;
  late _MockUser user;
  late _MockMetadata metadata;
  late bool verified;

  final afterCutoff =
      AuthSessionState.verificationRequiredFrom.add(const Duration(days: 1));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    auth = _MockAuth();
    user = _MockUser();
    metadata = _MockMetadata();
    verified = false;

    final passwordProvider = [_provider('password')];
    when(() => user.uid).thenReturn('uid-1');
    when(() => user.email).thenReturn('a@b.com');
    when(() => user.emailVerified).thenAnswer((_) => verified);
    when(() => user.providerData).thenReturn(passwordProvider);
    when(() => metadata.creationTime).thenReturn(afterCutoff);
    when(() => user.metadata).thenReturn(metadata);
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.userChanges()).thenAnswer((_) => const Stream.empty());
  });

  AuthSessionState session() {
    final bloc = AuthBloc(firebaseAuth: auth);
    final state = bloc.state;
    bloc.close();
    return state;
  }

  group('signed out', () {
    setUp(() => when(() => auth.currentUser).thenReturn(null));

    test('every protected screen bounces to sign-in', () {
      final s = session();
      for (final path in [
        '/home', '/quiz', '/scan-instructions', '/face-scan',
        '/analysis', '/results', '/account',
      ]) {
        expect(redirectFor(s, path), '/auth', reason: path);
      }
    });

    test('the verify screen bounces too', () {
      // Otherwise a signed-out person can sit on a screen that polls an
      // account that is not there.
      expect(redirectFor(session(), '/verify-email'), '/auth');
    });

    test('the auth flow itself is left alone', () {
      expect(redirectFor(session(), '/auth'), isNull);
      expect(redirectFor(session(), '/intro'), isNull);
      expect(redirectFor(session(), '/forgot'), isNull);
    });
  });

  group('signed in but unconfirmed', () {
    test('every protected screen goes to the gate', () {
      final s = session();
      expect(s.needsVerificationGate, isTrue);
      for (final path in ['/home', '/quiz', '/account', '/results']) {
        expect(redirectFor(s, path), '/verify-email', reason: path);
      }
    });

    test('the gate itself is not a redirect loop', () {
      expect(redirectFor(session(), '/verify-email'), isNull);
    });

    test('going back to sign-in returns to the gate, not the app', () {
      // The account exists and is signed in, so '/auth' has nothing to offer —
      // but sending it to '/home' would walk straight past the gate.
      expect(redirectFor(session(), '/auth'), '/verify-email');
      expect(redirectFor(session(), '/intro'), '/verify-email');
    });
  });

  group('signed in and confirmed', () {
    setUp(() => verified = true);

    test('the app is open', () {
      final s = session();
      for (final path in ['/home', '/quiz', '/account']) {
        expect(redirectFor(s, path), isNull, reason: path);
      }
    });

    test('the gate is behind them', () {
      expect(redirectFor(session(), '/verify-email'), '/home');
    });

    test('the auth flow is behind them', () {
      expect(redirectFor(session(), '/auth'), '/home');
      expect(redirectFor(session(), '/intro'), '/home');
    });
  });

  group('a Google account', () {
    setUp(() {
      final googleProvider = [_provider('google.com')];
      when(() => user.providerData).thenReturn(googleProvider);
    });

    test('never sees the gate, even reported unverified', () {
      // Google established the address exists and there is no password of
      // ours for a link to protect.
      final s = session();
      expect(s.needsVerificationGate, isFalse);
      expect(redirectFor(s, '/home'), isNull);
      expect(redirectFor(s, '/verify-email'), '/home');
    });
  });

  group('an account from before the gate', () {
    setUp(() {
      when(() => metadata.creationTime).thenReturn(
        AuthSessionState.verificationRequiredFrom
            .subtract(const Duration(days: 1)),
      );
    });

    test('is let in rather than locked out', () {
      // These predate the verification step, so some hold addresses their
      // owner cannot read. Gating them is a lockout no client can undo.
      expect(redirectFor(session(), '/home'), isNull);
    });

    test('unless this build is the one that created it', () async {
      await LocalStore.instance.markGatedSignup('uid-1');
      expect(redirectFor(session(), '/home'), '/verify-email');
    });
  });
}
