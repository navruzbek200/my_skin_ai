import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_page.dart';
// The concrete locale classes, so a test can name the exact sentence it
// expects instead of hard-coding a translation that would drift from the ARB.
import 'package:real_beauty_ai/l10n/app_localizations_en.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit cubit;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();
    cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(AuthInitial());
    when(() => cubit.hasAccountOnDevice).thenReturn(false);
  });

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      localizedApp(
        BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const AuthScreen(),
        ),
        locale: locale ?? const Locale('uz'),
      ),
    );
    await tester.pump();
  }

  // ── The validator, without a widget ──────────────────────────────────
  //
  // `validateEmail` takes the strings rather than a context precisely so it
  // can be checked like this — a validator runs inside `Form.validate()`,
  // where the field's context is not the screen's.

  group('validateEmail', () {
    final l10n = AppLocalizationsUz();

    test('an empty field asks for an address', () {
      expect(validateEmail('', l10n), l10n.authEmailRequired);
      expect(validateEmail(null, l10n), l10n.authEmailRequired);
    });

    test('a malformed address is refused', () {
      expect(validateEmail('nope', l10n), l10n.authEmailInvalid);
      expect(validateEmail('a@b', l10n), l10n.authEmailInvalid);
    });

    test('a throwaway inbox is refused with its own message', () {
      // Refused at the field rather than after sign-up: the account would
      // otherwise be created and the confirmation mail would land in an inbox
      // that expires in ten minutes.
      expect(
        validateEmail('x@mailinator.com', l10n),
        l10n.authErrorDisposableEmail,
      );
    });

    test('a domain that can never receive mail is refused', () {
      expect(
        validateEmail('x@example.com', l10n),
        l10n.authErrorEmailUnreachable,
      );
    });

    test('a real address passes', () {
      expect(validateEmail('ali@gmail.com', l10n), isNull);
      expect(validateEmail('  Ali@Gmail.com  ', l10n), isNull);
    });
  });

  // ── The screen ───────────────────────────────────────────────────────

  testWidgets('nothing is red before the first submit', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'nonsense');
    await tester.pump();

    // Validation stays off until the first submit, so the form does not turn
    // red under somebody still typing their address for the first time.
    expect(find.text(AppLocalizationsUz().authEmailInvalid), findsNothing);
  });

  testWidgets('a fake address is refused at the field, not at Firebase',
      (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    await tester.enterText(
        find.byType(TextFormField).first, 'x@mailinator.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pump();

    expect(find.text(l10n.authErrorDisposableEmail), findsOneWidget);
    verifyNever(() => cubit.continueWithEmail(any(), any()));
  });

  testWidgets('a short password is refused at the field', (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pump();

    expect(find.text(l10n.authPasswordTooShort), findsOneWidget);
    verifyNever(() => cubit.continueWithEmail(any(), any()));
  });

  testWidgets('a valid pair reaches the cubit once the address is confirmed',
      (tester) async {
    final l10n = AppLocalizationsUz();
    when(() => cubit.continueWithEmail(any(), any()))
        .thenAnswer((_) async {});
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.authConfirmSend));
    await tester.pumpAndSettle();

    verify(() => cubit.continueWithEmail('ali@gmail.com', 'secret123'))
        .called(1);
  });

  // ── The address confirmation ─────────────────────────────────────────
  //
  // The one class of mistake nothing else can catch: `ali7@gmail.com` typed as
  // `ali@gmail.com`. Both are valid, both pass every check, and only the person
  // typing knows which is theirs — so they are asked before the account exists,
  // not after the mail has already gone to a stranger.

  testWidgets('a first sign-up is shown the address before the account is made',
      (tester) async {
    final l10n = AppLocalizationsUz();
    when(() => cubit.continueWithEmail(any(), any()))
        .thenAnswer((_) async {});
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authConfirmTitle), findsOneWidget);
    // Scoped to the dialog: the field behind it holds the same string, and an
    // unscoped finder would pass on the text the person already typed.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('ali@gmail.com'),
      ),
      findsOneWidget,
    );
    verifyNever(() => cubit.continueWithEmail(any(), any()));
  });

  testWidgets('the address is shown exactly as it will be registered',
      (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    await tester.enterText(
        find.byType(TextFormField).first, '  Ali@Gmail.com  ');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pumpAndSettle();

    // Confirming an address that differs from the one Firebase stores would
    // defeat the point of showing it at all — the field still reads
    // '  Ali@Gmail.com  ', the dialog reads what will actually be registered.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('ali@gmail.com'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('backing out of the confirmation creates no account',
      (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.authConfirmEdit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authConfirmTitle), findsNothing);
    verifyNever(() => cubit.continueWithEmail(any(), any()));
    // Dropped back on the field with the address selected, so the fix is one
    // keystroke rather than a hunt for the cursor.
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .selection
          .textInside('ali@gmail.com'),
      'ali@gmail.com',
    );
  });

  testWidgets('a returning user is not asked to confirm anything',
      (tester) async {
    final l10n = AppLocalizationsUz();
    when(() => cubit.hasAccountOnDevice).thenReturn(true);
    when(() => cubit.continueWithEmail(any(), any()))
        .thenAnswer((_) async {});
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(l10n.authContinue));
    await tester.pumpAndSettle();

    // The address on this device has already proved it works. Confirming it on
    // every sign-in would be a tax, not a safeguard.
    expect(find.text(l10n.authConfirmTitle), findsNothing);
    verify(() => cubit.continueWithEmail('ali@gmail.com', 'secret123'))
        .called(1);
  });

  testWidgets('a misspelled provider is offered a correction, not a rejection',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmial.com');
    await tester.pump();

    // Offered rather than applied: the domain may be somebody's real employer,
    // and rewriting what they typed under their fingers is worse than a tap.
    expect(find.textContaining('ali@gmail.com'), findsOneWidget);
  });

  testWidgets('tapping the correction fills the field with it', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ali@gmial.com');
    await tester.pump();
    await tester.tap(find.textContaining('ali@gmail.com'));
    await tester.pump();

    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'ali@gmail.com',
    );
  });

  testWidgets('only the email button spins while email sign-in is in flight',
      (tester) async {
    when(() => cubit.state).thenReturn(AuthLoading(AuthMethod.email));
    await pump(tester);

    // One spinner, not two: the Google button stays a button so the person can
    // see which one they actually pressed.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('only the Google button spins while Google is in flight',
      (tester) async {
    when(() => cubit.state).thenReturn(AuthLoading(AuthMethod.google));
    await pump(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(AppLocalizationsUz().authContinue), findsOneWidget);
  });

  testWidgets('a returning user is greeted as one', (tester) async {
    when(() => cubit.hasAccountOnDevice).thenReturn(true);
    await pump(tester);

    final l10n = AppLocalizationsUz();
    expect(find.text(l10n.authWelcomeBack), findsOneWidget);
    expect(find.text(l10n.authWelcome), findsNothing);
  });

  // ── Language ─────────────────────────────────────────────────────────

  testWidgets('the whole screen follows the chosen language', (tester) async {
    await pump(tester, locale: const Locale('ru'));

    final ru = AppLocalizationsRu();
    expect(find.text(ru.authWelcome), findsOneWidget);
    expect(find.text(ru.authContinue), findsOneWidget);
    expect(find.text(ru.authForgotPassword), findsOneWidget);
    expect(find.text(ru.authGoogleButton), findsOneWidget);
  });

  testWidgets('and in English', (tester) async {
    await pump(tester, locale: const Locale('en'));

    final en = AppLocalizationsEn();
    expect(find.text(en.authWelcome), findsOneWidget);
    expect(find.text(en.authContinue), findsOneWidget);
  });

  testWidgets('a field error is spoken in the chosen language',
      (tester) async {
    final ru = AppLocalizationsRu();
    await pump(tester, locale: const Locale('ru'));

    await tester.enterText(
        find.byType(TextFormField).first, 'x@mailinator.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text(ru.authContinue));
    await tester.pump();

    expect(find.text(ru.authErrorDisposableEmail), findsOneWidget);
  });
}
