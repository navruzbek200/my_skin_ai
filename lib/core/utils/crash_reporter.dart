import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// The app's one seam onto Crashlytics.
///
/// Nothing else in the codebase imports `firebase_crashlytics` directly. That
/// keeps the reporting backend swappable, but the real reason is safety: every
/// method here is total. A crash reporter that can itself throw turns a handled
/// error into an unhandled one, which is the exact opposite of its job, so each
/// call is wrapped and failures are swallowed.
///
/// Reporting is disabled in debug builds. Local runs would otherwise bury real
/// production crashes under noise from hot reloads and half-written code.
class CrashReporter {
  CrashReporter._();

  static bool _ready = false;

  /// Call once, after `Firebase.initializeApp`. Safe to skip — every other
  /// method degrades to a no-op until this succeeds.
  static Future<void> init() async {
    try {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      _ready = true;
    } catch (_) {
      // Play Services missing, or the console project has Crashlytics off.
      // The app must still start.
      _ready = false;
    }
  }

  /// A crash we did not catch — the app is going down.
  static Future<void> recordFatal(Object error, StackTrace stack) async {
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: true);
    } catch (_) {}
  }

  /// A caught error. The app carries on, but we still want to know it happened
  /// and how often — a failure that is handled everywhere is still a failure.
  static Future<void> recordHandled(
    Object error,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: false,
      );
    } catch (_) {}
  }

  /// Breadcrumb. These ship with the next crash report and are the difference
  /// between "it crashed in the routine screen" and knowing which step the user
  /// had just tapped.
  static void log(String message) {
    if (!_ready) return;
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  /// Ties reports to an account so a single user's repeated crash is visible as
  /// one story. The uid is already in Firebase's own logs; no email, no name.
  static Future<void> setUser(String? uid) async {
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
    } catch (_) {}
  }
}
