import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';

import '../../support/localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit cubit;
  late StreamController<AuthState> states;
  final l10n = AppLocalizationsUz();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    cubit = _MockAuthCubit();
    // A controller rather than `Stream.value`: the confirmation tests have to
    // interact with the form *before* the send is reported, and a stream that
    // has already emitted replaces the form before the first tap lands.
    states = StreamController<AuthState>.broadcast();
    whenListen(cubit, states.stream, initialState: AuthInitial());
    when(() => cubit.reset()).thenReturn(null);
    when(() => cubit.sendPasswordReset(any())).thenAnswer((_) async {});
  });

  tearDown(() => states.close());

  /// Drives the screen to its second state the way the cubit would.
  Future<void> reportSent(WidgetTester tester) async {
    states.add(AuthInfo(AuthMessage.resetLinkSent));
    await tester.pumpAndSettle();
  }

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      localizedApp(
        BlocProvider<AuthCubit>.value(
          value: cubit,
          child: const ForgotPasswordScreen(),
        ),
        locale: locale ?? const Locale('uz'),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ── The form ─────────────────────────────────────────────────────────

  testWidgets('says what the button is about to do before it is pressed',
      (tester) async {
    await pump(tester);

    // The screen used to be a heading, a field and a button on an empty page.
    // These three lines are what make it a decision rather than a demand.
    expect(find.text(l10n.forgotWhyTitle), findsOneWidget);
    expect(find.text(l10n.forgotStep1), findsOneWidget);
    expect(find.text(l10n.forgotStep2), findsOneWidget);
    expect(find.text(l10n.forgotStep3), findsOneWidget);
  });

  testWidgets('warns the one person a reset link can never reach',
      (tester) async {
    await pump(tester);
    // Below the fold on a test-sized viewport, so the ListView has not built
    // it yet. Dragged rather than scrollUntilVisible, which needs a single
    // Scrollable and this screen has the switcher's outgoing child too.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    // A Google account has no password of ours, so no link will ever arrive
    // however many times the button is pressed.
    expect(find.text(l10n.forgotGoogleHint), findsOneWidget);
  });

  testWidgets('an empty field is refused without a network call',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(l10n.forgotSend));
    await tester.pump();

    expect(find.text(l10n.authEmailRequired), findsOneWidget);
    verifyNever(() => cubit.sendPasswordReset(any()));
  });

  testWidgets('a malformed address is refused without a network call',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField), 'nonsense');
    await tester.tap(find.text(l10n.forgotSend));
    await tester.pump();

    // A typo would otherwise cost a round trip to come back as
    // "invalid-email" — and an address that is merely wrong comes back as
    // success, so the screen would report a link sent to nobody.
    expect(find.text(l10n.authEmailInvalid), findsOneWidget);
    verifyNever(() => cubit.sendPasswordReset(any()));
  });

  testWidgets('nothing is red before the first submit', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField), 'nope');
    await tester.pump();

    expect(find.text(l10n.authEmailInvalid), findsNothing);
  });

  testWidgets('a valid address reaches the cubit', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField), 'ali@gmail.com');
    await tester.tap(find.text(l10n.forgotSend));
    await tester.pump();

    verify(() => cubit.sendPasswordReset('ali@gmail.com')).called(1);
  });

  testWidgets('the button is disabled while the request is in flight',
      (tester) async {
    await pump(tester);

    states.add(AuthLoading());
    // Two pumps: the first lets the stream event reach the BlocBuilder, the
    // second paints it. And pump, never pumpAndSettle — the spinner does not
    // stop, so settling never returns.
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── The confirmation ─────────────────────────────────────────────────

  testWidgets('a confirmed send replaces the form and names the inbox',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField), '  Ali@Gmail.com ');
    await tester.tap(find.text(l10n.forgotSend));
    await reportSent(tester);

    // Naming it matters: somebody who mistyped finds out here rather than
    // after ten minutes of watching the wrong inbox. Normalised, because that
    // is the address the mail actually went to.
    expect(find.text(l10n.forgotSentTo('ali@gmail.com')), findsOneWidget);
    expect(find.text(l10n.forgotSentTitle), findsOneWidget);
    // The form is gone — no second button to press and wonder about.
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('the confirmation offers a way back and a way to retry',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField), 'ali@gmail.com');
    await tester.tap(find.text(l10n.forgotSend));
    await reportSent(tester);

    expect(find.text(l10n.forgotBackToSignIn), findsOneWidget);
    expect(find.text(l10n.forgotResend), findsOneWidget);
    expect(find.text(l10n.forgotNoEmailHint), findsOneWidget);
  });

  testWidgets('resending returns to the form rather than dead-ending',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField), 'ali@gmail.com');
    await tester.tap(find.text(l10n.forgotSend));
    await reportSent(tester);

    await tester.tap(find.text(l10n.forgotResend));
    await tester.pumpAndSettle();

    // Back to an editable field — which is also the fix for a mistyped
    // address, and the only one this screen can offer.
    expect(find.byType(TextFormField), findsOneWidget);
  });

  // ── Language ─────────────────────────────────────────────────────────

  testWidgets('the whole screen follows the chosen language', (tester) async {
    final ru = AppLocalizationsRu();
    await pump(tester, locale: const Locale('ru'));

    expect(find.text(ru.forgotTitle), findsOneWidget);
    expect(find.text(ru.forgotSend), findsOneWidget);
    expect(find.text(ru.forgotWhyTitle), findsOneWidget);
    expect(find.text(ru.forgotStep1), findsOneWidget);
  });
}
