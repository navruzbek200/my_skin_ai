import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_message_text.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';
import 'package:real_beauty_ai/l10n/app_localizations_en.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';

/// Every [AuthMessage] has to say something in every language.
///
/// The switch in `AuthMessageText` is exhaustive, so the compiler already
/// catches a *missing* case. What it cannot catch is a case wired to an ARB key
/// that was never translated, or two different failures pointed at the same
/// sentence — which is how a wrong-password error ends up reading like a
/// network error.
void main() {
  final locales = <String, AppLocalizations>{
    'uz': AppLocalizationsUz(),
    'ru': AppLocalizationsRu(),
    'en': AppLocalizationsEn(),
  };

  for (final entry in locales.entries) {
    group(entry.key, () {
      final l10n = entry.value;

      test('every message resolves to a non-empty sentence', () {
        for (final message in AuthMessage.values) {
          final text = message.text(l10n);
          expect(text.trim(), isNotEmpty, reason: '$message is blank');
        }
      });

      test('no two failures share a sentence', () {
        // Notices are allowed to overlap in principle; failures are not — two
        // different causes reading identically is indistinguishable from a bug
        // to the person trying to get in.
        const notices = {
          AuthMessage.resetLinkSent,
          AuthMessage.verificationSent,
          AuthMessage.profileUpdated,
          AuthMessage.emailVerified,
        };
        final failures =
            AuthMessage.values.where((m) => !notices.contains(m)).toList();

        final seen = <String, AuthMessage>{};
        for (final message in failures) {
          final text = message.text(l10n);
          // weakPassword deliberately reuses the field validator's sentence so
          // a server rejection never contradicts the hint under the input.
          if (message == AuthMessage.weakPassword) continue;
          expect(
            seen.containsKey(text),
            isFalse,
            reason: '$message says the same as ${seen[text]}: "$text"',
          );
          seen[text] = message;
        }
      });

      test('the wrong-password-or-Google message names Google', () {
        // A Google-only account produces the same Firebase code as a mistyped
        // password. Without the second half of this sentence that user is
        // locked out for good — a reset link never reaches an account with no
        // password provider.
        final text = AuthMessage.wrongPasswordOrGoogle.text(l10n);
        expect(text.toLowerCase(), contains('google'));
        expect(text.length,
            greaterThan(AuthMessage.wrongPassword.text(l10n).length));
      });
    });
  }

  test('the three languages differ from one another', () {
    for (final message in AuthMessage.values) {
      final uz = message.text(locales['uz']!);
      final ru = message.text(locales['ru']!);
      final en = message.text(locales['en']!);
      expect({uz, ru, en}.length, 3,
          reason: '$message is not translated in all three: $uz / $ru / $en');
    }
  });
}
