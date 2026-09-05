import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' show AppleLogoPainter;

import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';

/// Sign in with Apple, in the "White Outline" variant Apple's Human Interface
/// Guidelines permit — one of exactly three sanctioned styles (Black, White,
/// White Outline), chosen deliberately over the solid-black default.
///
/// A solid black pill is the single heaviest shape on a screen built from pale
/// lavender and white — it reads as the primary action even sitting under the
/// real one. The white-outline style keeps Apple's own mark and wording intact
/// while matching [GoogleSignInButton]'s weight exactly, so the two read as one
/// family of equally-weighted choices rather than one button announcing itself
/// over the other.
///
/// Built here rather than using the package's own `SignInWithAppleButton`:
/// that widget owns its height, radius and font, and would sit next to the
/// Google pill looking like it came from a different app. What the guidelines
/// actually require is Apple's own logo shape (taken from the package, not
/// redrawn) and one of the three approved styles — both kept here.
///
/// Must be placed inside a `BlocProvider<AuthCubit>` ancestor.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.authAppleButton;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Same split as the Google button: spin only for the tap that started
        // here, but refuse taps while any path is in flight.
        final loading = state is AuthLoading;
        final isLoading = loading && state.method == AuthMethod.apple;
        return SizedBox(
          height: AppTouch.control,
          child: OutlinedButton(
            onPressed:
                loading ? null : () => context.read<AuthCubit>().signInWithApple(),
            // Same geometry as GoogleSignInButton, on purpose: same surface,
            // same border colour and weight, same label style. The two
            // buttons should differ only in their mark and their words.
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.heading,
              side: const BorderSide(color: AppColors.borderStrong, width: 1.4),
              shape: const StadiumBorder(),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.cta),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Slightly taller than it is wide, which is the aspect
                      // Apple's mark is drawn at — a square box squashes it.
                      // Black on the white surface, per the White Outline spec.
                      const SizedBox(
                        width: 18,
                        height: 21,
                        child: CustomPaint(
                          painter: AppleLogoPainter(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Flexible for the same reason as the Google button:
                      // "Продолжить с Apple" at the largest text size is wider
                      // than the pill, and an unconstrained Text overflows the
                      // row rather than shortening.
                      Flexible(
                        child: Text(
                          label,
                          style:
                              AppText.button.copyWith(color: AppColors.heading),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
