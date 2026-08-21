import 'dart:ui';

import 'package:real_beauty_ai/l10n/app_localizations.dart';

/// The three languages the app ships in.
///
/// A closed enum rather than a bare [Locale] because the set is fixed by what
/// is actually translated: anything outside it would resolve to the template
/// language at runtime and show Uzbek strings under a Russian label.
enum AppLanguage {
  uz('uz'),
  ru('ru'),
  en('en');

  const AppLanguage(this.code);

  /// ISO 639-1 code — also what is persisted and what [Locale] is built from.
  final String code;

  Locale get locale => Locale(code);

  static const List<Locale> supportedLocales = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
  ];

  /// Null for anything we do not translate, so callers can fall back rather
  /// than silently mislabel a locale.
  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }

  /// Each language named in itself — a picker that labels "Русский" as
  /// "Rus tili" is unreadable to the person who needs it most.
  String label(AppLocalizations l10n) => switch (this) {
        AppLanguage.uz => l10n.languageUz,
        AppLanguage.ru => l10n.languageRu,
        AppLanguage.en => l10n.languageEn,
      };

  /// Two letters for the compact selector on the intro screen, where there is
  /// no room for a full name.
  String get short => switch (this) {
        AppLanguage.uz => 'UZ',
        AppLanguage.ru => 'RU',
        AppLanguage.en => 'EN',
      };
}
