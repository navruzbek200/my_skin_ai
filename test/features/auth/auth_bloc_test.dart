import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockMetadata extends Mock implements UserMetadata {}

/// One day either side of the cut-off, so the tests keep meaning the same
/// thing if the date is ever moved.
final _beforeCutOff =
    AuthSessionState.verificationRequiredFrom.subtract(const Duration(days: 1));
final _afterCutOff =
    AuthSessionState.verificationRequiredFrom.add(const Duration(days: 1));

void main() {
  late _MockAuth auth;
  late _MockUser user;
  late _MockMetadata metadata;
  // Flipped by reload() to mimic the link being clicked outside the app.
  late bool verified;

  setUp(() {
    auth = _MockAuth();
    user = _MockUser();
    metadata = _MockMetadata();
    verified = false;

    when(() => user.uid).thenReturn('uid-1');
    when(() => user.emailVerified).thenAnswer((_) => verified);
    when(() => user.reload()).thenAnswer((_) async => verified = true);
    when(() => metadata.creationTime).thenReturn(_afterCutOff);
    when(() => user.metadata).thenReturn(metadata);
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges()).thenAnswer((_) => const Stream.empty());
  });

  test('seeds an unverified session synchronously', () {
    final bloc = AuthBloc(firebaseAuth: auth);

    expect(bloc.state.isAuthenticated, isTrue);
    expect(bloc.state.isEmailVerified, isFalse);

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

  group('the verification gate', () {
    test('holds a sign-up made after the cut-off', () {
      final bloc = AuthBloc(firebaseAuth: auth);

      expect(bloc.state.needsVerificationGate, isTrue);

      bloc.close();
    });

    test('lets that sign-up through once the link is clicked', () async {
      final bloc = AuthBloc(firebaseAuth: auth);

      final next = bloc.stream.first;
      bloc.add(const AuthRefreshRequested());

      expect((await next).needsVerificationGate, isFalse);

      await bloc.close();
    });

    // These accounts were created when no verification step existed, so some
    // hold addresses their owner cannot read. Gating them is a lockout with no
    // way out, which is why the cut-off exists at all.
    test('never holds an account that predates it, verified or not', () {
      when(() => metadata.creationTime).thenReturn(_beforeCutOff);
      final bloc = AuthBloc(firebaseAuth: auth);

      expect(bloc.state.isEmailVerified, isFalse);
      expect(bloc.state.needsVerificationGate, isFalse);

      bloc.close();
    });

    // Should not happen, but being wrong in the direction of letting someone
    // in beats being wrong in the direction the client cannot undo.
    test('lets an account through when its creation time is missing', () {
      when(() => metadata.creationTime).thenReturn(null);
      final bloc = AuthBloc(firebaseAuth: auth);

      expect(bloc.state.needsVerificationGate, isFalse);

      bloc.close();
    });

    test('does not apply to a signed-out session', () {
      when(() => auth.currentUser).thenReturn(null);
      final bloc = AuthBloc(firebaseAuth: auth);

      expect(bloc.state.needsVerificationGate, isFalse);

      bloc.close();
    });
  });
}
