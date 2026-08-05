import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockAuth auth;
  late _MockUser user;
  // Flipped by reload() to mimic the link being clicked outside the app.
  late bool verified;

  setUp(() {
    auth = _MockAuth();
    user = _MockUser();
    verified = false;

    when(() => user.uid).thenReturn('uid-1');
    when(() => user.emailVerified).thenAnswer((_) => verified);
    when(() => user.reload()).thenAnswer((_) async => verified = true);
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
}
