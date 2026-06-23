import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
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
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    // lesson.color kept in model; UI uses primary for calm palette
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    lesson.category,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  lesson.duration,
                  style: GoogleFonts.nunito(fontSize: 11, color: AppColors.muted),
                ),
              ],
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
              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.signal_cellular_alt, size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  lesson.level,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${lesson.steps.length} qadam',
                  style:
                      GoogleFonts.nunito(fontSize: 11, color: AppColors.muted),
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
