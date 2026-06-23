import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/models/lesson.dart';
import 'package:real_beauty_ai/widgets/lessons/steps/fact_step.dart';
import 'package:real_beauty_ai/widgets/lessons/steps/intro_step.dart';
import 'package:real_beauty_ai/widgets/lessons/steps/list_step.dart';
import 'package:real_beauty_ai/widgets/lessons/steps/tip_step.dart';
import 'package:real_beauty_ai/widgets/primary_button.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _stepIndex = 0;
  int _direction = 1;

  Lesson get _lesson => widget.lesson;
  LessonStep get _step => _lesson.steps[_stepIndex];
  bool get _isLast => _stepIndex == _lesson.steps.length - 1;

  void _next() {
    HapticFeedback.lightImpact();
    if (_isLast) {
      Navigator.pop(context);
    } else {
      setState(() {
        _direction = 1;
        _stepIndex++;
      });
    }
  }

  void _prevStep() {
    if (_stepIndex == 0) return;
    HapticFeedback.lightImpact();
    setState(() {
      _direction = -1;
      _stepIndex--;
    });
  }

  void _onSwipe(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v < -300 && !_isLast) _next();
    if (v > 300) _prevStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              lesson: _lesson,
              stepIndex: _stepIndex,
              onBack: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            _ProgressDots(lesson: _lesson, stepIndex: _stepIndex),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: _onSwipe,
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  transitionBuilder: (child, anim) {
                    final slide = Tween<Offset>(
                      begin: Offset(_direction * 0.3, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    );
                    return SlideTransition(
                      position: slide,
                      child: FadeTransition(opacity: anim, child: child),
                    );
                  },
                  child: _StepContent(
                    key: ValueKey(_stepIndex),
                    step: _step,
                    color: _lesson.color,
                  ),
                ),
              ),
            ),
            _BottomNav(isLast: _isLast, onNext: _next),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Lesson lesson;
  final int stepIndex;
  final VoidCallback onBack;

  const _Header({
    required this.lesson,
    required this.stepIndex,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (stepIndex + 1) / lesson.steps.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                label: 'Ortga',
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${stepIndex + 1} / ${lesson.steps.length} qadam',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: 400.ms,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(lesson.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress dots ──────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final Lesson lesson;
  final int stepIndex;

  const _ProgressDots({required this.lesson, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(lesson.steps.length, (i) {
          final active = i == stepIndex;
          return AnimatedContainer(
            duration: 300.ms,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? lesson.color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step content dispatcher ────────────────────────────────────

class _StepContent extends StatelessWidget {
  final LessonStep step;
  final Color color;

  const _StepContent({super.key, required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: switch (step.type) {
        LessonStepType.intro => IntroStep(step: step, color: color),
        LessonStepType.fact  => FactStep(step: step, color: color),
        LessonStepType.list  => ListStep(step: step, color: color),
        LessonStepType.tip   => TipStep(step: step, color: color),
      },
    );
  }
}

// ── Bottom nav ─────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final bool isLast;
  final VoidCallback onNext;

  const _BottomNav({required this.isLast, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: PrimaryButton(
        label: isLast ? 'Darsni tugatish ✓' : 'Keyingi →',
        onPressed: onNext,
      ),
    );
  }
}
