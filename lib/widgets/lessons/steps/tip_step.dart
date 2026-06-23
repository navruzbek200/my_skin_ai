import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/colors.dart';
import '../../../models/lesson.dart';

class TipStep extends StatelessWidget {
  final LessonStep step;
  final Color color;
  const TipStep({super.key, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lightbulb_outline, color: color, size: 28),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 14),
              Text(
                step.body,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15, color: AppColors.text, height: 1.6,
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
        const SizedBox(height: 20),
      ],
    );
  }
}
