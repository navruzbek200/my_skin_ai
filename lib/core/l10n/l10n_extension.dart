import 'package:flutter/widgets.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';

extension L10nExtension on BuildContext {
  /// Shorthand for the generated strings: `context.l10n.authContinue`.
  ///
  /// Non-null by configuration (`nullable-getter: false` in l10n.yaml) — the
  /// delegate is installed above every route, so a null here would be a wiring
  /// bug, not a state to handle at each call site.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
