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

  // ClipRect + Align(heightFactor) — cheaper than AnimatedSize (no child rebuild)
  Widget _yogaAccordion({
    required bool expanded,
    required List<Widget> cards,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: expanded ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      builder: (context, value, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: value,
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(children: cards),
      ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'Darslar',
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),

          // ── Yuz Yoga accordion ─────────────────────────────
          SliverToBoxAdapter(
            child: YogaSectionHeader(
              isExpanded: _yogaExpanded,
              onTap: _toggleYoga,
              title: 'Yuz Yoga',
            ),
          ),
          SliverToBoxAdapter(
            child: _yogaAccordion(
              expanded: _yogaExpanded,
              cards: yogaExercises
                  .asMap()
                  .entries
                  .map((e) => YogaVideoCard(exercise: e.value, index: e.key))
                  .toList(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ──  ──────────────────────────
          SliverToBoxAdapter(
            child: YogaSectionHeader(
              isExpanded: _yogaVoiceExpanded,
              onTap: _toggleYogaVoice,
              title: 'Yoga mashqlari',
              avatarPath: 'assets/yoga avatar 2.jpg',
            ),
          ),
          SliverToBoxAdapter(
            child: _yogaAccordion(
              expanded: _yogaVoiceExpanded,
              cards: yogaVoiceExercises
                  .asMap()
                  .entries
                  .map(
                    (e) => YogaVideoCard(
                      exercise: e.value,
                      index: e.key,
                      withAudio: true,
                    ),
                  )
                  .toList(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Ingrediyentlar ────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionHeader(title: 'Ingrediyentlar'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => LessonCard(lesson: lessons[i], index: i),
                childCount: lessons.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Maqolalar ─────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SectionHeader(title: 'Maqolalar'),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ArticleCard(article: articles[i], index: i),
                childCount: articles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
