import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';

/// The text field every auth screen uses.
///
/// Floating label rather than a placeholder: a placeholder disappears the
/// moment someone starts typing, which leaves a filled form as a column of
/// values with nothing saying what any of them are. The label rises onto the
/// border instead, so each input stays self-describing without a stacked label
/// row above it.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.icon,
    this.helperText,
    this.errorText,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofocus = false,
  });

  final String label;
  final String? helperText;

  /// Set only by screens that validate by hand rather than through a [Form].
  final String? errorText;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // A rounder radius than the app's default `md` — pill buttons already sit
    // at 30, and a field this close to them read as a different, sharper
    // component when it used the same corner as a plain card.
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      // The system fills and, once the screen calls
      // `TextInput.finishAutofillContext()`, offers to save — which is what
      // stops the next sign-in being typed out by hand again.
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
      autocorrect: false,
      enableSuggestions: !obscure,
      style: AppText.body.copyWith(fontWeight: FontWeight.w600),
      cursorColor: AppColors.cta,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        errorText: errorText,
        // Two lines of room: "Password must be at least 6 characters" wraps in
        // Russian, and a one-line error box clips it.
        errorMaxLines: 2,
        helperMaxLines: 2,
        labelStyle: AppText.body.copyWith(color: AppColors.muted),
        floatingLabelStyle: AppText.bodySm.copyWith(
          color: AppColors.cta,
          fontWeight: FontWeight.w700,
        ),
        helperStyle: AppText.caption,
        errorStyle: AppText.caption.copyWith(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: AppColors.cta.withValues(alpha: 0.7), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        // 18 vertical rather than 16: with the 56dp control height used
        // everywhere else, a 16 here made the fields visibly shorter than the
        // button they sit above.
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        // [AppColors.borderStrong] is tuned to just clear the 3:1 boundary
        // contrast a UI component needs against this fill — dropping it
        // entirely would leave a field with no visible edge for anyone who
        // cannot rely on the faint fill tint alone. A thinner stroke keeps
        // that floor while reading as a finer line than the 1.4 used on the
        // heavier outlined buttons.
        border: outline(AppColors.borderStrong, 1.1),
        enabledBorder: outline(AppColors.borderStrong, 1.1),
        focusedBorder: outline(AppColors.cta, 2),
        errorBorder: outline(AppColors.danger, 1.5),
        focusedErrorBorder: outline(AppColors.danger, 2),
      ),
    );
  }
}

/// The show/hide control for a password field.
///
/// An [IconButton] rather than a bare [GestureDetector] on the icon: the glyph
/// is 20dp, and without the button's own 48dp box the transparent padding
/// around it swallows every near-miss tap.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onToggle,
    required this.showLabel,
    required this.hideLabel,
  });

  final bool obscured;
  final VoidCallback onToggle;
  final String showLabel;
  final String hideLabel;

  @override
  Widget build(BuildContext context) {
    final label = obscured ? showLabel : hideLabel;
    return IconButton(
      onPressed: onToggle,
      // Both, deliberately: the tooltip is for a long press, the semantic
      // label is what a screen reader announces instead of "button".
      tooltip: label,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 21,
        color: AppColors.muted,
        semanticLabel: label,
      ),
    );
  }
}

/// "or" between the email form and the provider buttons.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    // Bumped from the hairline [AppColors.border] and [labelMuted]: at that
    // weight the row sat between two much heavier buttons and disappeared —
    // decorative dividers can afford to be that quiet, but this one is a
    // labelled break in the page's one column, and needs to hold its own line.
    final line = Expanded(
      child: Divider(
        color: AppColors.borderStrong.withValues(alpha: 0.55),
        height: 1,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: AppText.label.copyWith(
              color: AppColors.muted,
              letterSpacing: 0.3,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

/// A soft accent wash behind the top of an auth screen, echoing the splash
/// bloom so sign-in reads as a continuation of the arrival rather than a
/// different app.
///
/// Two radial blooms rather than one flat linear fade: a single top-to-bottom
/// gradient reads as a coloured rectangle behind the content, where a pair of
/// off-centre glows — one from the accent, one from the deeper CTA purple —
/// reads as light rather than as paint, which is the difference between a
/// screen that looks tinted and one that looks lit.
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.46;
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: -height * 0.28,
              left: -60,
              right: -60,
              height: height * 0.9,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x3D9B7DD4), Color(0x009B7DD4)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -height * 0.1,
              right: -90,
              width: height * 0.75,
              height: height * 0.75,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x224A3A9A), Color(0x004A3A9A)],
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

/// A large icon in a tinted circle — the visual anchor at the top of the verify
/// and reset screens.
class HaloIcon extends StatelessWidget {
  const HaloIcon({super.key, required this.icon, this.size = 92});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.accentSoft,
          shape: BoxShape.circle,
        ),
        // Decorative: the heading underneath already says what the screen is
        // about, so announcing the glyph as well would only repeat it.
        child: ExcludeSemantics(
          child: Icon(icon, size: size * 0.42, color: AppColors.cta),
        ),
      ),
    );
  }
}

/// One place that shows an auth message, so an error and a notice can never
/// end up styled differently on two screens.
///
/// Carries an icon as well as a colour: red alone says nothing to a person who
/// cannot distinguish it, and a snackbar has no other structure to lean on.
void showAuthSnack(
  BuildContext context,
  String message, {
  required bool isError,
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppText.bodySm.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.cta,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        // Long enough to read the two-sentence wrong-password message, which is
        // the one that tells a Google user which button to press instead.
        duration: Duration(seconds: isError ? 5 : 4),
      ),
    );
}
