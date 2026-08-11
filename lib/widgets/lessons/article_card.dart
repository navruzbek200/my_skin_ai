import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../../models/article.dart';
import 'package:go_router/go_router.dart';
import 'info_row_card.dart';
import 'lesson_styles.dart';

/// One article in the Maqolalar list.
///
/// Built on [InfoRowCard] rather than on its own Container: this card used to
/// hand-roll the same white surface, hairline border, two-layer shadow and
/// press-opacity that InfoRowCard already provides, which meant two places to
/// keep in step every time the card styling moved.
class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final accent = article.iconColor;

    return Semantics(
      button: true,
      label:
          '${article.title}. ${article.summary}. '
          "O'qish uchun ${article.duration}",
      child: ExcludeSemantics(
        child: InfoRowCard(
          accentColor: accent,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/article-detail', extra: article);
          },
          content: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(article.icon, size: 14, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      'Maqola',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: LessonStyles.readableAccent(accent),
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
                const SizedBox(height: 9),
                Text(
                  article.title,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
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
