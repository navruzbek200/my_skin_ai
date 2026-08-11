import 'package:flutter/foundation.dart';
import 'package:real_beauty_ai/core/utils/crash_reporter.dart';

/// Every log line in the app goes through here.
///
/// One funnel, two destinations, chosen by build mode: the console while you
/// are developing, Crashlytics once the app is on someone's phone. Call sites
/// never decide which — that is the whole point of the funnel, and it is why
/// `AppLogger.error` inside a `catch` block is enough to make a swallowed
/// failure visible in production instead of vanishing.
class AppLogger {
  const AppLogger._();

  static void info(String message, [Object? data]) {
    final line = '$message${data != null ? ' | $data' : ''}';
    if (kDebugMode) debugPrint('[INFO] $line');
    // A breadcrumb, not a report: on its own it means nothing, but attached to
    // a later crash it shows what the user had just done.
    CrashReporter.log(line);
  }

  static void warning(String message, [Object? data]) {
    final line = '$message${data != null ? ' | $data' : ''}';
    if (kDebugMode) debugPrint('[WARN] $line');
    CrashReporter.log('WARN $line');
  }

  /// A failure that was caught and handled. Reported anyway — code that falls
  /// back silently is exactly the code whose failure rate nobody knows.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message${error != null ? ' | $error' : ''}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    if (error != null) {
      CrashReporter.recordHandled(error, stackTrace, reason: message);
    } else {
      CrashReporter.log('ERROR $message');
    }
  }
}
