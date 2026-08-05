import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../models/lesson.dart';
import 'package:go_router/go_router.dart';
import 'info_row_card.dart';
import 'lesson_styles.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;

  const LessonCard({super.key, required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    return InfoRowCard(
      accentColor: lesson.color,
      showAccentBar: false,
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/lesson-detail', extra: lesson);
      },
      content: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                lesson.category,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              lesson.title,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Text(
              lesson.subtitle,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 7),
            // Metadata
            Row(
              children: [
                const Icon(Icons.signal_cellular_alt, size: 12, color: AppColors.primary),
                const SizedBox(width: 3),
                Text(
                  lesson.level,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.timer_outlined, size: 12, color: AppColors.muted),
                const SizedBox(width: 3),
                Text(
                  lesson.duration,
                  style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted),
                ),
                const Spacer(),
                Text(
                  '${lesson.steps.length} qadam',
                  style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
      trailing: const Padding(
        padding: EdgeInsets.only(right: 14),
        child: Center(
          child: Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
        ),
      ),
    )
        .animate(delay: LessonStyles.stagger(index))
        .fadeIn(duration: LessonStyles.enterDuration)
        .slideX(begin: 0.06);
  }
}
