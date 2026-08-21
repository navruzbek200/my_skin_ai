import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/data/skin_problems_data.dart';
import 'package:real_beauty_ai/models/skin_analysis_result.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/logic/skin_copy.dart';

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
                    context.l10n.scanStartTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7060AA),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  Text(
                    context.l10n.scanStartBody,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 36),
                  _buildScanCard(context),
                  const SizedBox(height: 10),
                  const _AiDisclaimer().animate().fadeIn(delay: 200.ms),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _ScanHistorySection(history: history),
                  ],
                  const SizedBox(height: 32),
                  const _SkinProblemsSection(),
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
      label: context.l10n.scanStartCta,
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
                      context.l10n.scanStartCta,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2050),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.scanStartHint,
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
          context.l10n.scanResultsHeading,
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
                  context.l10n.scanFirstSaved,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2050),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.scanFirstSavedBody,
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

  /// Through `intl` rather than a hard-coded month table: the table only ever
  /// held Uzbek abbreviations, so a Russian or English reader saw "12 iyul" in
  /// the middle of their own interface.
  static String _fmtDate(BuildContext context, DateTime dt) =>
      DateFormat.MMMd(Localizations.localeOf(context).toString()).format(dt);

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
                  context.l10n.scanComparison,
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
            label: context.l10n.scanLatest,
            skinType: context.skinTypeLabel(latest.skinTypeCode,
                stored: latest.skinType),
            date: _fmtDate(context, latest.takenAt),
          ),
          const SizedBox(height: 8),
          _SkinTypeRow(
            label: context.l10n.scanPrevious,
            skinType: context.skinTypeLabel(previous.skinTypeCode,
                stored: previous.skinType),
            date: _fmtDate(context, previous.takenAt),
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
          context.l10n.scanSkinTypeValue(skinType),
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
          context.l10n.scanAiNote,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: const Color(0xFFB8A8D8),
          ),
        ),
      ],
    );
  }
}

// ── Skin problems section ─────────────────────────────────────

class _SkinProblemsSection extends StatelessWidget {
  const _SkinProblemsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.scanProblems,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2050),
          ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 4),
        Text(
          context.l10n.scanCauses,
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: const Color(0xFF9490B0),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: skinProblems.length,
          itemBuilder: (context, i) => _SkinProblemCard(
            problem: skinProblems[i],
            index: i,
          ),
        ),
      ],
    );
  }
}

class _SkinProblemCard extends StatefulWidget {
  final SkinProblem problem;
  final int index;

  const _SkinProblemCard({required this.problem, required this.index});

  @override
  State<_SkinProblemCard> createState() => _SkinProblemCardState();
}

class _SkinProblemCardState extends State<_SkinProblemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.problem;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SkinProblemDetailPage(problem: p),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'skin_problem_${p.id}',
                child: p.imagePath != null
                    ? Image.asset(
                        p.imagePath!,
                        fit: BoxFit.cover,
                        cacheWidth: 360,
                        errorBuilder: (_, _, _) =>
                            _GradientPlaceholder(problem: p),
                      )
                    : _GradientPlaceholder(problem: p),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                    stops: [0.38, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  context.tr(p.name),
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: const [
                      Shadow(blurRadius: 6, color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + widget.index * 50))
        .fadeIn(duration: const Duration(milliseconds: 300));
  }
}

class _GradientPlaceholder extends StatelessWidget {
  final SkinProblem problem;
  const _GradientPlaceholder({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            problem.color.withValues(alpha: 0.85),
            problem.color.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          problem.icon,
          size: 52,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

// ── Skin problem detail page ──────────────────────────────────

class SkinProblemDetailPage extends StatelessWidget {
  final SkinProblem problem;
  const SkinProblemDetailPage({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFFF8F6FC),
            foregroundColor: const Color(0xFF2D2050),
            surfaceTintColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'skin_problem_${problem.id}',
                child: problem.imagePath != null
                    ? Image.asset(
                        problem.imagePath!,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        errorBuilder: (_, _, _) =>
                            _GradientPlaceholder(problem: problem),
                      )
                    : _GradientPlaceholder(problem: problem),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(problem.name),
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2050),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: problem.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DetailCard(
                    icon: Icons.help_outline_rounded,
                    label: context.l10n.scanProblemCause,
                    text: context.tr(problem.cause),
                    accentColor: const Color(0xFF7060AA),
                  ),
                  const SizedBox(height: 14),
                  _DetailCard(
                    icon: Icons.check_circle_outline_rounded,
                    label: context.l10n.scanProblemSolution,
                    text: context.tr(problem.solution),
                    accentColor: const Color(0xFF16A34A),
                  ),
                  if (problem.note != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: problem.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: problem.color.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 18,
                            color: problem.color,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.tr(problem.note!),
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: problem.color,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color accentColor;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF2D2050),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
