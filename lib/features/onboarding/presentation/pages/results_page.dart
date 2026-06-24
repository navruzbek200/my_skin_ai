import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async' show unawaited;
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/features/products/data/product_repository.dart';
import 'package:real_beauty_ai/models/skin_analysis_result.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:go_router/go_router.dart';

class ResultsScreen extends StatefulWidget {
  final SkinAnalysisResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _expandedBlocks = <int>{};
  List<Product> _recommendedProducts = [];

  static const _bg = Color(0xFFF0ECF8);
  static const _accent = Color(0xFF7060AA);
  static const _textDark = Color(0xFF2D2050);
  static const _typeColors = {
    'Quruq': Color(0xFF7060AA),
    'Aralash': Color(0xFF9B59B6),
    'Normal': Color(0xFF7060AA),
    "Yog'li": Color(0xFFFF8A35),
  };

  static const _typeIconMap = <String, IconData>{
    'Quruq': Icons.water_drop_outlined,
    'Aralash': Icons.water_outlined,
    'Normal': Icons.auto_awesome_outlined,
    "Yog'li": Icons.grass_outlined,
  };

  SkinAnalysisResult get _result => widget.result;

  @override
  void initState() {
    super.initState();
    // Map to SkinResult for LocalStore + RoutineEngine — fire-and-forget.
    unawaited(LocalStore.instance.saveSkinProfile(_result.toSkinResult()));
    // Append to scan history (scores only, no image data).
    unawaited(LocalStore.instance.saveAnalysisToHistory(_result));
    _loadRecommendedProducts();
  }

  Future<void> _loadRecommendedProducts() async {
    final scores = _result.scores;
    if (scores == null || scores.isEmpty) return;
    final topConcerns = scores.entries
        .where((e) => e.value > 0.25)
        .map((e) => e.key)
        .toSet();
    if (topConcerns.isEmpty) return;
    try {
      final items =
          await ProductRepository().getRecommendedForConcerns(topConcerns);
      if (mounted && items.isNotEmpty) {
        setState(() => _recommendedProducts = items);
      }
    } catch (_) {}
  }

  static const _concernLabels = <String, String>{
    'acne': 'Husnbuzar',
    'darkSpots': "Qo'ngir dog'lar",
    'pores': 'Kengaygan teshikchalar',
    'wrinkles': 'Ajinlar',
    'darkCircles': "Ko'z osti qorayishi",
    'eyeBags': "Ko'z osti shishi",
    'blackheads': 'Qora nuqtalar',
    'oiliness': "Yog'lilik",
  };

  Color get _typeColor => _typeColors[_result.skinType] ?? _accent;
  IconData get _typeIconData => _typeIconMap[_result.skinType] ?? Icons.auto_awesome_outlined;

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
                if (_result.source == AnalysisSource.cameraAnalysis &&
                    _result.scores != null) ...[
                  const SizedBox(height: 24),
                  _buildConcernScores(),
                ],
                if (_result.additionalBlocks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildAdditionalSection(),
                ],
                if (_recommendedProducts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildRecommendedProducts(),
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
      backgroundColor: Colors.black,
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
                    'Teri tahlili tayyor!',
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
                              'Teri tipingiz',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            Text(
                              '${_result.skinType} teri',
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
                          label: '+${_result.additionalBlocks.length} tavsiya',
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      if (_result.additionalBlocks.isNotEmpty &&
                          _result.source == AnalysisSource.quizEstimate)
                        const SizedBox(width: 8),
                      if (_result.source == AnalysisSource.quizEstimate)
                        _HeaderBadge(
                          label: 'natija anketadan',
                          color: Colors.white.withValues(alpha: 0.12),
                          icon: Icons.quiz_outlined,
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
      title: 'Asosiy tavsiya',
      icon: Icons.auto_awesome_outlined,
      iconColor: _typeColor,
      child: Text(
        _result.baseRecommendation,
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
          text: "Qo'shimcha tavsiyalar",
          count: _result.additionalBlocks.length,
        ),
        const SizedBox(height: 12),
        ...List.generate(_result.additionalBlocks.length, (i) {
          final block = _result.additionalBlocks[i];
          final expanded = _expandedBlocks.contains(i);
          return _AdditionalCard(
            title: block['title'] ?? '',
            text: block['text'] ?? '',
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

  Widget _buildConcernScores() {
    final scores = _result.scores!;
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.where((e) => e.value > 0).take(6).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: "Teri holati ko'rsatkichlari",
      icon: Icons.bar_chart_rounded,
      iconColor: _typeColor,
      child: Column(
        children: List.generate(top.length, (i) {
          final e = top[i];
          final pct = (e.value * 100).round().clamp(0, 100);
          final color = pct < 30
              ? const Color(0xFF4CAF50)
              : pct < 60
                  ? const Color(0xFFFF8A35)
                  : const Color(0xFFE53935);
          return Padding(
            padding: EdgeInsets.only(bottom: i < top.length - 1 ? 12 : 0),
            child: _ConcernBar(
              label: _concernLabels[e.key] ?? e.key,
              pct: pct,
              color: color,
            ),
          );
        }),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1);
  }

  Widget _buildRecommendedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          text: 'Tavsiya etilgan mahsulotlar',
          count: _recommendedProducts.length,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                _ProductCard(product: _recommendedProducts[i]),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.08);
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
              'Bu kosmetik tahlil tibbiy tashxis hisoblanmaydi. '
              "Teri muammolari bo'lsa mutaxassisga murojaat qiling.",
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
  final IconData? icon;
  const _HeaderBadge({required this.label, required this.color, this.icon});

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
          if (icon != null) ...[
            Icon(icon, size: 11, color: Colors.white),
            const SizedBox(width: 4),
          ],
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
              "Dasturni boshlash",
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

class _ConcernBar extends StatelessWidget {
  final String label;
  final int pct; // 0-100
  final Color color;
  const _ConcernBar({required this.label, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2050),
              ),
            ),
            Text(
              '$pct%',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct / 100.0,
            minHeight: 7,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: product.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    width: 140,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 140,
                      height: 110,
                      color: const Color(0xFFF0ECF8),
                    ),
                    errorWidget: (_, _, _) => Image.asset(
                      product.imagePath,
                      width: 140,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    product.imagePath,
                    width: 140,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9490B0),
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2050),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product.price,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7060AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
