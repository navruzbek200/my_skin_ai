import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/router/route_args.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/skin_analysis/domain/skin_analysis_repository.dart';
import 'package:real_beauty_ai/logic/skin_logic.dart';

class AnalysisScreen extends StatefulWidget {
  final AnalysisArgs args;
  const AnalysisScreen({super.key, required this.args});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _apiDone = false;
  bool _animDone = false;
  bool _waitingForApi = false;
  SkinAnalysisResult? _pendingNav;

  static const _bg = Color(0xFFF0ECF8);
  static const _accent = Color(0xFF7060AA);
  static const _textDark = Color(0xFF2D2050);
  static const _textMuted = Color(0xFF9490B0);

  static const _steps = [
    'Rasm tahlilga tayyorlanmoqda',
    "Serverga jo'natilmoqda",
    'Teri holati aniqlanmoqda',
    'Natijalar tayyorlanmoqda',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _ctrl.forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _animDone = true);
        if (!_apiDone && mounted) setState(() => _waitingForApi = true);
        _tryNavigate();
      }
    });
    _runAnalysis();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Converts domain concern scores (0-100 int) to models scores (0-1 double).
  static Map<String, double>? _toScores(Map<SkinConcern, int>? concerns) {
    if (concerns == null) return null;
    return concerns.map((k, v) => MapEntry(k.name, v / 100.0));
  }

  Future<void> _runAnalysis() async {
    final skinResult = SkinLogic.analyze(widget.args.quizAnswers);

    CloudSkinData? cloudData;
    final imagePath = widget.args.imagePath;

    if (imagePath != null && File(imagePath).existsSync()) {
      try {
        cloudData = await GetIt.instance<SkinAnalysisRepository>()
            .analyze(File(imagePath));
      } catch (e, st) {
        AppLogger.error('Cloud analysis failed, quiz fallback', e, st);
      }
    }

    // Quiz determines skin type (12 questions); cloud adds per-concern scores.
    _pendingNav = SkinAnalysisResult(
      skinType: skinResult.skinType,
      skinTypeCode: skinResult.skinTypeCode,
      baseRecommendation: skinResult.baseRecommendation,
      additionalBlocks: skinResult.additionalBlocks,
      source: cloudData != null
          ? AnalysisSource.cameraAnalysis
          : AnalysisSource.quizEstimate,
      scores: _toScores(cloudData?.concerns),
      takenAt: cloudData?.takenAt,
    );

    if (mounted) {
      setState(() {
        _apiDone = true;
        _waitingForApi = false;
      });
    }
    _tryNavigate();
  }

  void _tryNavigate() {
    if (!_animDone || !_apiDone || !mounted) return;
    final nav = _pendingNav;
    if (nav == null) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.go('/results', extra: nav);
    });
  }

  bool _isDone(int i) {
    if (_waitingForApi && i == _steps.length - 1) return false;
    return _ctrl.value > (i + 1) / _steps.length;
  }

  bool _isActive(int i) {
    if (_waitingForApi && i == _steps.length - 1) return true;
    return _ctrl.value > i / _steps.length && !_isDone(i);
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
                widget.args.imagePath != null
                    ? 'Rasmingiz cloud orqali tahlil qilinmoqda'
                    : 'Savollaringiz asosida tahlil qilinmoqda',
                style: GoogleFonts.nunito(fontSize: 14, color: _textMuted),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 56),
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
                          child: _waitingForApi
                              ? const CircularProgressIndicator(
                                  strokeWidth: 10,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(_accent),
                                )
                              : CircularProgressIndicator(
                                  value: _ctrl.value,
                                  strokeWidth: 10,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          _accent),
                                ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _waitingForApi ? '99%' : '$pct%',
                              style: GoogleFonts.nunito(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              _waitingForApi ? 'kutilmoqda' : 'tayyor',
                              style: GoogleFonts.nunito(
                                  fontSize: 13, color: _textMuted),
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
              final done = _isDone(i);
              final active = _isActive(i);
              return Padding(
                padding:
                    EdgeInsets.only(bottom: i < _steps.length - 1 ? 16 : 0),
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
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : active
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(_accent),
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
                          fontWeight: active || done
                              ? FontWeight.w700
                              : FontWeight.w500,
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
