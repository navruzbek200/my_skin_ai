import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../models/article.dart';
import 'package:go_router/go_router.dart';
import 'lesson_styles.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final int index;

  const ArticleCard({super.key, required this.article, required this.index});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/article-detail', extra: article);
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.62 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LessonStyles.cardRadius),
            border: Border.all(
              color: LessonStyles.cardBorderColor,
              width: 0.5,
            ),
            boxShadow: LessonStyles.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: "Maqola" chip + reading time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Maqola',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.duration,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                article.title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Summary excerpt
              Text(
                article.summary,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.45,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Bottom CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "O'qish",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: LessonStyles.stagger(widget.index))
        .fadeIn(duration: LessonStyles.enterDuration)
        .slideX(begin: 0.06);
  }
}
