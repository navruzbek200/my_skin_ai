import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/services/local_store.dart';

/// The app's language, as a single source of truth.
///
/// Its own cubit rather than a field on something else: the language is a
/// property of the app on this device, not of the account — it survives sign
/// out, it is chosen before anyone signs in, and `MaterialApp` has to rebuild
/// on it and on nothing else.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({Locale? deviceLocale}) : super(_initial(deviceLocale));

  /// A stored choice wins. Otherwise the device language is used when we speak
  /// it, and Uzbek is the fallback — this is a Tashkent app, so that is the
  /// likelier language for a phone set to something we do not translate.
  static Locale _initial(Locale? deviceLocale) {
    final stored = AppLanguage.fromCode(LocalStore.instance.localeCode);
    if (stored != null) return stored.locale;
    final device = AppLanguage.fromCode(deviceLocale?.languageCode);
    return (device ?? AppLanguage.uz).locale;
  }

  AppLanguage get language =>
      AppLanguage.fromCode(state.languageCode) ?? AppLanguage.uz;

  /// True once the person has picked a language themselves. The intro screen
  /// uses it to decide whether to nudge, rather than assuming the device
  /// guess was wrong.
  bool get isChosen => LocalStore.instance.localeCode != null;

  void setLanguage(AppLanguage language) {
    LocalStore.instance.saveLocaleCode(language.code);
    if (language.code == state.languageCode) return;
    emit(language.locale);
  }
}
