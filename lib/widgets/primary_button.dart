import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/colors.dart';
import '../core/typography.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.width,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : widget.width,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B72CC), Color(0xFF6050AA)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: _pressed ? 0.20 : 0.38),
                  blurRadius: _pressed ? 6 : 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(widget.label, style: AppText.button),
            ),
          ),
        ),
      ),
    );
  }
}
