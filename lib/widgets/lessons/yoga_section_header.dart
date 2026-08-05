import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import 'lesson_styles.dart';

class YogaSectionHeader extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  final String title;
  final String avatarPath;

  const YogaSectionHeader({
    super.key,
    required this.isExpanded,
    required this.onTap,
    this.title = 'Yoga mashqlari',
    this.avatarPath = 'assets/yoga_avatar.jpg',
  });

  @override
  State<YogaSectionHeader> createState() => _YogaSectionHeaderState();
}

class _YogaSectionHeaderState extends State<YogaSectionHeader> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.65 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(LessonStyles.yogaSectionRadius),
            boxShadow: LessonStyles.cardShadow,
            border: Border.all(
              color: LessonStyles.cardBorderColor,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              SizedBox(
                width: 56,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.avatarPath,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: const Icon(
                          Icons.self_improvement,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: widget.isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
