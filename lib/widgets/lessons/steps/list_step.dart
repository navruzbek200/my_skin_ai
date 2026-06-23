import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/colors.dart';
import '../../../models/lesson.dart';

class ListStep extends StatelessWidget {
  final LessonStep step;
  final Color color;
  const ListStep({super.key, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    final items = step.items ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          step.title,
          style: GoogleFonts.nunito(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        ...items.indexed.map((entry) {
          final (i, item) = entry;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.nunito(
                      fontSize: 14, color: AppColors.text, height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: i * 260))
              .slideY(begin: 0.3)
              .fadeIn();
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
