import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> withStore(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    await LocalStore.instance.init();
  }

  group('first run', () {
    test('follows the phone when we speak its language', () async {
      await withStore({});
      expect(
        LocaleCubit(deviceLocale: const Locale('ru')).state.languageCode,
        'ru',
      );
      expect(
        LocaleCubit(deviceLocale: const Locale('en')).state.languageCode,
        'en',
      );
    });

    test('falls back to Uzbek for a language we do not ship', () async {
      await withStore({});
      // This is a Tashkent app, so Uzbek is the likelier language for a phone
      // set to something we do not translate — not English.
      expect(
        LocaleCubit(deviceLocale: const Locale('de')).state.languageCode,
        'uz',
      );
      expect(LocaleCubit().state.languageCode, 'uz');
    });

    test('reports that nobody has chosen yet', () async {
      await withStore({});
      expect(LocaleCubit().isChosen, isFalse);
    });
  });

  group('a stored choice', () {
    test('wins over the device language', () async {
      await withStore({'locale_v1': 'en'});
      // Somebody who picked English on a Russian phone meant it.
      expect(
        LocaleCubit(deviceLocale: const Locale('ru')).state.languageCode,
        'en',
      );
    });

    test('survives into the next run', () async {
      await withStore({});
      LocaleCubit().setLanguage(AppLanguage.ru);
      expect(LocalStore.instance.localeCode, 'ru');

      // A fresh cubit over the same store is what the next cold start sees.
      expect(LocaleCubit().state.languageCode, 'ru');
      expect(LocaleCubit().isChosen, isTrue);
    });

    test('a corrupt or retired code is ignored, not shown', () async {
      await withStore({'locale_v1': 'kz'});
      // Resolving to the template language would show Uzbek strings under a
      // Kazakh label; falling back openly is the honest failure.
      expect(LocaleCubit().state.languageCode, 'uz');
    });
  });

  test('picking the language already on is not an emit', () async {
    await withStore({'locale_v1': 'uz'});
    final cubit = LocaleCubit();
    final emitted = <Locale>[];
    cubit.stream.listen(emitted.add);

    cubit.setLanguage(AppLanguage.uz);
    await Future<void>.delayed(Duration.zero);

    // MaterialApp rebuilds on this cubit and on nothing else, so a no-op
    // emit rebuilds the entire widget tree for nothing.
    expect(emitted, isEmpty);
    // The choice is still recorded, though — tapping the language you are
    // already reading is still a choice.
    expect(cubit.isChosen, isTrue);
  });

  test('but a real change is', () async {
    await withStore({});
    final cubit = LocaleCubit(deviceLocale: const Locale('uz'));
    final emitted = <Locale>[];
    cubit.stream.listen(emitted.add);

    cubit.setLanguage(AppLanguage.en);
    await Future<void>.delayed(Duration.zero);

    expect(emitted.map((l) => l.languageCode), ['en']);
  });

  group('AppLanguage', () {
    test('maps only the three codes we actually translate', () {
      expect(AppLanguage.fromCode('uz'), AppLanguage.uz);
      expect(AppLanguage.fromCode('ru'), AppLanguage.ru);
      expect(AppLanguage.fromCode('en'), AppLanguage.en);
      expect(AppLanguage.fromCode('de'), isNull);
      expect(AppLanguage.fromCode(null), isNull);
    });

    test('supportedLocales matches the enum, so neither can drift', () {
      expect(
        AppLanguage.supportedLocales.map((l) => l.languageCode),
        AppLanguage.values.map((v) => v.code),
      );
    });
  });
}
