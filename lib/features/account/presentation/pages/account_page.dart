import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:real_beauty_ai/core/constants/api_constants.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/l10n/language_picker.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_message_text.dart';
import 'package:real_beauty_ai/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:real_beauty_ai/widgets/buttons.dart';
import 'package:real_beauty_ai/logic/skin_copy.dart';

/// Four blocks, in the order somebody actually needs them: who you are, what
/// the app knows about your skin, the handful of settings that do something,
/// and — last, apart, and quiet — the two ways out of the account.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with WidgetsBindingObserver {
  /// Set while a confirmation mail this screen asked for is in flight.
  ///
  /// The cubit is app-wide, so its AuthInfo/AuthError also carry the reset link
  /// the delete sheet sends — and that sheet reports those itself. Only
  /// reacting to results this screen asked for keeps the two from answering
  /// each other's requests.
  bool _awaitingVerificationMail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Clicking the confirmation link happens in a mail client, and
  /// `userChanges()` does not fire for it — `emailVerified` changes on the Auth
  /// record and nowhere else. Coming back to the app is the only moment we can
  /// notice, so that is when we re-read it.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!context.read<AuthCubit>().needsEmailVerification) return;
    sl<AuthBloc>().add(const AuthRefreshRequested());
  }

  // ── Sign out ─────────────────────────────────────────────────

  Future<void> _confirmSignOut() async {
    final l10n = context.l10n;
    HapticFeedback.mediumImpact();
    final confirmed = await _confirm(
      context,
      title: l10n.accountSignOutTitle,
      body: l10n.accountSignOutBody,
      confirmLabel: l10n.accountSignOut,
      confirmColor: AppColors.cta,
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    // Via '/' rather than straight to '/auth': the auth-only guard reads
    // AuthBloc, which has not yet seen the sign-out this instant, so a direct
    // jump would be bounced back to '/home'. The splash resolves the
    // destination a frame later, by which time the bloc has caught up.
    context.go('/');
  }

  // ── Delete account ───────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    HapticFeedback.mediumImpact();
    final confirmed = await _confirm(
      context,
      title: l10n.accountDeleteAccount,
      body: l10n.accountDeleteBody,
      confirmLabel: l10n.commonDelete,
      confirmColor: AppColors.danger,
    );
    if (confirmed != true || !mounted) return;
    // Always re-authenticate first: deletion is destructive and irreversible,
    // so it has to be a deliberate, freshly-confirmed action.
    _showReAuthSheet();
  }

  Future<void> _clearAndExit() async {
    await LocalStore.instance.clearAllUserData();
    AppLogger.info('Account deleted — local data cleared');
    if (!mounted) return;
    showAuthSnack(context, context.l10n.accountDeletedNotice, isError: false);
    // Same reason as sign-out: '/intro' is guarded on stale bloc state, so go
    // through the splash, which resolves it a frame later.
    context.go('/');
  }

  void _showReAuthSheet() {
    final cubit = context.read<AuthCubit>();
    // Read here rather than inside the sheet: the sheet is built from a
    // different context, and by the time it is disposed the session may
    // already be gone.
    final method = cubit.isAppleOnlyUser
        ? _ReAuthMethod.apple
        : cubit.isGoogleOnlyUser
            ? _ReAuthMethod.google
            : _ReAuthMethod.password;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ReAuthSheet(method: method),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = LocalStore.instance.getSkinProfile();
    final padding = MediaQuery.paddingOf(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthDeleted) {
          _clearAndExit();
        } else if (_awaitingVerificationMail &&
            (state is AuthInfo || state is AuthError)) {
          _awaitingVerificationMail = false;
          showAuthSnack(
            context,
            state is AuthInfo
                ? state.message.text(l10n)
                : (state as AuthError).message.text(l10n),
            isError: state is AuthError,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ListView(
          padding: EdgeInsets.only(bottom: padding.bottom + 32),
          children: [
            _AccountHero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // A notice, not a gate. New sign-ups never reach this screen
                  // unverified — the router holds them on '/verify-email' —
                  // so the only accounts that see this card are the ones
                  // grandfathered in from before the gate shipped, for whom
                  // confirming is what makes a password reset possible at all.
                  BlocBuilder<AuthBloc, AuthSessionState>(
                    bloc: sl<AuthBloc>(),
                    builder: (context, _) {
                      if (!context.read<AuthCubit>().needsEmailVerification) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _UnverifiedEmailCard(
                          onResend: () {
                            _awaitingVerificationMail = true;
                            context.read<AuthCubit>().sendEmailVerification();
                          },
                        ),
                      );
                    },
                  ),
                  _SectionCard(
                    label: l10n.accountSkinProfile,
                    child: profile != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SkinTypeChip(
                                label: context.skinTypeLabel(
                                  profile.skinTypeCode,
                                  stored: profile.skinType,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.baseRecommendation(
                                  profile.skinTypeCode,
                                  stored: profile.baseRecommendation,
                                ),
                                style: AppText.bodyMuted,
                              ),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.refresh_rounded,
                                label: l10n.accountRetakeAnalysis,
                                onTap: () => context.push('/quiz'),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.accountNotAnalysed,
                                  style: AppText.bodyMuted),
                              const SizedBox(height: 8),
                              _ActionRow(
                                icon: Icons.face_retouching_natural_rounded,
                                label: l10n.accountStartAnalysis,
                                onTap: () => context.push('/quiz'),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    label: l10n.commonSettings,
                    child: Column(
                      children: [
                        _ActionRow(
                          icon: Icons.translate_rounded,
                          label: l10n.accountLanguage,
                          // The language a row *changes* is worth showing on
                          // the row: without it there is no way to tell what
                          // the app is set to without opening the sheet.
                          value: context.watch<LocaleCubit>().language
                              .label(l10n),
                          onTap: () => showLanguageSheet(context),
                        ),
                        const _RowDivider(),
                        _ActionRow(
                          icon: Icons.privacy_tip_outlined,
                          label: l10n.commonPrivacyPolicy,
                          onTap: () => launchUrl(
                            Uri.parse(privacyPolicyUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SecondaryPillButton(
                    label: l10n.accountSignOut,
                    icon: Icons.logout_rounded,
                    onPressed: _confirmSignOut,
                  ),
                  const SizedBox(height: 4),
                  // Deliberately the quietest control on the screen and the
                  // furthest from everything else: it is the one action here
                  // that cannot be undone.
                  TextButton(
                    onPressed: _confirmDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size(0, AppTouch.min),
                    ),
                    child: Text(
                      l10n.accountDeleteAccount,
                      style:
                          AppText.labelSm.copyWith(color: AppColors.danger),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.accountVersion(appVersion),
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The brand block at the top: avatar, address, and a way back.
///
/// The screen used to open with a "Hisob" title bar over a white card that
/// repeated it. The gradient says the same thing with the account in it, and
/// buys the rest of the screen a clear starting point.
class _AccountHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = context.select((AuthBloc b) => b.state.email);
    final initial = email.isEmpty ? '?' : email[0].toUpperCase();

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.paddingOf(context).top + 8, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.cta],
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Text(
                l10n.accountTitle,
                style: AppText.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  // The initial is decoration over the address that follows
                  // it — announcing "A" before reading the email out is noise.
                  child: ExcludeSemantics(
                    child: Text(
                      initial,
                      style: AppText.h1.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    email.isEmpty ? l10n.accountDefaultName : email,
                    style: AppText.bodySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinTypeChip extends StatelessWidget {
  const _SkinTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppText.labelSm.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// Confirmation for anything that cannot simply be tapped again.
Future<bool?> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required Color confirmColor,
}) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(title, style: AppText.h3),
      content: Text(body, style: AppText.bodyMuted),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.muted,
            minimumSize: const Size(0, AppTouch.min),
          ),
          child: Text(l10n.commonCancel,
              style: AppText.labelSm.copyWith(color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: confirmColor,
            minimumSize: const Size(0, AppTouch.min),
          ),
          child: Text(confirmLabel,
              style: AppText.labelSm.copyWith(color: confirmColor)),
        ),
      ],
    ),
  );
}

// ── Unverified email notice ───────────────────────────────────

class _UnverifiedEmailCard extends StatelessWidget {
  const _UnverifiedEmailCard({required this.onResend});

  final VoidCallback onResend;

  // Amber rather than red: nothing is broken and nothing is at risk — this is
  // a thing worth doing, not a thing gone wrong. Both inks are checked against
  // the card's own fill rather than against white.
  static const _fill = Color(0xFFFFF6E9);
  static const _line = Color(0xFFEED6AE);
  static const _ink = Color(0xFF7A5410); // 7.4:1 on _fill
  static const _inkSoft = Color(0xFF8A6524); // 5.6:1 on _fill

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_unread_outlined,
              size: 20, color: _ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountEmailUnverified,
                  style: AppText.bodySm
                      .copyWith(color: _ink, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.accountEmailUnverifiedBody,
                  style: AppText.labelMuted.copyWith(color: _inkSoft),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onResend,
                    style: TextButton.styleFrom(
                      foregroundColor: _ink,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, AppTouch.min),
                    ),
                    child: Text(
                      l10n.accountSendLink,
                      style: AppText.labelSm.copyWith(color: _ink),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Re-auth sheet ─────────────────────────────────────────────

/// How the person on this account proves it is theirs before it is deleted.
///
/// An account has exactly one of these: a password, or a provider that owns
/// the identity. Modelled as an enum rather than a pair of booleans so adding
/// Apple could not leave a `!isGoogleUser` branch quietly meaning "password"
/// when it now also means "Apple".
enum _ReAuthMethod { password, google, apple }

class _ReAuthSheet extends StatefulWidget {
  const _ReAuthSheet({required this.method});

  final _ReAuthMethod method;

  /// True when the sheet has no password field — the identity is proved by a
  /// system sheet instead.
  bool get isProviderUser => method != _ReAuthMethod.password;

  @override
  State<_ReAuthSheet> createState() => _ReAuthSheetState();
}

class _ReAuthSheetState extends State<_ReAuthSheet> {
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  /// Non-null once a reset link has been mailed. Switches the sheet to its
  /// second step, where the field means "the new password you just set".
  String? _resetSentTo;

  /// Address a reset link is currently being sent to. Promoted to
  /// [_resetSentTo] only when the cubit confirms the send.
  String? _pendingResetTo;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submitProvider() {
    setState(() {
      _loading = true;
      _error = null;
    });
    final cubit = context.read<AuthCubit>();
    switch (widget.method) {
      case _ReAuthMethod.google:
        cubit.reauthenticateWithGoogleAndDelete();
      case _ReAuthMethod.apple:
        // Also revokes the Apple token, which Apple requires on deletion —
        // see [AuthCubit.reauthenticateWithAppleAndDelete].
        cubit.reauthenticateWithAppleAndDelete();
      case _ReAuthMethod.password:
        // Unreachable: this branch has a field and goes through
        // _submitPassword. Kept exhaustive so a new method cannot be added
        // without deciding what it does here.
        break;
    }
  }

  /// Mails a reset link to the signed-in address and stays put.
  ///
  /// Closing the sheet here used to be the end of the road: the user set a new
  /// password in the browser, came back, and had to find their way to the
  /// delete screen all over again. Keeping the sheet open turns it into one
  /// continuous action — send link, set password elsewhere, return, confirm.
  void _sendReset() {
    final l10n = context.l10n;
    final cubit = context.read<AuthCubit>();
    final email = cubit.currentEmail;
    if (email == null || email.isEmpty) {
      setState(() => _error = l10n.accountNoEmail);
      return;
    }
    // Not switched to step two here: the send is asynchronous and can fail
    // (rate limit, no network). Announcing "link sent to X" before knowing
    // that would leave the user waiting on an email nobody mailed. The
    // listener below flips the step when AuthInfo confirms it went out.
    setState(() {
      _loading = true;
      _error = null;
      _pendingResetTo = email;
    });
    cubit.sendPasswordReset(email);
  }

  void _submitPassword() {
    final password = _passwordCtrl.text;
    if (password.isEmpty) {
      setState(() => _error = context.l10n.authErrorPasswordRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    context.read<AuthCubit>().reauthenticateAndDelete(password);
  }

  void _onPrimaryTap() =>
      widget.isProviderUser ? _submitProvider() : _submitPassword();

  /// Second step of the email flow: a reset link is out and we are waiting for
  /// the user to come back with the password they set through it.
  bool get _awaitingReset => _resetSentTo != null;

  String _subtitle(AppLocalizations l10n) {
    switch (widget.method) {
      case _ReAuthMethod.google:
        return l10n.accountConfirmGoogleBody;
      case _ReAuthMethod.apple:
        return l10n.accountConfirmAppleBody;
      case _ReAuthMethod.password:
        if (_awaitingReset) return l10n.accountResetSentBody(_resetSentTo!);
        return l10n.accountConfirmPasswordBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    final bottom = mq.viewInsets.bottom + mq.padding.bottom;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setState(() {
            _loading = false;
            _pendingResetTo = null;
            _error = state.message.text(l10n);
          });
        } else if (state is AuthInfo) {
          // The only AuthInfo this sheet can produce is "reset link sent".
          setState(() {
            _loading = false;
            _resetSentTo = _pendingResetTo ?? _resetSentTo;
            _pendingResetTo = null;
            _passwordCtrl.clear();
          });
        } else if (state is AuthInitial) {
          // The Google picker or the Apple sheet was dismissed — stop the
          // spinner, stay on this sheet.
          setState(() => _loading = false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: EdgeInsets.fromLTRB(24, 10, 24, bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.accountConfirmIdentity, style: AppText.h3),
              const SizedBox(height: 6),
              Text(_subtitle(l10n), style: AppText.bodyMuted),
              const SizedBox(height: 20),
              if (!widget.isProviderUser) ...[
                AuthField(
                  label: _awaitingReset
                      ? l10n.accountNewPassword
                      : l10n.commonPassword,
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordCtrl,
                  obscure: _obscure,
                  errorText: _error,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _loading ? null : _submitPassword(),
                  suffix: PasswordVisibilityToggle(
                    obscured: _obscure,
                    onToggle: () => setState(() => _obscure = !_obscure),
                    showLabel: l10n.authShowPassword,
                    hideLabel: l10n.authHidePassword,
                  ),
                ),
                // Without this the sheet is a dead end: deletion needs the
                // password, and someone who has forgotten it has no way out of
                // the account at all.
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _sendReset,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cta,
                      minimumSize: const Size(0, AppTouch.min),
                    ),
                    child: Text(
                      _awaitingReset
                          ? l10n.accountResendLink
                          : l10n.authForgotPassword,
                      style: AppText.labelSm.copyWith(color: AppColors.cta),
                    ),
                  ),
                ),
              ] else if (_error != null) ...[
                _InlineError(message: _error!),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              _DangerButton(
                label: switch (widget.method) {
                  _ReAuthMethod.google => l10n.accountConfirmDeleteGoogle,
                  _ReAuthMethod.apple => l10n.accountConfirmDeleteApple,
                  _ReAuthMethod.password => l10n.accountConfirmDelete,
                },
                isLoading: _loading,
                showGoogleMark: widget.method == _ReAuthMethod.google,
                onPressed: _loading ? null : _onPrimaryTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The error under the Google branch of the sheet, which has no field to hang
/// one off. Carries an icon as well as the colour — red alone is not a signal
/// somebody who cannot see it can act on.
class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 17, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppText.caption.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The delete confirmation button. Filled in the danger colour rather than the
/// brand one, because it is the only place in the app where the primary action
/// on the screen destroys something.
class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.showGoogleMark,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showGoogleMark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTouch.control,
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.danger,
          disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showGoogleMark) ...[
                    // On the red fill, Google's mark keeps its own colours per
                    // their guidelines — it sits inside a white disc rather
                    // than being recoloured to match the button.
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset('assets/icons/google.svg',
                          width: 16, height: 16),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppText.button,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: AppText.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border,
      );
}

// ── Action row ────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;

  /// The current setting, shown on the right of the row for anything that has
  /// one — a row that only says "Language" makes you open it to find out.
  final String? value;
  final VoidCallback onTap;

  void _activate() {
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    const tint = AppColors.text;
    return Semantics(
      button: true,
      label: value == null ? label : '$label, $value',
      // ExcludeSemantics below drops the InkWell's tap along with the icon and
      // the chevron, so the row has to declare the action itself.
      onTap: _activate,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: _activate,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            // 52 rather than the 40 this row used to be: it is the primary way
            // into every setting on the screen and was under the tap-target
            // floor on all of them.
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Icon(icon, size: 20, color: tint),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.bodySm.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null) ...[
                  Text(value!, style: AppText.labelMuted),
                  const SizedBox(width: 6),
                ],
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.inkFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
