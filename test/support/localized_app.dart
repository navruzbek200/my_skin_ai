import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';

/// A `MaterialApp` with the localisation delegates installed.
///
/// Every screen now reads `context.l10n`, which throws without them — a bare
/// `MaterialApp(home: …)` in a test fails on the first `Text` it builds. The
/// locale defaults to Uzbek so existing expectations keep asserting on the
/// source copy; pass another to check a screen in that language.
Widget localizedApp(Widget home, {Locale locale = const Locale('uz')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLanguage.supportedLocales,
    home: home,
  );
}
