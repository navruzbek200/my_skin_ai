import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/utils/crash_reporter.dart';
import 'package:real_beauty_ai/services/local_store.dart';

part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';

/// Single source of truth for "is someone signed in".
///
/// It owns no credentials of its own — it mirrors `authStateChanges()`, which
/// every sign-in path (Google, email/password) ultimately feeds. The router
/// guards read [state] instead of touching FirebaseAuth directly, so a redirect
/// re-runs the instant the session flips.
class AuthBloc extends Bloc<AuthEvent, AuthSessionState> {
  AuthBloc({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        // Seeded synchronously: after Firebase.initializeApp a persisted
        // session is already restored, so the first router redirect does not
        // have to flash the login screen while a stream event arrives.
        super(
          (firebaseAuth ?? FirebaseAuth.instance).currentUser == null
              ? const AuthUnauthenticated()
              : AuthAuthenticatedSession(
                  (firebaseAuth ?? FirebaseAuth.instance).currentUser!,
                ),
        ) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthRefreshRequested>(_onRefreshRequested);

    // userChanges() rather than authStateChanges(): confirming an address does
    // not change *who* is signed in, so the narrower stream stays silent and
    // the verify screen would never learn that the gate had lifted.
    _subscription = _auth.userChanges().listen(
          (user) => add(AuthUserChanged(user)),
        );
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _subscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthSessionState> emit) {
    final user = event.user;
    // This is the one place that sees every session change, so it is also the
    // one place that has to keep crash reports attributed to the right person.
    CrashReporter.setUser(user?.uid);
    emit(_stateFor(user));
  }

  /// The one place a [User] becomes a state.
  ///
  /// Both handlers go through here so the gate-marker cleanup cannot be done
  /// in one path and forgotten in the other — and the refresh path is exactly
  /// the one that sees the address turn verified, since the link is opened
  /// outside the app and no stream event follows it.
  AuthSessionState _stateFor(User? user) {
    if (user == null) return const AuthUnauthenticated();
    // Once the address is confirmed the account has passed the gate for good,
    // so the marker is retired rather than left to be re-read on every launch.
    if (user.emailVerified) {
      unawaited(LocalStore.instance.clearGatedSignup(user.uid));
    }
    return AuthAuthenticatedSession(user);
  }

  Future<void> _onRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthSessionState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      await user.reload();
    } catch (_) {
      // Offline or a transient Auth error — keep the state we already have and
      // let the next poll try again.
      return;
    }
    emit(_stateFor(_auth.currentUser));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
