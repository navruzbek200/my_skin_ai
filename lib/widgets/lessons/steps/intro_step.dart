import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/colors.dart';
import '../../../models/lesson.dart';
import 'animated_lesson_icon.dart';

class IntroStep extends StatelessWidget {
  final LessonStep step;
  final Color color;
  const IntroStep({super.key, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AnimatedLessonIcon(color: color),
        const SizedBox(height: 24),
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            step.body,
            style: GoogleFonts.nunito(
              fontSize: 15, color: AppColors.text, height: 1.6,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        const SizedBox(height: 20),
      ],
    );
  }
}
