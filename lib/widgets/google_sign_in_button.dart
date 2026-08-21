import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';

/// Google Sign-In, in Google's own colours and wordmark placement per their
/// branding guidelines: white surface, full-colour "G", no recolouring.
///
/// Must be placed inside a `BlocProvider<AuthCubit>` ancestor.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.authGoogleButton;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Same split as the email button: show a spinner only for the tap that
        // started here, but refuse taps while either path is in flight.
        final loading = state is AuthLoading;
        final isLoading = loading && state.method == AuthMethod.google;
        return SizedBox(
          height: AppTouch.control,
          child: OutlinedButton(
            onPressed:
                loading ? null : () => context.read<AuthCubit>().signInWithGoogle(),
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
                      SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 21,
                        height: 21,
                      ),
                      const SizedBox(width: 12),
                      // Flexible: "Войти через Google" at the largest text size
                      // is wider than the pill, and an unconstrained Text
                      // overflows the row rather than shortening.
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
