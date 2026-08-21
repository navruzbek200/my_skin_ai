import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/l10n/language_picker.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language control, wired the way `App` wires it: a `LocaleCubit` above a
/// `MaterialApp` that rebuilds on it. Anything less would test the picker
/// without testing the thing the picker is for.
void main() {
  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
  });

  Widget app(LocaleCubit locale) {
    return BlocProvider<LocaleCubit>.value(
      value: locale,
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, currentLocale) => MaterialApp(
          locale: currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLanguage.supportedLocales,
          home: const _Probe(),
        ),
      ),
    );
  }

  testWidgets('picking a language repaints the screen in it', (tester) async {
    final locale = LocaleCubit(deviceLocale: const Locale('uz'));
    await tester.pumpWidget(app(locale));

    expect(find.text('Xush kelibsiz'), findsOneWidget);

    await tester.tap(find.text('RU'));
    await tester.pumpAndSettle();

    expect(find.text('Добро пожаловать'), findsOneWidget);
    expect(find.text('Xush kelibsiz'), findsNothing);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);

    await locale.close();
  });

  testWidgets('the choice is on disk before the next launch', (tester) async {
    final locale = LocaleCubit(deviceLocale: const Locale('uz'));
    await tester.pumpWidget(app(locale));

    await tester.tap(find.text('RU'));
    await tester.pumpAndSettle();

    // Written synchronously enough that a cold start moments later — which is
    // what a force-quit looks like — reads it back.
    expect(LocalStore.instance.localeCode, 'ru');
    expect(LocaleCubit().state.languageCode, 'ru');

    await locale.close();
  });

  testWidgets('the selected pill is announced as selected', (tester) async {
    final handle = tester.ensureSemantics();
    final locale = LocaleCubit(deviceLocale: const Locale('ru'));
    await tester.pumpWidget(app(locale));

    // The pill says "RU" but a screen reader is given the full name — two
    // letters would be spelled out or mispronounced.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Русский')),
      matchesSemantics(
        isButton: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasSelectedState: true,
        label: 'Русский',
        // The tap is the point: the pill sits inside an ExcludeSemantics, so
        // without an explicitly declared action a screen reader announces a
        // button it has no way to press.
        hasTapAction: true,
      ),
    );

    handle.dispose();
    await locale.close();
  });

  testWidgets('the sheet names each language in its own language',
      (tester) async {
    final locale = LocaleCubit(deviceLocale: const Locale('uz'));
    await tester.pumpWidget(app(locale));

    await tester.tap(find.text('open sheet'));
    await tester.pumpAndSettle();

    // A picker that labels "Русский" as "Rus tili" is unreadable to the person
    // who needs it most.
    expect(find.text("O'zbekcha"), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(LocalStore.instance.localeCode, 'en');

    await locale.close();
  });
}

/// Stands in for a real screen: one translated string, the segmented control
/// and a way into the sheet.
class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.authWelcome),
            const LanguageSegmentedControl(),
            TextButton(
              onPressed: () => showLanguageSheet(context),
              child: const Text('open sheet'),
            ),
          ],
        ),
      ),
    );
  }
}
