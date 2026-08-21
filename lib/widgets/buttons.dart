import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';

/// The one filled call-to-action.
///
/// Exactly one of these belongs on a screen: a second filled pill makes the
/// person choose between two things that look equally important. Everything
/// else on the screen is an [SecondaryPillButton] or a text button.
class PrimaryPillButton extends StatefulWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;

  /// Null disables the button — which is also what makes it announce itself as
  /// disabled to a screen reader, rather than merely looking dimmed.
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  State<PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<PrimaryPillButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    // With animations turned off the press scale is skipped entirely; the
    // colour change alone still confirms the tap.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      // The GestureDetector below is inside ExcludeSemantics, so its tap never
      // reaches the accessibility tree. Without this the button announces
      // itself and then cannot be pressed.
      onTap: _enabled ? widget.onPressed : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled
              ? (_) {
                  setState(() => _pressed = false);
                  HapticFeedback.lightImpact();
                  widget.onPressed!();
                }
              : null,
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed && !reduceMotion ? 0.98 : 1.0,
            duration: AppMotion.fast,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              height: AppTouch.control,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _enabled
                    ? (_pressed ? AppColors.heading : AppColors.cta)
                    // 0.45 rather than the Material 0.38 floor: at 0.38 this
                    // purple drops under 3:1 against white and the label
                    // stops being readable while a request is in flight.
                    : AppColors.cta.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: _enabled && !_pressed
                    ? [
                        BoxShadow(
                          color: AppColors.cta.withValues(alpha: 0.26),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: widget.isLoading
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
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 19, color: Colors.white),
                          const SizedBox(width: 9),
                        ],
                        // Flexible, because the same pill holds "Continue" and
                        // "Подтвердить через Google и удалить" — an
                        // unconstrained Text overflows the row instead of
                        // shortening.
                        Flexible(
                          child: Text(
                            widget.label,
                            style: AppText.button,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The quieter sibling: same geometry, an outline instead of a fill, so it
/// reads as available without competing with the primary action.
class SecondaryPillButton extends StatelessWidget {
  const SecondaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Destructive actions carry the danger colour *and* sit apart from
  /// everything else — colour alone is not a signal for someone who cannot see
  /// it.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final tint = isDestructive ? AppColors.danger : AppColors.cta;
    return SizedBox(
      height: AppTouch.control,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: tint,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: onPressed == null
                ? AppColors.borderStrong.withValues(alpha: 0.5)
                : tint.withValues(alpha: 0.45),
            width: 1.5,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: 9),
            ],
            Flexible(
              child: Text(
                label,
                style: AppText.button.copyWith(color: tint),
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
