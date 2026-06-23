import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/colors.dart';
import '../../../models/lesson.dart';

class FactStep extends StatelessWidget {
  final LessonStep step;
  final Color color;
  const FactStep({super.key, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
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
        if (step.keyword case final kw?)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              kw,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800, color: color,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Text(
            step.body,
            style: GoogleFonts.nunito(
              fontSize: 15, color: AppColors.text, height: 1.6,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
        const SizedBox(height: 20),
      ],
    );
  }
}
