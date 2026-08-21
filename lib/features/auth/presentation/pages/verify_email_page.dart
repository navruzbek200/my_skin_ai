import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_message_text.dart';
import 'package:real_beauty_ai/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:real_beauty_ai/widgets/buttons.dart';

/// The wall between signing up and using the app.
///
/// Anyone can type an address they do not own — or one that does not exist —
/// and until this screen there was nothing stopping them: the account worked,
/// and the password-reset link went nowhere. Confirming the address is the only
/// check available without a backend, so it happens once, here.
///
/// Password accounts only, and only ones created after
/// [AuthSessionState.verificationRequiredFrom]. Google has already established
/// that the address is real, and older accounts are grandfathered — gating
/// those would be a lockout no client can undo.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  /// Firebase rate-limits verification mail. Four taps in a row earn
  /// `too-many-requests` instead of a message, so the button is held shut for a
  /// minute and says how long is left.
  static const _cooldownSeconds = 60;

  /// The link is followed in a mail client and nothing tells the app about it,
  /// so the account is re-read on a timer as well as on demand.
  static const _pollInterval = Duration(seconds: 5);

  Timer? _poll;
  Timer? _countdown;
  int _remaining = 0;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A verification mail went out with the sign-up, so the cooldown starts
    // spent and the first tap here is a genuine re-send.
    _startCooldown();
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  /// The link is opened in a mail client, which means the app is backgrounded
  /// at the moment it is clicked — polling through that window spends battery
  /// and Auth quota on a flag that provably cannot have changed yet. Coming
  /// back is the first moment it can have, so that is when we look.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check(silent: true);
      _startPolling();
      return;
    }
    _poll?.cancel();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(_pollInterval, (_) => _check(silent: true));
  }

  void _startCooldown() {
    setState(() => _remaining = _cooldownSeconds);
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _remaining--);
      if (_remaining <= 0) timer.cancel();
    });
  }

  /// [silent] is the background poll: it must not throw a red banner every five
  /// seconds at somebody who simply has not opened the link yet.
  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    if (!silent) setState(() => _checking = true);
    final auth = context.read<AuthCubit>();
    final l10n = context.l10n;
    await auth.refreshVerification();
    if (!mounted) return;
    if (!silent) setState(() => _checking = false);

    // The refresh only updates Firebase's cached user; the router watches
    // AuthBloc, so it has to be told to re-read before the gate can lift.
    sl<AuthBloc>().add(const AuthRefreshRequested());

    if (silent) return;
    // Nothing navigates from here: the router redirects into the app the
    // moment the session comes back confirmed.
    switch (auth.state) {
      case AuthError(:final message):
        showAuthSnack(context, message.text(l10n), isError: true);
      case AuthInfo(:final message):
        showAuthSnack(context, message.text(l10n), isError: false);
      default:
        break;
    }
  }

  Future<void> _resend() async {
    final l10n = context.l10n;
    final auth = context.read<AuthCubit>();
    await auth.sendEmailVerification();
    if (!mounted) return;
    switch (auth.state) {
      case AuthError(:final message):
        // Reported rather than swallowed: a rate-limited or offline retry that
        // says nothing leaves an empty inbox with no explanation, and the
        // person taps again into the same wall.
        showAuthSnack(context, message.text(l10n), isError: true);
      case AuthInfo(:final message):
        showAuthSnack(context, message.text(l10n), isError: false);
        _startCooldown();
      default:
        break;
    }
  }

  /// The way out of a mistyped address.
  ///
  /// Deletes rather than signs out: the record holds an address nobody can
  /// read, and left behind it both blocks that address for ever and adds an
  /// account nobody can reach. The skin profile and scan history live on the
  /// device and survive the new sign-up untouched.
  Future<void> _startOver() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(l10n.verifyStartOverTitle, style: AppText.h3),
        content: Text(l10n.verifyStartOverBody, style: AppText.bodyMuted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              minimumSize: const Size(0, AppTouch.min),
            ),
            child: Text(l10n.commonCancel,
                style: AppText.labelSm.copyWith(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              minimumSize: const Size(0, AppTouch.min),
            ),
            child: Text(l10n.verifyStartOverConfirm,
                style: AppText.labelSm.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthCubit>().abandonUnverifiedAccount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = context.select((AuthBloc b) => b.state.email);
    final waiting = _remaining > 0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const AuthBackdrop(),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                Center(
                  child: Semantics(
                    label: l10n.appName,
                    image: true,
                    child: Image.asset('assets/splash.png', height: 72),
                  ),
                ),
                const SizedBox(height: 28),
                const HaloIcon(icon: Icons.mark_email_read_outlined),
                const SizedBox(height: 22),
                Text(
                  l10n.verifyTitle,
                  textAlign: TextAlign.center,
                  style: AppText.display,
                ),
                const SizedBox(height: 10),
                // Only when there is an address to name: a sentence that opens
                // with an empty string reads as a bug.
                if (email.isNotEmpty) ...[
                  Text(
                    l10n.verifyBody(email),
                    textAlign: TextAlign.center,
                    style: AppText.bodyMuted,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  l10n.verifyHint,
                  textAlign: TextAlign.center,
                  style: AppText.caption,
                ),
                const SizedBox(height: 26),
                PrimaryPillButton(
                  label: l10n.verifyCheck,
                  isLoading: _checking,
                  icon: Icons.refresh_rounded,
                  onPressed: () => _check(),
                ),
                const SizedBox(height: 10),
                SecondaryPillButton(
                  label: waiting
                      ? l10n.authResendIn(_remaining)
                      : l10n.verifyResend,
                  icon: waiting ? null : Icons.send_outlined,
                  onPressed: waiting ? null : _resend,
                ),
                const SizedBox(height: 20),
                _WhyPanel(text: l10n.verifyWhy),
                const SizedBox(height: 6),
                // The quietest control on the screen and the furthest from
                // everything else: it is the one action here that throws work
                // away.
                TextButton(
                  onPressed: _startOver,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.muted,
                    minimumSize: const Size(0, AppTouch.min),
                  ),
                  child: Text(
                    l10n.verifyUseAnother,
                    style: AppText.labelSm.copyWith(color: AppColors.muted),
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

class _WhyPanel extends StatelessWidget {
  const _WhyPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.labelMuted)),
        ],
      ),
    );
  }
}
