import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/models/skin_analysis_result.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:go_router/go_router.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = LocalStore.instance.getAnalysisHistory();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildGradientBg(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skanerla',
                    style: GoogleFonts.nunito(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7060AA),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  Text(
                    'Kamera orqali yuzni tahlil qiling',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 36),
                  _buildScanCard(context),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _ScanHistorySection(history: history),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/quiz'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF9B7DD4).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7060AA).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B7DD4), Color(0xFF7060AA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yuzni tahlil qilish',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2050),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamera va savol-javob orqali teri tipingizni aniqlang',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF7060AA).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF7060AA),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08);
  }

  Widget _buildGradientBg() {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCFC8E8),
            Color(0xFFE4D8F0),
            Color(0xFFF5EEF8),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.28, 0.55, 1.0],
        ),
      ),
    );
  }
}

// ── Progress / history section ────────────────────────────────

class _ScanHistorySection extends StatelessWidget {
  final List<SkinAnalysisResult> history;
  const _ScanHistorySection({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Taraqqiyot',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2050),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        if (history.length < 2)
          _EmptyStateCard()
        else
          _ComparisonCard(latest: history[0], previous: history[1]),
      ],
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08);
  }
}

// ── Empty state (only 1 scan recorded) ───────────────────────

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF7060AA).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: Color(0xFF7060AA),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birinchi skaningiz saqlandi',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2050),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "O'zgarishni ko'rish uchun yana skan qiling",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF9490B0),
                    height: 1.5,
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

// ── Comparison card (≥2 entries) ──────────────────────────────

class _ComparisonCard extends StatelessWidget {
  final SkinAnalysisResult latest;
  final SkinAnalysisResult previous;

  const _ComparisonCard({required this.latest, required this.previous});

  static const _concernLabels = <String, String>{
    'acne': 'Toshma',
    'darkSpots': "Qo'ng'ir dog'lar",
    'pores': "Keng g'ovaklar",
    'wrinkles': 'Ajinlar',
    'darkCircles': "Ko'z xalqalari",
    'eyeBags': "Ko'z xaltalari",
    'blackheads': 'Qora nuqtalar',
    'oiliness': "Yog'lilik",
  };

  static String _fmtDate(DateTime dt) {
    const months = [
      'yan', 'fev', 'mar', 'apr', 'may', 'iyun',
      'iyul', 'avg', 'sen', 'okt', 'noy', 'dek',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final hasScores =
        latest.scores != null && latest.scores!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7060AA).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF7060AA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "So'nggi vs oldingi skan",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2050),
                  ),
                ),
              ),
              Text(
                _fmtDate(latest.takenAt),
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: const Color(0xFF9490B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasScores) ...[
            ...latest.scores!.entries.map((e) {
              final prevVal = previous.scores?[e.key];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ConcernRow(
                  label: _concernLabels[e.key] ?? e.key,
                  value: e.value,
                  prevValue: prevVal,
                ),
              );
            }),
          ] else ...[
            _SkinTypeRow(
              label: "So'nggi",
              skinType: latest.skinType,
              date: _fmtDate(latest.takenAt),
            ),
            const SizedBox(height: 8),
            _SkinTypeRow(
              label: 'Oldingi',
              skinType: previous.skinType,
              date: _fmtDate(previous.takenAt),
              muted: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0ECF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFF9490B0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kamera skan qilgandan so\'ng aniq ballar ko\'rsatiladi',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF9490B0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Concern score bar row ─────────────────────────────────────

class _ConcernRow extends StatelessWidget {
  final String label;
  final double value; // 0–1
  final double? prevValue;

  const _ConcernRow({
    required this.label,
    required this.value,
    this.prevValue,
  });

  Color _barColor(double v) {
    if (v < 0.33) return const Color(0xFF4CAF50);
    if (v < 0.66) return const Color(0xFFFF8A35);
    return const Color(0xFFE05555);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    final prevPct = prevValue != null ? (prevValue! * 100).round() : null;
    final delta = prevPct != null ? pct - prevPct : null;
    final barColor = _barColor(value);

    return Row(
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4070),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: const Color(0xFFF0ECF8),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, v, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$pct',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2050),
                ),
              ),
              if (delta != null) ...[
                const SizedBox(width: 3),
                Text(
                  delta > 0 ? '+$delta' : '$delta',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    // lower is better: negative delta = improvement = green
                    color: delta < 0
                        ? const Color(0xFF4CAF50)
                        : delta > 0
                            ? const Color(0xFFE05555)
                            : const Color(0xFF9490B0),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Skin type row (quiz-only, no scores) ─────────────────────

class _SkinTypeRow extends StatelessWidget {
  final String label;
  final String skinType;
  final String date;
  final bool muted;

  const _SkinTypeRow({
    required this.label,
    required this.skinType,
    required this.date,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: muted
                ? const Color(0xFF9490B0)
                : const Color(0xFF7060AA),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: const Color(0xFF9490B0),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$skinType teri',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: muted
                ? const Color(0xFF9490B0)
                : const Color(0xFF2D2050),
          ),
        ),
        const Spacer(),
        Text(
          date,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: const Color(0xFF9490B0),
          ),
        ),
      ],
    );
  }
}
