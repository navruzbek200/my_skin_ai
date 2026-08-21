import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/data/articles_data.dart';
import 'package:real_beauty_ai/data/lessons_data.dart';
import 'package:real_beauty_ai/data/yoga_data.dart'
    show yogaExercises, yogaVoiceExercises;
import 'package:real_beauty_ai/widgets/lessons/article_card.dart';
import 'package:real_beauty_ai/widgets/lessons/lesson_card.dart';
import 'package:real_beauty_ai/widgets/lessons/section_header.dart';
import 'package:real_beauty_ai/widgets/lessons/yoga_section_header.dart';
import 'package:real_beauty_ai/widgets/lessons/yoga_video_card.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool _yogaExpanded = false;
  bool _yogaVoiceExpanded = false;

  void _toggleYoga() => setState(() => _yogaExpanded = !_yogaExpanded);
  void _toggleYogaVoice() =>
      setState(() => _yogaVoiceExpanded = !_yogaVoiceExpanded);

  /// A collapsible block that holds nothing at all while it is shut.
  ///
  /// [buildCards] is called from inside the builder rather than passed as a
  /// prebuilt `child`, and that is the whole point. As a `child` the cards
  /// were constructed once and kept mounted no matter what the accordion was
  /// doing, so opening Darslar mounted all ten YogaVideoCards — ten
  /// VisibilityDetectors and ten registrations with VideoPlaybackManager —
  /// for two closed sections. The shell keeps every tab alive in an
  /// IndexedStack, so that cost was paid from launch and never given back.
  /// Collapsed now means an empty box; the cards are created on the way open
  /// and disposed on the way shut, which also releases their controllers.
  Widget _yogaAccordion({
    required bool expanded,
    required List<Widget> Function() buildCards,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: expanded ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        if (value == 0) return const SizedBox.shrink();
        // ClipRect + Align(heightFactor) — cheaper than AnimatedSize, which
        // would measure the subtree on every frame of the reveal.
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(children: buildCards()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 90;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Title ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.lessonsHeading,
                      style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.lessonsSubtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ── Yuz Yoga accordion ─────────────────────────────
          SliverToBoxAdapter(
            child: YogaSectionHeader(
              isExpanded: _yogaExpanded,
              onTap: _toggleYoga,
              title: context.l10n.lessonsYoga,
              count: yogaExercises.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _yogaAccordion(
              expanded: _yogaExpanded,
              buildCards: () => [
                for (var i = 0; i < yogaExercises.length; i++)
                  YogaVideoCard(exercise: yogaExercises[i], index: i),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Yoga mashqlari (with narration) ────────────────
          SliverToBoxAdapter(
            child: YogaSectionHeader(
              isExpanded: _yogaVoiceExpanded,
              onTap: _toggleYogaVoice,
              title: context.l10n.lessonsYogaExercises,
              avatarPath: 'assets/yoga avatar 2.jpg',
              count: yogaVoiceExercises.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _yogaAccordion(
              expanded: _yogaVoiceExpanded,
              buildCards: () => [
                for (var i = 0; i < yogaVoiceExercises.length; i++)
                  YogaVideoCard(
                    exercise: yogaVoiceExercises[i],
                    index: i,
                    withAudio: true,
                  ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          // ── Ingrediyentlar ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionHeader(
                title: context.l10n.lessonsIngredients,
                count: lessons.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverList.builder(
              itemCount: lessons.length,
              itemBuilder: (_, i) => LessonCard(lesson: lessons[i]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 26)),

          // ── Maqolalar ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionHeader(title: context.l10n.lessonsArticles, count: articles.length),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList.builder(
              itemCount: articles.length,
              itemBuilder: (_, i) => ArticleCard(article: articles[i]),
            ),
          ),
        ],
      ),
    );
  }
}
