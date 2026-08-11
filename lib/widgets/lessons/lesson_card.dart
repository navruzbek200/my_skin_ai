import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../models/lesson.dart';
import 'package:go_router/go_router.dart';
import 'info_row_card.dart';
import 'lesson_styles.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // Every lesson already carries its own colour, and until now the card
    // asked for it and then drew it nowhere: `showAccentBar` was false, so
    // seven differently-themed lessons rendered as seven identical white
    // rectangles. The bar and the chip below are what that colour is for.
    final accent = lesson.color;

    return Semantics(
      button: true,
      label:
          '${lesson.title}. ${lesson.subtitle}. '
          '${lesson.level}, ${lesson.duration}, ${lesson.steps.length} qadam',
      child: ExcludeSemantics(
        child: InfoRowCard(
          accentColor: accent,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/lesson-detail', extra: lesson);
          },
          content: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Chip(label: lesson.category, color: accent),
                    const Spacer(),
                    Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      lesson.duration,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  lesson.title,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_alt, size: 12, color: accent),
                    const SizedBox(width: 3),
                    Text(
                      lesson.level,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.format_list_numbered_rounded,
                      size: 12,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${lesson.steps.length} qadam',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: LessonStyles.readableAccent(color),
        ),
      ),
    );
  }
}
