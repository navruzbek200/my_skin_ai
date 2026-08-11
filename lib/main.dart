import 'dart:async';
// Narrow import: a bare `dart:ui` would pull in a second Brightness and Color
// alongside the ones material.dart already exports.
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:real_beauty_ai/app.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/utils/crash_reporter.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/firebase_options.dart';
import 'package:real_beauty_ai/services/local_store.dart';

void main() {
  // Everything runs inside the guarded zone so an async error thrown outside a
  // widget callback — a stray Future in a repository, a timer — still reaches
  // Crashlytics instead of being printed to a console nobody is watching.
  runZonedGuarded(_bootstrap, (error, stack) {
    AppLogger.error('Uncaught zone error', error, stack);
    CrashReporter.recordFatal(error, stack);
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The catalogue is 54 products in a 2-column grid. At the default 100MB the
  // cache cannot hold a full scroll, so coming back up re-decoded everything
  // and the cards blanked out one by one. Thumbnails are around 1MB decoded,
  // so 200MB covers the whole grid with room for the detail pages on top.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20;

  await _configureChrome();
  await _initFirebase();
  await _initLocalStore();

  configureDependencies();
  runApp(const App());
}

/// Orientation and system bars.
///
/// Failing here is cosmetic — a tilted status bar is not worth refusing to
/// start over — so it is logged and stepped past rather than rethrown.
Future<void> _configureChrome() async {
  try {
    // Portrait-only: face scan camera math and all layouts assume portrait.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Every screen is light, and from Android 15 the status bar is always
    // transparent over the app. Without this the system keeps its default
    // white icons, which are invisible on our backgrounds — the clock and
    // battery simply disappear.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  } catch (e, st) {
    AppLogger.error('System chrome setup failed', e, st);
  }
}

/// Firebase, Crashlytics and the Google Sign-In SDK.
///
/// A failure here costs the user sign-in and the remote catalogue, but the app
/// still works: the products screen falls back to its bundled list and the
/// router simply shows the sign-in screen. Starting degraded beats a phone
/// that shows a dead splash, so this is caught too.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await CrashReporter.init();
    _installErrorHandlers();
    await GoogleSignIn.instance.initialize();
    AppLogger.info('Firebase ready');
  } catch (e, st) {
    AppLogger.error('Firebase init failed — running degraded', e, st);
  }
}

/// SharedPreferences. Installed before anything reads it, because every read on
/// [LocalStore] assumes `init()` already completed.
Future<void> _initLocalStore() async {
  try {
    await LocalStore.instance.init();
  } catch (e, st) {
    AppLogger.error('LocalStore init failed', e, st);
  }
}

/// Routes framework and platform errors into Crashlytics.
///
/// Installed only after [CrashReporter.init] has run, so nothing reports into
/// an uninitialised backend.
void _installErrorHandlers() {
  final flutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    // Chain rather than replace: the default handler is what prints the red
    // error box and the console trace during development.
    flutterOnError?.call(details);
    CrashReporter.recordFatal(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  // Errors from the engine itself (platform channels, image decode) surface
  // here and nowhere else.
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught platform error', error, stack);
    CrashReporter.recordFatal(error, stack);
    return true;
  };
}
