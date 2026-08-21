import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'dart:async' show unawaited;
import 'package:real_beauty_ai/models/skin_analysis_result.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/logic/skin_copy.dart';

class ResultsScreen extends StatefulWidget {
  final SkinAnalysisResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _expandedBlocks = <int>{};
  static const _bg = Color(0xFFF0ECF8);
  static const _accent = Color(0xFF7060AA);
  static const _textDark = Color(0xFF2D2050);
  // Keyed on the one-letter code rather than on the Uzbek name: the name is
  // now translated for display, so matching on it would drop back to the
  // default colour and icon the moment the app was read in Russian.
  static const _typeColors = <String, Color>{
    'D': Color(0xFF7060AA),
    'C': Color(0xFF9B59B6),
    'N': Color(0xFF7060AA),
    'O': Color(0xFFFF8A35),
  };

  static const _typeIconMap = <String, IconData>{
    'D': Icons.water_drop_outlined,
    'C': Icons.water_outlined,
    'N': Icons.auto_awesome_outlined,
    'O': Icons.grass_outlined,
  };

  SkinAnalysisResult get _result => widget.result;

  @override
  void initState() {
    super.initState();
    // Map to SkinResult for LocalStore + RoutineEngine — fire-and-forget.
    unawaited(LocalStore.instance.saveSkinProfile(_result.toSkinResult()));
    // Append to scan history (scores only, no image data).
    unawaited(LocalStore.instance.saveAnalysisToHistory(_result));
  }

  Color get _typeColor => _typeColors[_result.skinTypeCode] ?? _accent;
  IconData get _typeIconData =>
      _typeIconMap[_result.skinTypeCode] ?? Icons.auto_awesome_outlined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _buildBaseRec(),
                if (_result.additionalBlocks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildAdditionalSection(),
                ],
                const SizedBox(height: 24),
                _buildDisclaimer(),
                const SizedBox(height: 32),
                _buildCta(context),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner photo
            Image.asset(
              'assets/skin_result_banner.webp',
              fit: BoxFit.cover,
              alignment: const Alignment(0.3, 0.6),
            ),
            // Subtle dark gradient at bottom for text readability only
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0.0, 0.45, 0.75, 1.0],
                ),
              ),
            ),
            // Text content pinned at bottom
            Positioned(
              left: 24, right: 24, bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.resultsTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_typeIconData, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.resultsSkinType,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            Text(
                              context.l10n.resultsSkinTypeValue(
                                // Resolved from the code rather than read off
                                // the stored name, so a language switch after
                                // the analysis applies to it too.
                                context.skinTypeLabel(
                                  _result.skinTypeCode,
                                  stored: _result.skinType,
                                ),
                              ),
                              style: GoogleFonts.nunito(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_result.additionalBlocks.isNotEmpty)
                        _HeaderBadge(
                          label: context.l10n.resultsMoreAdvice(_result.additionalBlocks.length),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                    ],
                  ).animate().fadeIn(delay: 350.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseRec() {
    return _SectionCard(
      title: context.l10n.resultsMainAdvice,
      icon: Icons.auto_awesome_outlined,
      iconColor: _typeColor,
      child: Text(
        context.baseRecommendation(
          _result.skinTypeCode,
          stored: _result.baseRecommendation,
        ),
        style: GoogleFonts.nunito(
          fontSize: 14,
          color: _textDark,
          height: 1.65,
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.12);
  }

  Widget _buildAdditionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          text: context.l10n.resultsExtraAdvice,
          count: _result.additionalBlocks.length,
        ),
        const SizedBox(height: 12),
        ...List.generate(_result.additionalBlocks.length, (i) {
          final block = _result.additionalBlocks[i];
          final expanded = _expandedBlocks.contains(i);
          return _AdditionalCard(
            title: context
                .concernBlock(block['code'],
                    storedTitle: block['title'] ?? '',
                    storedText: block['text'] ?? '')
                .title,
            text: context
                .concernBlock(block['code'],
                    storedTitle: block['title'] ?? '',
                    storedText: block['text'] ?? '')
                .text,
            expanded: expanded,
            delay: 400 + i * 80,
            onToggle: () => setState(() {
              if (expanded) {
                _expandedBlocks.remove(i);
              } else {
                _expandedBlocks.add(i);
              }
            }),
          );
        }),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.resultsDisclaimer,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.orange.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 650.ms);
  }

  Widget _buildCta(BuildContext context) {
    return _ResultsCta(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.go('/home');
      },
      accent: _accent,
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1);
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _HeaderBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final int count;
  const _SectionLabel({required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2050),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF7060AA).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7060AA),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2050),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AdditionalCard extends StatelessWidget {
  final String title;
  final String text;
  final bool expanded;
  final int delay;
  final VoidCallback onToggle;

  const _AdditionalCard({
    required this.title,
    required this.text,
    required this.expanded,
    required this.delay,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3AABFF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2050),
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9490B0),
                    size: 22,
                  ),
                ],
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 16, 14),
                child: Text(
                  text,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF4A4070),
                    height: 1.6,
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.08);
  }
}

class _ResultsCta extends StatefulWidget {
  final VoidCallback onTap;
  final Color accent;
  const _ResultsCta({required this.onTap, required this.accent});

  @override
  State<_ResultsCta> createState() => _ResultsCtaState();
}

class _ResultsCtaState extends State<_ResultsCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: _pressed ? 0.18 : 0.35),
                blurRadius: _pressed ? 8 : 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              context.l10n.resultsStart,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
