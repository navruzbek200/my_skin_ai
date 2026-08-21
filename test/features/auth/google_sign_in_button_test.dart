import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/l10n/app_localizations_en.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';
import 'package:real_beauty_ai/widgets/google_sign_in_button.dart';

import '../../support/localized_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockAuthCubit cubit;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(AuthInitial());
    when(() => cubit.signInWithGoogle()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: BlocProvider<AuthCubit>.value(
            value: cubit,
            child: const Center(child: GoogleSignInButton()),
          ),
        ),
        locale: locale ?? const Locale('uz'),
      ),
    );
    await tester.pump();
  }

  testWidgets('a tap starts the Google flow', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(GoogleSignInButton));
    await tester.pump();

    verify(() => cubit.signInWithGoogle()).called(1);
  });

  testWidgets('it spins for its own request', (tester) async {
    when(() => cubit.state).thenReturn(AuthLoading(AuthMethod.google));
    await pump(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('it does not spin for the email button, but is still disabled',
      (tester) async {
    when(() => cubit.state).thenReturn(AuthLoading(AuthMethod.email));
    await pump(tester);

    // Two spinners at once means the person cannot tell which button they
    // pressed — but a live Google button during an email request would race
    // two sign-ins, so it stays visible and refuses the tap.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(AppLocalizationsUz().authGoogleButton), findsOneWidget);

    await tester.tap(find.byType(GoogleSignInButton));
    await tester.pump();
    verifyNever(() => cubit.signInWithGoogle());
  });

  testWidgets('a tap is refused while its own request is in flight',
      (tester) async {
    when(() => cubit.state).thenReturn(AuthLoading(AuthMethod.google));
    await pump(tester);

    await tester.tap(find.byType(GoogleSignInButton));
    await tester.pump();

    verifyNever(() => cubit.signInWithGoogle());
  });

  testWidgets('the label follows the chosen language', (tester) async {
    await pump(tester, locale: const Locale('ru'));
    expect(find.text(AppLocalizationsRu().authGoogleButton), findsOneWidget);

    await pump(tester, locale: const Locale('en'));
    expect(find.text(AppLocalizationsEn().authGoogleButton), findsOneWidget);
  });

  testWidgets('the label never overflows, however long the translation',
      (tester) async {
    // "Войти через Google" at the largest allowed text size is wider than the
    // pill; an unconstrained Text overflows the row instead of shortening.
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pump(tester, locale: const Locale('ru'));

    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(
      find.text(AppLocalizationsRu().authGoogleButton),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
}
