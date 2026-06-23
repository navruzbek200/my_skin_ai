import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/widgets/looping_video_thumb.dart';
import 'package:real_beauty_ai/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

// ── Step data model ───────────────────────────────────────────────────────────

class _StepItem {
  final int number;
  final String? videoAsset;
  final String? imageAsset;
  final String title;
  final String subtitle;

  const _StepItem({
    required this.number,
    this.videoAsset,
    // ignore: unused_element_parameter
    this.imageAsset,
    required this.title,
    required this.subtitle,
  });
}

const _steps = [
  _StepItem(
    number: 1,
    videoAsset: 'assets/videos/scan/step1_glasses.mp4',
    title: "Ko'zoynakni yeching",
    subtitle: "Va yorug' joy toping",
  ),
  _StepItem(
    number: 2,
    videoAsset: 'assets/videos/scan/step2_straight.mp4',
    title: 'Boshingizni tik tuting',
    subtitle: 'Va Boshlash tugmasini bosing',
  ),
  _StepItem(
    number: 3,
    videoAsset: 'assets/videos/scan/step3_ring.mp4',
    title: "To'liq aylaning",
    subtitle: "Sekin aylanib, barcha bo'laklarni yoping",
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ScanInstructionsScreen extends StatefulWidget {
  final List<dynamic> quizAnswers;
  const ScanInstructionsScreen({super.key, required this.quizAnswers});

  @override
  State<ScanInstructionsScreen> createState() => _ScanInstructionsScreenState();
}

class _ScanInstructionsScreenState extends State<ScanInstructionsScreen>
    with WidgetsBindingObserver {
  // Toggled true on background/inactive, false on resume — drives all thumbs.
  final _pauseSignal = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseSignal.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _pauseSignal.value = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden;
  }

  void _proceed() {
    HapticFeedback.mediumImpact();
    context.pushReplacement('/face-scan', extra: widget.quizAnswers);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0A0A0A)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _Sheet(
              safeBottom: bottom,
              pauseSignal: _pauseSignal,
              onClose: () => Navigator.pop(context),
              onContinue: _proceed,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  final double safeBottom;
  final ValueListenable<bool> pauseSignal;
  final VoidCallback onClose;
  final VoidCallback onContinue;

  const _Sheet({
    required this.safeBottom,
    required this.pauseSignal,
    required this.onClose,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 28, 24, safeBottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(onClose: onClose),
          const SizedBox(height: 28),
          for (int i = 0; i < _steps.length; i++) ...[
            _StepRow(step: _steps[i], pauseSignal: pauseSignal),
            if (i < _steps.length - 1) const SizedBox(height: 22),
          ],
          const SizedBox(height: 32),
          PrimaryButton(label: 'Davom etish', onPressed: onContinue),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 280))
        .slideY(begin: 0.06, duration: const Duration(milliseconds: 320));
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Skanerlash yo'riqnomasi",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Yopish',
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF555555),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step row ──────────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final _StepItem step;
  final ValueListenable<bool> pauseSignal;

  const _StepRow({required this.step, required this.pauseSignal});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Thumbnail(step: step, pauseSignal: pauseSignal),
        const SizedBox(width: 16),
        Expanded(child: _StepText(step: step)),
      ],
    );
  }
}

// ── Thumbnail with number badge ───────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final _StepItem step;
  final ValueListenable<bool> pauseSignal;

  const _Thumbnail({required this.step, required this.pauseSignal});

  Widget _content() {
    if (step.videoAsset != null) {
      return LoopingVideoThumb(
        assetPath: step.videoAsset!,
        pauseSignal: pauseSignal,
      );
    }
    if (step.imageAsset != null) {
      return Image.asset(
        step.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ThumbPlaceholder(),
      );
    }
    return const _ThumbPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(width: 88, height: 88, child: _content()),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: _NumberBadge(number: step.number),
        ),
      ],
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF0F0F0),
      child: Center(
        child: Icon(Icons.face_outlined, size: 32, color: AppColors.muted),
      ),
    );
  }
}

// ── Number badge ──────────────────────────────────────────────────────────────

class _NumberBadge extends StatelessWidget {
  final int number;
  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Step text ─────────────────────────────────────────────────────────────────

class _StepText extends StatelessWidget {
  final _StepItem step;
  const _StepText({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.subtitle,
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: const Color(0xFF8E8EA0),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
