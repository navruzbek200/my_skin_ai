import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/features/account/presentation/pages/account_page.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockAuth extends Mock implements FirebaseAuth {}

/// The account screen, and in particular the delete flow — the one action in
/// the app that cannot be undone, and the one that used to be able to report a
/// deletion that never happened.
void main() {
  late _MockAuthCubit cubit;
  late StreamController<AuthState> states;
  late AuthBloc bloc;
  final l10n = AppLocalizationsUz();

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await LocalStore.instance.init();

    cubit = _MockAuthCubit();
    states = StreamController<AuthState>.broadcast();
    whenListen(cubit, states.stream, initialState: AuthInitial());
    when(() => cubit.needsEmailVerification).thenReturn(false);
    when(() => cubit.isGoogleOnlyUser).thenReturn(false);
    when(() => cubit.isAppleOnlyUser).thenReturn(false);
    when(() => cubit.reauthenticateWithAppleAndDelete())
        .thenAnswer((_) async {});
    when(() => cubit.currentEmail).thenReturn('a@b.com');
    when(() => cubit.logout()).thenAnswer((_) async {});
    when(() => cubit.reauthenticateAndDelete(any())).thenAnswer((_) async {});
    when(() => cubit.sendPasswordReset(any())).thenAnswer((_) async {});
    when(() => cubit.sendEmailVerification()).thenAnswer((_) async {});

    final auth = _MockAuth();
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.userChanges()).thenAnswer((_) => const Stream.empty());
    bloc = AuthBloc(firebaseAuth: auth);
    if (sl.isRegistered<AuthBloc>()) sl.unregister<AuthBloc>();
    sl.registerSingleton<AuthBloc>(bloc);
  });

  tearDown(() async {
    await states.close();
    await GetIt.instance.reset();
  });

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      localizedApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: cubit),
            BlocProvider<AuthBloc>.value(value: bloc),
            BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
          ],
          child: const AccountScreen(),
        ),
        locale: locale ?? const Locale('uz'),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the delete confirmation and then the re-auth sheet behind it.
  Future<void> openDeleteSheet(WidgetTester tester) async {
    await tester.tap(find.text(l10n.accountDeleteAccount));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonDelete));
    await tester.pumpAndSettle();
  }

  // ── Layout ───────────────────────────────────────────────────────────

  testWidgets('the language row shows what the app is set to', (tester) async {
    await pump(tester);

    // A row that only says "Language" makes you open it to find out.
    expect(find.text(l10n.accountLanguage), findsOneWidget);
    expect(find.text(l10n.languageUz), findsOneWidget);
  });

  testWidgets('the language sheet names each language in its own language',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(l10n.accountLanguage));
    await tester.pumpAndSettle();

    expect(find.text(l10n.languageRu), findsOneWidget);
    expect(find.text(l10n.languageEn), findsOneWidget);
  });

  testWidgets('a confirmed address hides the verification nag', (tester) async {
    await pump(tester);
    expect(find.text(l10n.accountEmailUnverified), findsNothing);
  });

  testWidgets('an unconfirmed grandfathered account is offered the link',
      (tester) async {
    when(() => cubit.needsEmailVerification).thenReturn(true);
    await pump(tester);

    // These accounts predate the gate and are let in, so this card is the only
    // place confirming is offered — and a confirmed address is what makes a
    // forgotten password recoverable at all.
    expect(find.text(l10n.accountEmailUnverified), findsOneWidget);
    await tester.tap(find.text(l10n.accountSendLink));
    await tester.pump();
    verify(() => cubit.sendEmailVerification()).called(1);
  });

  // ── Sign out ─────────────────────────────────────────────────────────

  testWidgets('signing out asks first', (tester) async {
    await pump(tester);

    await tester.tap(find.text(l10n.accountSignOut));
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountSignOutTitle), findsOneWidget);
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();
    verifyNever(() => cubit.logout());
  });

  // ── Delete ───────────────────────────────────────────────────────────

  testWidgets('deleting asks first, and cancelling deletes nothing',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(l10n.accountDeleteAccount));
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountDeleteBody), findsOneWidget);
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();

    // No re-auth sheet, no delete.
    expect(find.text(l10n.accountConfirmIdentity), findsNothing);
    verifyNever(() => cubit.reauthenticateAndDelete(any()));
  });

  testWidgets('confirming opens the re-auth sheet rather than deleting',
      (tester) async {
    await pump(tester);
    await openDeleteSheet(tester);

    // Deletion is irreversible, so it has to be a freshly-confirmed action.
    expect(find.text(l10n.accountConfirmIdentity), findsOneWidget);
    expect(find.text(l10n.accountConfirmPasswordBody), findsOneWidget);
    verifyNever(() => cubit.reauthenticateAndDelete(any()));
  });

  testWidgets('an empty password is refused without touching the account',
      (tester) async {
    await pump(tester);
    await openDeleteSheet(tester);

    await tester.tap(find.text(l10n.accountConfirmDelete));
    await tester.pumpAndSettle();

    expect(find.text(l10n.authErrorPasswordRequired), findsOneWidget);
    verifyNever(() => cubit.reauthenticateAndDelete(any()));
  });

  testWidgets('a password reaches the cubit', (tester) async {
    await pump(tester);
    await openDeleteSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'secret123');
    await tester.tap(find.text(l10n.accountConfirmDelete));
    await tester.pump();

    verify(() => cubit.reauthenticateAndDelete('secret123')).called(1);
  });

  testWidgets('the sheet is not a dead end for a forgotten password',
      (tester) async {
    await pump(tester);
    await openDeleteSheet(tester);

    // Deletion needs the password, so somebody who has forgotten it would
    // otherwise have no way out of the account at all.
    await tester.tap(find.text(l10n.authForgotPassword));
    await tester.pump();
    verify(() => cubit.sendPasswordReset('a@b.com')).called(1);
  });

  testWidgets('a Google account confirms through the picker, not a password',
      (tester) async {
    when(() => cubit.isGoogleOnlyUser).thenReturn(true);
    when(() => cubit.reauthenticateWithGoogleAndDelete())
        .thenAnswer((_) async {});
    await pump(tester);
    await openDeleteSheet(tester);

    // No password field: a Google account has none of ours to check.
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text(l10n.accountConfirmGoogleBody), findsOneWidget);

    await tester.tap(find.text(l10n.accountConfirmDeleteGoogle));
    await tester.pump();
    verify(() => cubit.reauthenticateWithGoogleAndDelete()).called(1);
  });

  testWidgets('an Apple account confirms through the Apple sheet',
      (tester) async {
    when(() => cubit.isAppleOnlyUser).thenReturn(true);
    await pump(tester);
    await openDeleteSheet(tester);

    // No password field: an Apple account has none of ours to check.
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text(l10n.accountConfirmAppleBody), findsOneWidget);
    // And not the Google copy, which the sheet used to show for anyone
    // without a password.
    expect(find.text(l10n.accountConfirmGoogleBody), findsNothing);

    await tester.tap(find.text(l10n.accountConfirmDeleteApple));
    await tester.pump();
    verify(() => cubit.reauthenticateWithAppleAndDelete()).called(1);
    verifyNever(() => cubit.reauthenticateWithGoogleAndDelete());
  });

  testWidgets('a failed delete says why and keeps the sheet open',
      (tester) async {
    await pump(tester);
    await openDeleteSheet(tester);

    await tester.enterText(find.byType(TextFormField), 'nope');
    await tester.tap(find.text(l10n.accountConfirmDelete));
    await tester.pump();

    states.add(AuthError(AuthMessage.wrongPassword));
    await tester.pump();
    await tester.pump();

    // Reported in the field rather than swallowed — and the sheet stays put so
    // the password can be corrected without starting over.
    expect(find.text(l10n.authErrorWrongPassword), findsOneWidget);
    expect(find.text(l10n.accountConfirmIdentity), findsOneWidget);
  });

  // ── Language ─────────────────────────────────────────────────────────

  testWidgets('the whole screen follows the chosen language', (tester) async {
    final ru = AppLocalizationsRu();
    await pump(tester, locale: const Locale('ru'));

    expect(find.text(ru.accountTitle), findsOneWidget);
    expect(find.text(ru.accountSignOut), findsOneWidget);
    expect(find.text(ru.accountDeleteAccount), findsOneWidget);
  });
}
