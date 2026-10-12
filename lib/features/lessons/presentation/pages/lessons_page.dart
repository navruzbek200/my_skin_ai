import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/data/yoga_data.dart'
    show yogaExercises, yogaVoiceExercises;
import 'package:real_beauty_ai/widgets/lessons/yoga_section_header.dart';
import 'package:real_beauty_ai/widgets/lessons/yoga_video_card.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  // Open on arrival. Collapsed-by-default left the tab showing two bars and
  // a screen of empty background, which reads as an unfinished section; the
  // accordion still builds its cards lazily, so this costs one section's
  // worth of video thumbs, not both.
  bool _yogaExpanded = true;
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
                      'Darslar',
                      style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kuniga bir necha daqiqa yuz mashqlari',
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

          const SliverToBoxAdapter(child: _YogaIntroCard()),

          const SliverToBoxAdapter(child: SizedBox(height: 18)),

          // ── Yuz Yoga accordion ─────────────────────────────
          SliverToBoxAdapter(
            child: YogaSectionHeader(
              isExpanded: _yogaExpanded,
              onTap: _toggleYoga,
              title: 'Yuz Yoga',
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
              title: 'Yoga mashqlari',
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

          SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
        ],
      ),
    );
  }
}


/// Sits above the accordions so the tab opens with something to read instead
/// of two collapsed bars on an empty background.
class _YogaIntroCard extends StatelessWidget {
  const _YogaIntroCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B72CC), Color(0xFF5F4CA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5040A0).withValues(alpha: 0.26),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.self_improvement_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Yuz yogasi nima?',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Yuz yogasi — yuz va bo'yin mushaklari uchun oddiy mashqlar "
              "to'plami. Har bir videoni takrorlab boring: mashqlar qisqa, "
              "jihoz talab qilmaydi va kundalik parvarishingizga osongina "
              "qo'shiladi.",
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _IntroChip(icon: Icons.schedule_rounded, label: '3–5 daqiqa'),
                const SizedBox(width: 8),
                _IntroChip(
                    icon: Icons.play_circle_outline_rounded,
                    label: '${yogaExercises.length + yogaVoiceExercises.length} ta video'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IntroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.95)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
