import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/verify_email_page.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';

import '../../support/localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockAuth extends Mock implements FirebaseAuth {}

void main() {
  late _MockAuthCubit cubit;
  late AuthBloc bloc;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(AuthInitial());
    when(() => cubit.refreshVerification()).thenAnswer((_) async {});
    when(() => cubit.sendEmailVerification()).thenAnswer((_) async {});
    when(() => cubit.abandonUnverifiedAccount()).thenAnswer((_) async {});

    // The screen reads the address off AuthBloc and pokes it to re-read the
    // account, so the locator has to hold a real one.
    final auth = _MockAuth();
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.userChanges()).thenAnswer((_) => const Stream.empty());
    bloc = AuthBloc(firebaseAuth: auth);

    if (sl.isRegistered<AuthBloc>()) sl.unregister<AuthBloc>();
    sl.registerSingleton<AuthBloc>(bloc);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      localizedApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: cubit),
            // Provided as well as registered: the screen reads the address off
            // the bloc through `context.select`, exactly as `App` supplies it.
            BlocProvider<AuthBloc>.value(value: bloc),
          ],
          child: const VerifyEmailScreen(),
        ),
        locale: locale ?? const Locale('uz'),
      ),
    );
    await tester.pump();
  }

  testWidgets('offers the check, the resend and the way out', (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    expect(find.text(l10n.verifyTitle), findsOneWidget);
    expect(find.text(l10n.verifyCheck), findsOneWidget);
    expect(find.text(l10n.verifyUseAnother), findsOneWidget);
    // Explaining why this screen exists at all is what stops it reading as an
    // arbitrary obstacle between sign-up and the app.
    expect(find.text(l10n.verifyWhy), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the resend button opens held shut, and says for how long',
      (tester) async {
    await pump(tester);

    // A mail went out with the sign-up, so the first tap here would earn
    // `too-many-requests` rather than a second message.
    expect(find.text(AppLocalizationsUz().verifyResend), findsNothing);
    expect(find.textContaining('60'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('checking asks the server, it does not trust the cache',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(AppLocalizationsUz().verifyCheck));
    await tester.pump();

    // Nothing pushes the flag to the phone — the link is opened in a mail
    // client — so the account has to be re-read on demand.
    verify(() => cubit.refreshVerification()).called(greaterThanOrEqualTo(1));

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('starting over asks first, then deletes the record',
      (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    await tester.tap(find.text(l10n.verifyUseAnother));
    await tester.pumpAndSettle();

    expect(find.text(l10n.verifyStartOverTitle), findsOneWidget);
    await tester.tap(find.text(l10n.verifyStartOverConfirm));
    await tester.pumpAndSettle();

    // Deleting rather than signing out: left behind, the record holds an
    // address nobody can read and blocks it from ever being registered again.
    verify(() => cubit.abandonUnverifiedAccount()).called(1);
  });

  testWidgets('cancelling the start-over deletes nothing', (tester) async {
    final l10n = AppLocalizationsUz();
    await pump(tester);

    await tester.tap(find.text(l10n.verifyUseAnother));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.abandonUnverifiedAccount());
  });

  testWidgets('the screen speaks the chosen language', (tester) async {
    final ru = AppLocalizationsRu();
    await pump(tester, locale: const Locale('ru'));

    expect(find.text(ru.verifyTitle), findsOneWidget);
    expect(find.text(ru.verifyCheck), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });
}
