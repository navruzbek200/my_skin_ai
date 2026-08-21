import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:real_beauty_ai/core/constants/api_constants.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/features/auth/data/email_rules.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_message_text.dart';
import 'package:real_beauty_ai/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';
import 'package:real_beauty_ai/widgets/buttons.dart';
import 'package:real_beauty_ai/widgets/google_sign_in_button.dart';

/// Takes the strings rather than a [BuildContext]: a validator runs inside
/// `Form.validate()`, where the context of the field is not the context of the
/// screen, and passing the looked-up strings in keeps this a pure function a
/// test can call directly.
String? validateEmail(String? value, AppLocalizations l10n) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return l10n.authEmailRequired;
  if (!EmailRules.isWellFormed(v)) return l10n.authEmailInvalid;
  // Both are rejected here rather than after sign-up. The account would
  // otherwise be created, the confirmation mail would go to an inbox that
  // expires — or to a domain that does not exist — and the person would be
  // holding an account they can never confirm and never recover.
  if (EmailRules.isDisposable(v)) return l10n.authErrorDisposableEmail;
  if (EmailRules.isUnreachable(v)) return l10n.authErrorEmailUnreachable;
  return null;
}

/// One screen, one form, no sign-in / sign-up switch.
///
/// Asking somebody whether they already have an account is a question about our
/// database, not about them — [AuthCubit.continueWithEmail] works it out from
/// the address instead.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _submitted = false;

  /// The corrected address offered under the field when the domain looks like a
  /// misspelling of one everybody uses. Never applied on its own — a domain
  /// that merely resembles a typo may well be someone's real employer.
  String? _suggestion;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final suggestion = EmailRules.suggestionFor(value);
    if (suggestion != _suggestion) setState(() => _suggestion = suggestion);
  }

  void _applySuggestion() {
    final fixed = _suggestion;
    if (fixed == null) return;
    _emailCtrl.text = fixed;
    _emailCtrl.selection = TextSelection.collapsed(offset: fixed.length);
    setState(() => _suggestion = null);
    _formKey.currentState?.validate();
  }

  Future<void> _submit() async {
    // Validation stays off until the first submit, so the form does not turn
    // red under somebody who is still typing their address for the first time.
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      // Announced rather than merely shown: without this the only signal that
      // nothing happened is a red line a screen-reader user never hears.
      SemanticsService.sendAnnouncement(
        View.of(context),
        context.l10n.authEmailInvalid,
        Directionality.of(context),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthCubit>();
    // Only on a device that has never signed anyone in — which is the sign-up
    // case in everything but name. A returning user is typing an address that
    // has already proved it works, and a confirmation step there would be a
    // tax on every single sign-in.
    if (!auth.hasAccountOnDevice) {
      final confirmed = await _confirmAddress();
      if (!mounted || confirmed != true) return;
    }
    auth.continueWithEmail(_emailCtrl.text, _passwordCtrl.text);
  }

  /// The last chance to catch a mistyped address, and the only one that costs
  /// nothing.
  ///
  /// Everything the client *can* check has already run: the format, the
  /// throwaway domains, the misspelt providers. None of that sees the half of
  /// an address that goes wrong most often — the part before the `@`, where
  /// `ali7@gmail.com` and `ali@gmail.com` are both perfectly valid and only one
  /// of them is yours. No lookup can tell them apart, so the person who knows
  /// is asked, once, before the account exists.
  ///
  /// Asking here rather than on the verify screen is the whole point: after
  /// sign-up the address is already taken on the server, the mail is already
  /// gone to a stranger, and undoing it means deleting an account. Before
  /// sign-up it costs one tap.
  Future<bool?> _confirmAddress() {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(l10n.authConfirmTitle, style: AppText.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The address is the thing being checked, so it is the loudest
            // thing in the dialog — set apart from the prose, not buried in a
            // sentence somebody will skim past.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                EmailRules.normalise(_emailCtrl.text),
                textAlign: TextAlign.center,
                style: AppText.h3,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.authConfirmBody, style: AppText.bodyMuted),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              minimumSize: const Size(0, AppTouch.min),
            ),
            child: Text(l10n.authConfirmEdit,
                style: AppText.labelSm.copyWith(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cta,
              minimumSize: const Size(0, AppTouch.min),
            ),
            child: Text(l10n.authConfirmSend,
                style: AppText.labelSm.copyWith(color: AppColors.cta)),
          ),
        ],
      ),
    ).whenComplete(() {
      // Dismissing to fix a typo should land the cursor where the typo is,
      // rather than making somebody hunt for the field they were just shown.
      if (!mounted) return;
      _emailFocus.requestFocus();
      _emailCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _emailCtrl.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final padding = MediaQuery.paddingOf(context);
    // Somebody who has signed in on this phone before is not being introduced
    // to the app, they are coming back to it — see [LocalStore.hasAccount].
    final returning = context.read<AuthCubit>().hasAccountOnDevice;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // AuthCubit is a single app-wide instance, and pushing '/forgot' keeps
        // this screen mounted underneath it — so without this guard, a reset
        // email fired from that screen makes this listener throw its own
        // snackbar on top of the one already showing there.
        if (ModalRoute.of(context)?.isCurrent == false) return;
        if (state is AuthAuthenticated) {
          HapticFeedback.mediumImpact();
          // Tells the platform the autofill session ended well, which is what
          // makes iOS and Android offer to save the credentials to the
          // keychain. Without it the AutofillGroup below only ever *fills* —
          // nobody's password is ever stored, so the next sign-in is typed out
          // by hand again.
          TextInput.finishAutofillContext();
          // Navigation is the router's job: the guard redirects off '/auth' as
          // soon as AuthBloc reports the new session, and to '/verify-email'
          // rather than '/home' when the address still needs confirming.
        } else if (state is AuthError) {
          showAuthSnack(context, state.message.text(l10n), isError: true);
        } else if (state is AuthInfo) {
          showAuthSnack(context, state.message.text(l10n), isError: false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            const AuthBackdrop(),
            SafeArea(
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: AutofillGroup(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, padding.bottom + 24),
                    children: [
                      Center(
                        child: Semantics(
                          label: l10n.appName,
                          image: true,
                          child: Image.asset('assets/splash.png', height: 96),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        returning ? l10n.authWelcomeBack : l10n.authWelcome,
                        style: AppText.display,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        returning
                            ? l10n.authSubtitleReturning
                            : l10n.authSubtitle,
                        style: AppText.bodyMuted,
                      ),
                      const SizedBox(height: 24),
                      AuthField(
                        label: l10n.commonEmail,
                        icon: Icons.mail_outline_rounded,
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) => validateEmail(v, l10n),
                        onChanged: _onEmailChanged,
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      if (_suggestion != null) ...[
                        const SizedBox(height: 6),
                        _DidYouMean(
                          address: _suggestion!,
                          onTap: _applySuggestion,
                        ),
                      ],
                      const SizedBox(height: 14),
                      AuthField(
                        label: l10n.commonPassword,
                        helperText: l10n.authPasswordHelper,
                        icon: Icons.lock_outline_rounded,
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        obscure: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.authPasswordRequired;
                          }
                          if (v.length < 6) return l10n.authPasswordTooShort;
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                        suffix: PasswordVisibilityToggle(
                          obscured: _obscure,
                          onToggle: () => setState(() => _obscure = !_obscure),
                          showLabel: l10n.authShowPassword,
                          hideLabel: l10n.authHidePassword,
                        ),
                      ),
                      const SizedBox(height: 22),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final loading = state is AuthLoading;
                          return PrimaryPillButton(
                            label: l10n.authContinue,
                            // Spins only for the tap that started here, but
                            // refuses taps while either path is in flight —
                            // otherwise pressing this lights the Google button
                            // too and nobody can tell which one they pressed.
                            isLoading:
                                loading && state.method == AuthMethod.email,
                            onPressed: loading ? null : _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/forgot'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.cta,
                            // A bare TextButton is 36dp tall; this floors the
                            // row at a thumb-sized target.
                            minimumSize: const Size(0, AppTouch.min),
                          ),
                          child: Text(
                            l10n.authForgotPassword,
                            style:
                                AppText.labelSm.copyWith(color: AppColors.cta),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OrDivider(label: l10n.authOr),
                      const SizedBox(height: 18),
                      const GoogleSignInButton(),
                      const SizedBox(height: 24),
                      const _PrivacyNote(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Did you mean ali@gmail.com?" — a tap applies it.
///
/// Offered rather than corrected silently, and shown as an ordinary hint
/// instead of an error: the address may be perfectly real, and rewriting what
/// somebody typed under their fingers is worse than one extra tap.
class _DidYouMean extends StatelessWidget {
  const _DidYouMean({required this.address, required this.onTap});

  final String address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.authErrorEmailTypo,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTouch.min),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 17, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppText.labelMuted,
                    children: [
                      TextSpan(text: '${context.l10n.authErrorEmailTypo} '),
                      TextSpan(
                        text: address,
                        style: AppText.labelSm.copyWith(color: AppColors.cta),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          l10n.authTermsNote,
          textAlign: TextAlign.center,
          style: AppText.labelMuted,
        ),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(privacyPolicyUrl),
            mode: LaunchMode.externalApplication,
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.cta,
            minimumSize: const Size(0, AppTouch.min),
          ),
          child: Text(
            l10n.commonPrivacyPolicy,
            style: AppText.labelSm.copyWith(
              color: AppColors.cta,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.cta,
            ),
          ),
        ),
      ],
    );
  }
}
