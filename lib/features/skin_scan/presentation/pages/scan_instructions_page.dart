import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:real_beauty_ai/widgets/looping_video_thumb.dart';
import 'package:real_beauty_ai/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/router/route_args.dart';

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
    videoAsset: 'assets/videos/scan/step2_straight.mp4',
    title: "To'g'ri va frontal qarang",
    subtitle: "Avtomatik suratga olinadi",
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
    if (LocalStore.instance.cloudAnalysisAccepted) {
      context.pushReplacement('/face-scan', extra: widget.quizAnswers);
    } else {
      _showConsentDialog();
    }
  }

  void _showConsentDialog() {
    // Capture router and answers before any async gap.
    final router = GoRouter.of(context);
    final answers = widget.quizAnswers;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Capture navigator before async gap so BuildContext isn't used after await.
        final nav = Navigator.of(ctx);
        return _CloudConsentDialog(
          onAccept: () async {
            await LocalStore.instance.acceptCloudAnalysis();
            if (!mounted) return;
            nav.pop();
            router.pushReplacement('/face-scan', extra: answers);
          },
          onDecline: () {
            Navigator.of(ctx).pop();
            // Skip camera — AnalysisScreen falls through to quiz-only SkinLogic path.
            router.pushReplacement('/analysis', extra: AnalysisArgs(quizAnswers: answers));
          },
        );
      },
    );
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
              onClose: () => context.pop(),
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

// ── Cloud analysis consent dialog ─────────────────────────────

class _CloudConsentDialog extends StatelessWidget {
  final Future<void> Function() onAccept;
  final VoidCallback onDecline;

  const _CloudConsentDialog({
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7060AA).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Color(0xFF7060AA),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rasm yuborish haqida',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2050),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bullet list
            ..._bullets.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Color(0xFF7060AA),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF4A4070),
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Non-medical disclaimer box
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu tibbiy tashxis EMAS — faqat kosmetik yo\'riqnoma. '
                      'Teri muammolari bo\'lsa mutaxassisga murojaat qiling.',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3A9A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Qabul qilaman',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: onDecline,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9490B0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  'Rad etaman (faqat anketa)',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _bullets = [
    'Yuz rasmingiz kosmetik tahlil uchun uchinchi tomon serveriga yuboriladi',
    'Rasm tahlildan so\'ng darhol o\'chiriladi — saqlanmaydi',
    'Natijalar faqat qurilmangizda qoladi',
  ];
}
