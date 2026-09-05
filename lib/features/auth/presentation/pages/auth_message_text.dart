import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';

/// The half of [AuthMessage] that knows about language.
///
/// Kept out of the cubit on purpose: the cubit decides *what* happened, this
/// decides how to say it. Adding a language means editing three ARB files and
/// nothing else — no auth logic is touched.
extension AuthMessageText on AuthMessage {
  String text(AppLocalizations l10n) => switch (this) {
        AuthMessage.generic => l10n.authErrorGeneric,
        AuthMessage.timedOut => l10n.authErrorTimeout,
        AuthMessage.userNotFound => l10n.authErrorUserNotFound,
        AuthMessage.wrongPassword => l10n.authErrorWrongPassword,
        AuthMessage.wrongPasswordOrGoogle =>
          l10n.authErrorWrongPasswordOrGoogle,
        AuthMessage.emailInUse => l10n.authErrorEmailInUse,
        // The same sentence the field validator shows, so a rejection from the
        // server never contradicts the hint under the input.
        AuthMessage.weakPassword => l10n.authPasswordTooShort,
        AuthMessage.invalidEmail => l10n.authErrorInvalidEmail,
        AuthMessage.network => l10n.authErrorNetwork,
        AuthMessage.tooManyRequests => l10n.authErrorTooManyRequests,
        AuthMessage.requiresRecentLogin => l10n.authErrorRequiresRecentLogin,
        AuthMessage.sessionExpired => l10n.authErrorSessionExpired,
        AuthMessage.googleFailed => l10n.authErrorGoogle,
        AuthMessage.appleFailed => l10n.authErrorApple,
        AuthMessage.accountExistsWithOtherProvider =>
          l10n.authErrorAccountExists,
        AuthMessage.passwordRequired => l10n.authErrorPasswordRequired,
        AuthMessage.notVerifiedYet => l10n.authErrorNotVerifiedYet,
        AuthMessage.disposableEmail => l10n.authErrorDisposableEmail,
        AuthMessage.unreachableEmail => l10n.authErrorEmailUnreachable,
        AuthMessage.resetLinkSent => l10n.authInfoResetSent,
        AuthMessage.verificationSent => l10n.authInfoVerificationSent,
        AuthMessage.profileUpdated => l10n.authInfoProfileUpdated,
        AuthMessage.emailVerified => l10n.authInfoEmailVerified,
      };
}
