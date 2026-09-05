import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/features/auth/data/email_rules.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_message_text.dart';
import 'package:real_beauty_ai/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:real_beauty_ai/widgets/buttons.dart';

/// Two states in one screen: the form, and the confirmation that replaces it.
///
/// Deliberately not a snackbar over the form. Firebase will not say whether an
/// account exists, so "sent" is all we can ever report — and a message that
/// flashes for four seconds over a still-editable field leaves the person
/// wondering whether to press the button again.
///
/// Both states carry their own explanation. The screen used to be a heading, a
/// field and a button on an otherwise empty page, which is the layout that
/// makes somebody wonder whether they are in the right place: it asked for an
/// address without saying what it was about to do with it, and after sending
/// it said nothing about what to do next.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  /// The address the link actually went to. Non-null switches the screen to
  /// its second state — and naming the inbox is what stops somebody watching
  /// the wrong one.
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    // AuthCubit is app-wide, so it may still be holding the error from the
    // sign-in attempt that sent the user here. Clearing it stops that error
    // painting itself over this screen the moment it opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthCubit>().reset();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _send() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().sendPasswordReset(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final padding = MediaQuery.paddingOf(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent == false) return;
        if (state is AuthInfo) {
          setState(() => _sentTo = EmailRules.normalise(_emailCtrl.text));
        } else if (state is AuthError) {
          showAuthSnack(context, state.message.text(l10n), isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        // The backdrop below is the first thing in the body, and without this
        // the body starts *under* the app bar — leaving a white band across
        // the top with a hard edge where the gradient suddenly begins. The bar
        // is transparent, so it has nothing of its own to draw over.
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            // The system back label, so the control announces itself the way
            // every other back button on the phone does.
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.cta),
          ),
        ),
        body: Stack(
          children: [
            const AuthBackdrop(),
            SafeArea(
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                // Cross-faded rather than swapped: the two states share a
                // heading position and an icon, so a hard cut reads as the
                // screen flickering rather than as one step following another.
                child: AnimatedSwitcher(
                  duration: AppMotion.slow,
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  child: ListView(
                    key: ValueKey(_sentTo != null),
                    // The body runs behind the app bar now, so the content has
                    // to clear the back button itself — SafeArea only accounts
                    // for the status bar above it.
                    padding: EdgeInsets.fromLTRB(
                        24, kToolbarHeight + 8, 24, padding.bottom + 24),
                    children:
                        _sentTo == null ? _formBlock(context) : _sentBlock(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── State one: ask ──────────────────────────────────────────

  List<Widget> _formBlock(BuildContext context) {
    final l10n = context.l10n;
    return [
      const HaloIcon(icon: Icons.lock_reset_rounded, size: 84),
      const SizedBox(height: 18),
      Text(l10n.forgotTitle,
          textAlign: TextAlign.center, style: AppText.display),
      const SizedBox(height: 7),
      Text(
        l10n.forgotSubtitle,
        textAlign: TextAlign.center,
        // Same bump as the sign-in screen's subtitle: same AA-checked muted
        // colour, a step heavier so it reads as part of the heading block
        // rather than fading under it.
        style: AppText.bodyMuted.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 22),
      AuthField(
        label: l10n.commonEmail,
        icon: Icons.mail_outline_rounded,
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        // Deliberately not autofocused. The keyboard would cover the three
        // steps below on arrival, which are the whole reason this screen is
        // more than a field — somebody who lands here confused would be shown
        // the explanation and then have it hidden before they read it.
        validator: (v) {
          final value = v?.trim() ?? '';
          if (value.isEmpty) return l10n.authEmailRequired;
          // Checked here as well as in the cubit because a typo otherwise
          // costs a network round trip to come back as "invalid-email" — and
          // an address that is merely *wrong* rather than malformed comes back
          // as success, so the screen would cheerfully report a link sent to
          // nobody.
          if (!EmailRules.isWellFormed(value)) return l10n.authEmailInvalid;
          return null;
        },
        onFieldSubmitted: (_) => _send(),
      ),
      const SizedBox(height: 22),
      BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => PrimaryPillButton(
          label: l10n.forgotSend,
          icon: Icons.send_rounded,
          isLoading: state is AuthLoading,
          onPressed: state is AuthLoading ? null : _send,
        ),
      ),
      const SizedBox(height: 28),
      // The three steps are what turn a bare form into something somebody can
      // decide about: it says what the button is going to do before they press
      // it, which is the difference between asking for an address and taking
      // one.
      _StepList(
        title: l10n.forgotWhyTitle,
        steps: [l10n.forgotStep1, l10n.forgotStep2, l10n.forgotStep3],
      ),
      const SizedBox(height: 14),
      // The dead end this screen otherwise has: a Google account has no
      // password of ours, so no link will ever arrive however many times the
      // button is pressed.
      _QuietNote(icon: Icons.info_outline_rounded, text: l10n.forgotGoogleHint),
    ];
  }

  // ── State two: confirm ──────────────────────────────────────

  List<Widget> _sentBlock(BuildContext context) {
    final l10n = context.l10n;
    return [
      const SizedBox(height: 6),
      const HaloIcon(icon: Icons.mark_email_read_outlined, size: 84),
      const SizedBox(height: 18),
      Text(l10n.forgotSentTitle,
          textAlign: TextAlign.center, style: AppText.display),
      const SizedBox(height: 10),
      // Naming the inbox matters: somebody who mistyped it finds out here
      // rather than after ten minutes of watching the wrong one.
      Semantics(
        liveRegion: true,
        child: Text(
          l10n.forgotSentTo(_sentTo!),
          textAlign: TextAlign.center,
          style: AppText.bodySm.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.forgotSentBody,
        textAlign: TextAlign.center,
        style: AppText.bodyMuted,
      ),
      const SizedBox(height: 26),
      PrimaryPillButton(
        label: l10n.forgotBackToSignIn,
        onPressed: () => Navigator.pop(context),
      ),
      const SizedBox(height: 10),
      // The way out of a mistyped address, and of a mail that never arrives.
      // Without it the only recourse is to leave the screen and come back.
      BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) => SecondaryPillButton(
          label: l10n.forgotResend,
          icon: Icons.refresh_rounded,
          onPressed: state is AuthLoading
              ? null
              : () {
                  setState(() => _sentTo = null);
                  context.read<AuthCubit>().reset();
                },
        ),
      ),
      const SizedBox(height: 22),
      _QuietNote(
        icon: Icons.mark_email_unread_outlined,
        text: l10n.forgotNoEmailHint,
      ),
    ];
  }
}

/// A numbered list of what is about to happen.
///
/// Numbers rather than bullets because these are sequential — the second step
/// is not available until the first has produced a mail — and a bullet list
/// would suggest they can be done in any order.
class _StepList extends StatelessWidget {
  const _StepList({required this.title, required this.steps});

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.label),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.cta.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    // The number is decoration over the sentence beside it;
                    // reading "one" before the step itself is noise.
                    child: ExcludeSemantics(
                      child: Text(
                        '${i + 1}',
                        style: AppText.caption.copyWith(
                          color: AppColors.cta,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(steps[i], style: AppText.bodySm),
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

/// An aside — the thing worth knowing that is not worth interrupting for.
class _QuietNote extends StatelessWidget {
  const _QuietNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppText.labelMuted)),
      ],
    );
  }
}
