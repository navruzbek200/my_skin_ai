import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/utils/crash_reporter.dart';

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

    _subscription = _auth.authStateChanges().listen(
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
    emit(user == null
        ? const AuthUnauthenticated()
        : AuthAuthenticatedSession(user));
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
    final refreshed = _auth.currentUser;
    emit(refreshed == null
        ? const AuthUnauthenticated()
        : AuthAuthenticatedSession(refreshed));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
