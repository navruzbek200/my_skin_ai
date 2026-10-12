import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/models/skin_analysis_result.dart';
import 'package:real_beauty_ai/models/skin_result.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:go_router/go_router.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = LocalStore.instance.getAnalysisHistory();
    final profile = LocalStore.instance.getSkinProfile();

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
                    profile == null
                        ? 'Teri tahlilini boshlang'
                        : 'Teri tahlili',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7060AA),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  Text(
                    'Savolnoma orqali teri tipingizni aniqlang',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 28),
                  if (profile != null) ...[
                    _ProfileSummaryCard(profile: profile),
                    const SizedBox(height: 18),
                  ],
                  _buildScanCard(context),
                  const SizedBox(height: 10),
                  const _AiDisclaimer().animate().fadeIn(delay: 200.ms),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _ScanHistorySection(history: history),
                  ],
                  const SizedBox(height: 30),
                  const _HowItWorksSection(),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Teri tahlilini boshlash — savolnoma orqali',
      child: GestureDetector(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/face tahlil.jpg',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teri tahlilini boshlash',
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2050),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bir necha daqiqa vaqt ajrating',
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
          'Natijalar',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2050),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        if (history.length < 2)
          const _EmptyStateCard()
        else
          _ComparisonCard(latest: history[0], previous: history[1]),
      ],
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08);
  }
}

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
                  'Birinchi tahlilingiz saqlandi',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2050),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "O'zgarishni ko'rish uchun yana tahlil qiling",
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

class _ComparisonCard extends StatelessWidget {
  final SkinAnalysisResult latest;
  final SkinAnalysisResult previous;

  const _ComparisonCard({required this.latest, required this.previous});

  static String _fmtDate(DateTime dt) {
    const months = [
      'yan', 'fev', 'mar', 'apr', 'may', 'iyun',
      'iyul', 'avg', 'sen', 'okt', 'noy', 'dek',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
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
                  "So'nggi vs oldingi tahlil",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2050),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}

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

class _AiDisclaimer extends StatelessWidget {
  const _AiDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          size: 13,
          color: Color(0xFFB8A8D8),
        ),
        const SizedBox(width: 5),
        Text(
          'Teri tahlili — tibbiy tashxis emas',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: const Color(0xFFB8A8D8),
          ),
        ),
        const SizedBox(width: 6),
        Text('·', style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFFB8A8D8))),
        const SizedBox(width: 6),
        Semantics(
          link: true,
          child: GestureDetector(
            onTap: () => context.push('/sources'),
            child: Text(
              'Manbalar',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF7060AA),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF7060AA),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Current profile ───────────────────────────────────────────

/// What the last analysis concluded, shown at the top of the tab once there
/// is a profile. Without it the tab was a title, one button and a screenful
/// of gradient — the result lived only on a screen the user had already
/// dismissed.
class _ProfileSummaryCard extends StatelessWidget {
  final SkinResult profile;
  const _ProfileSummaryCard({required this.profile});

  static const _typeIcons = <String, IconData>{
    'Quruq': Icons.water_drop_outlined,
    'Aralash': Icons.water_outlined,
    'Normal': Icons.auto_awesome_outlined,
    "Yog'li": Icons.grass_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final concerns = profile.additionalBlocks
        .map((b) => b['title'] ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFF7060AA).withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _typeIcons[profile.skinType] ?? Icons.auto_awesome_outlined,
                  size: 22,
                  color: const Color(0xFF7060AA),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teri tipingiz',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '${profile.skinType} teri',
                      style: GoogleFonts.nunito(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2050),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (concerns.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "E'tibor talab qiladigan jihatlar",
              style: GoogleFonts.nunito(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final c in concerns)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7060AA).withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      c,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5F4CA8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.08);
  }
}

// ── How it works ──────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const _steps = [
    (
      icon: Icons.checklist_rounded,
      title: 'Savolnomaga javob bering',
      body: "Teringiz haqida 10 ta qisqa savol — bir necha daqiqa vaqt oladi.",
    ),
    (
      icon: Icons.auto_awesome_outlined,
      title: 'Teri tipingizni oling',
      body:
          "Javoblaringiz asosida teri tipi va e'tibor talab qiladigan jihatlar aniqlanadi.",
    ),
    (
      icon: Icons.event_available_outlined,
      title: 'Kunlik rejani bajaring',
      body:
          "Natijaga mos ertalabki va kechki parvarish qadamlari «Bugun» bo'limida paydo bo'ladi.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qanday ishlaydi',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2050),
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _steps.length; i++) ...[
          _StepRow(index: i + 1, step: _steps[i]),
          if (i != _steps.length - 1) const SizedBox(height: 12),
        ],
      ],
    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.06);
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final ({IconData icon, String title, String body}) step;

  const _StepRow({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF7060AA).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(step.icon, size: 17, color: const Color(0xFF7060AA)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$index. ${step.title}',
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2050),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.body,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.55,
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
