import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/article.dart';
import 'package:go_router/go_router.dart';
import 'info_row_card.dart';
import 'lesson_styles.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final int index;

  const ArticleCard({super.key, required this.article, required this.index});

  @override
  Widget build(BuildContext context) {
    return InfoRowCard(
      // article.iconColor is kept in the model for compatibility but UI uses
      // AppColors.primary to avoid a rainbow palette.
      accentColor: AppColors.primary,
      showAccentBar: false,
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/article-detail', extra: article);
      },
      leading: Container(
        width: 56,
        color: AppColors.primary.withValues(alpha: 0.07),
        child: Center(
          child: Icon(article.icon, color: AppColors.primary, size: 22),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Text(
          article.title,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            height: 1.4,
          ),
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              article.duration,
              style: GoogleFonts.nunito(fontSize: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.muted),
          ],
        ),
      ),
    )
        .animate(delay: LessonStyles.stagger(index))
        .fadeIn(duration: LessonStyles.enterDuration)
        .slideX(begin: 0.06);
  }
}
