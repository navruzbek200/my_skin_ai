import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class AnalysisScreen extends StatefulWidget {
  final List<dynamic> answers;
  const AnalysisScreen({super.key, required this.answers});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const _bg = Color(0xFFF0ECF8);
  static const _accent = Color(0xFF7060AA);
  static const _textDark = Color(0xFF2D2050);
  static const _textMuted = Color(0xFF9490B0);

  // Steps describe what the quiz-based analysis is actually doing — no false
  // camera-measurement claims.  Results are computed from quiz answers only.
  static const _steps = [
    'Teri tipi tahlil qilinmoqda',
    "Javoblaringiz qayta ishlanmoqda",
    'Teri xususiyatlari aniqlanmoqda',
    'Tavsiyalar tayyorlanmoqda',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _ctrl.forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(300.ms, () {
          if (mounted) {
            context.go('/results', extra: widget.answers);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                'Tahlil qilinmoqda...',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                "Savollaringiz asosida tahlil qilinmoqda",
                style: GoogleFonts.nunito(fontSize: 14, color: _textMuted),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 56),
              // Circle progress
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) {
                  final pct = (_ctrl.value * 100).toInt();
                  return SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: _ctrl.value,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$pct%',
                              style: GoogleFonts.nunito(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'tayyor',
                              style: GoogleFonts.nunito(fontSize: 13, color: _textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const Spacer(flex: 2),
              _buildSteps(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          return Column(
            children: List.generate(_steps.length, (i) {
              final done = _ctrl.value > (i + 1) / 4;
              final active = _ctrl.value > i / 4 && !done;
              return Padding(
                padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? 16 : 0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: 300.ms,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? _accent
                            : active
                                ? _accent.withValues(alpha: 0.15)
                                : const Color(0xFFEEF2F7),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : active
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(_accent),
                                    ),
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _textMuted,
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _steps[i],
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: active || done ? FontWeight.w700 : FontWeight.w500,
                          color: done || active ? _textDark : _textMuted,
                        ),
                      ),
                    ),
                    if (done)
                      Text(
                        'Tayyor',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}
