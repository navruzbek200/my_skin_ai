import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/data/quiz_data.dart';
import 'package:real_beauty_ai/features/skin_quiz/presentation/bloc/quiz_cubit.dart';
import 'package:real_beauty_ai/models/quiz_question.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(),
      child: const _QuizBody(),
    );
  }
}

// ── Quiz body ─────────────────────────────────────────────────

class _QuizBody extends StatefulWidget {
  const _QuizBody();

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> with TickerProviderStateMixin {
  final _textControllers = <int, TextEditingController>{};
  late final AnimationController _slideCtrl;
  bool _forward = true;
  int _prevIndex = 0;
  bool _exiting = false;

  /// Last question actually rendered. Held so the screen has something to draw
  /// during the frame between completing the quiz and the route being replaced.
  QuizInProgress? _lastInProgress;

  static const _bg = Color(0xFFF0ECF8);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _textDark = Color(0xFF2D2050);
  static const _textMuted = Color(0xFF9490B0);
  static const _accent = Color(0xFF7060AA);
  static const _selectedBg = Color(0xFF7060AA);

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: 300.ms);
    _slideCtrl.forward();

    if (!LocalStore.instance.privacyAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPrivacyNotice());
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Dialogs ───────────────────────────────────────────────────

  void _showExitConfirm() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          context.l10n.quizExitTitle,
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: _textDark, fontSize: 17),
        ),
        content: Text(
          context.l10n.quizExitBody,
          style: GoogleFonts.nunito(fontSize: 14, color: _textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.commonCancel,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600, color: _textMuted, fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _exit();
            },
            child: Text(context.l10n.accountSignOut,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: _accent, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showValidationHint() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.quizSelectOne,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPrivacyNotice() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          context.l10n.quizPrivacyTitle,
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: _textDark, fontSize: 17),
        ),
        content: Text(
          context.l10n.quizPrivacyBody,
          style: GoogleFonts.nunito(
              fontSize: 13, color: const Color(0xFF4A4070), height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () {
              LocalStore.instance.acceptPrivacy();
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.quizAccept,
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: _accent, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────

  /// The one place that decides what "back" means, so the X button, the system
  /// back gesture and the predictive-back callback cannot drift apart: step to
  /// the previous question if there is one, otherwise leave the quiz.
  void _handleBack() {
    final cubit = context.read<QuizCubit>();
    final s = cubit.state;
    // Finished: the replacement route is already on its way in, and anything
    // done here would be undoing a quiz nobody is looking at any more.
    if (s is! QuizInProgress) return;
    // Only "Keyingi" used to commit what was typed, so leaving a free-text
    // question backwards dropped it from the answers. The text stayed in the
    // field, which hid the loss until the exit prompt decided there was
    // nothing worth warning about and closed the quiz on it.
    _syncTextarea(s.currentIndex);
    if (s.currentIndex > 0) {
      HapticFeedback.lightImpact();
      cubit.previous();
      return;
    }
    _tryExit();
  }

  /// Commits the text field for [index] to the cubit, if that question has one.
  void _syncTextarea(int index) {
    if (quizQuestions[index].type != QuestionType.textarea) return;
    final ctrl = _textControllers[index];
    if (ctrl != null) context.read<QuizCubit>().setAnswer(ctrl.text);
  }

  void _tryExit() {
    if (context.read<QuizCubit>().hasAnyAnswer) {
      _showExitConfirm();
    } else {
      _exit();
    }
  }

  // Guarded exit: prevents double-pop (back gesture + X tap, or double tap)
  // from popping the route below the quiz and leaving an empty navigator.
  void _exit() {
    if (_exiting) return;
    _exiting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        // Quiz was the only route (e.g. deep link) — go home instead of
        // popping into a black screen.
        context.go('/home');
      }
      // Still here a frame later means the route did not actually go away.
      // Leaving the latch set would silently swallow every later attempt to
      // close the quiz, so clear it and let the next tap try again.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _exiting = false;
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    });
    // A post-frame callback only runs after a frame, and a frame only happens
    // if something asked for one. Tapping X on the first question with nothing
    // answered marks no widget dirty, so the pop above sat queued until some
    // unrelated repaint — a "Keyingi" tap — finally produced a frame, and the
    // quiz closed then instead. Ask for the frame the callback is waiting on.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _goNext() {
    final cubit = context.read<QuizCubit>();
    // Read the index from the cubit, never from the state captured when this
    // button was built: a tap can be delivered after `previous()` has already
    // moved on, and acting on the stale index writes the answer to the wrong
    // question and advances from the wrong place.
    final state = cubit.state;
    if (state is! QuizInProgress) return;

    _syncTextarea(state.currentIndex);
    if (!cubit.isCurrentAnswered()) {
      _showValidationHint();
      return;
    }
    HapticFeedback.lightImpact();
    cubit.next();
  }

  // ── UI helpers ────────────────────────────────────────────────

  QuizGroup _group(int idx) {
    for (final g in quizGroups) {
      if (idx >= g.range.$1 && idx <= g.range.$2) return g;
    }
    return quizGroups.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is QuizInProgress && state.currentIndex != _prevIndex) {
          _forward = state.isMovingForward;
          _prevIndex = state.currentIndex;
          _slideCtrl.reset();
          _slideCtrl.forward();
        } else if (state is QuizCompleted) {
          // Replacing, not pushing. A pushed quiz stays on the stack under the
          // scan screen, and closing that lands back on a finished quiz: there
          // is no question left to draw, so the screen came up blank, and the
          // next back press ran the exit path against a completed state. The
          // quiz is done — it should not be somewhere "back" can return to.
          context.pushReplacement('/scan-instructions',
              extra: List<dynamic>.from(state.answers));
        }
      },
      builder: (context, state) {
        // Completion and the route swap are a frame apart, and for that frame
        // this route is still mounted with nothing left to show. Redrawing the
        // question it just finished keeps the handover silent; returning an
        // empty box flashed a blank screen instead.
        if (state is QuizInProgress) _lastInProgress = state;
        final s = state is QuizInProgress ? state : _lastInProgress;
        if (s == null) return const SizedBox.shrink();
        final question = quizQuestions[s.currentIndex];
        final progress = (s.currentIndex + 1) / quizQuestions.length;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, _) => _handleBack(),
          child: Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(s.currentIndex, progress),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _slideCtrl,
                      builder: (ctx, child) {
                        final t = CurvedAnimation(
                          parent: _slideCtrl,
                          curve: Curves.easeOutCubic,
                        ).value;
                        final dx =
                            _forward ? (1 - t) * 48.0 : (t - 1) * 48.0;
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child:
                              Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                        );
                      },
                      child: _buildBody(
                        key: ValueKey(s.currentIndex),
                        state: s,
                        question: question,
                      ),
                    ),
                  ),
                  _buildNav(s),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(int current, double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _handleBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    current > 0
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.close_rounded,
                    size: 16,
                    color: _textDark,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.quizTitle,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 38),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody({
    required Key key,
    required QuizInProgress state,
    required QuizQuestion question,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(state, question),
          const SizedBox(height: 14),
          _buildAnswerArea(state, question),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizInProgress state, QuizQuestion question) {
    final group = _group(state.currentIndex);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _cardBg,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.tr(group.title),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.quizQuestionNumber(state.currentIndex + 1),
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(question.text),
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textDark,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerArea(QuizInProgress state, QuizQuestion question) {
    return switch (question.type) {
      QuestionType.scale => _buildScale(state, question),
      QuestionType.textarea => _buildTextarea(state, question),
      QuestionType.choice => _buildChoice(state, question),
    };
  }

  Widget _buildScale(QuizInProgress state, QuizQuestion question) {
    final val = (state.answers[state.currentIndex] as int?) ?? 0;
    final labels = question.scaleLabels ?? [];
    return Column(
      children: List.generate(labels.length, (i) {
        return _OptionCard(
          label: context.tr(labels[i]),
          selected: i == val,
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<QuizCubit>().setAnswer(i);
          },
          selectedBg: _selectedBg,
        );
      }),
    );
  }

  Widget _buildTextarea(QuizInProgress state, QuizQuestion question) {
    _textControllers[state.currentIndex] ??= TextEditingController(
      text: state.answers[state.currentIndex] is String
          ? state.answers[state.currentIndex] as String
          : '',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            question.hint == null
                ? context.l10n.quizWriteAnswer
                : context.tr(question.hint!),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _textControllers[state.currentIndex],
            maxLines: 5,
            style: GoogleFonts.nunito(
                fontSize: 15, color: _textDark, height: 1.5),
            decoration: InputDecoration(
              hintText: question.hint == null
                  ? context.l10n.quizWriteHere
                  : context.tr(question.hint!),
              hintStyle:
                  GoogleFonts.nunito(color: _textMuted, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: _accent, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoice(QuizInProgress state, QuizQuestion question) {
    final options = question.options ?? [];
    final selected = state.answers[state.currentIndex] is int
        ? state.answers[state.currentIndex] as int
        : -1;
    return Column(
      children: List.generate(options.length, (i) {
        return _OptionCard(
          label: context.tr(options[i]),
          selected: i == selected,
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<QuizCubit>().setAnswer(i);
          },
          selectedBg: _selectedBg,
        );
      }),
    );
  }

  Widget _buildNav(QuizInProgress state) {
    final isLast = state.currentIndex == quizQuestions.length - 1;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
      child: _PressButton(
        onTap: _goNext,
        color: _accent,
        child: Text(
          isLast ? 'Yakunlash' : 'Keyingi',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ── Option card ───────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedBg;

  const _OptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedBg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? selectedBg : const Color(0xFFE8EDF2),
            width: 1.5,
          ),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: 180.ms,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFFCDD5DF),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF2D3748),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Press button ──────────────────────────────────────────────

class _PressButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final Widget child;
  const _PressButton(
      {required this.onTap, required this.color, required this.child});

  @override
  State<_PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<_PressButton> {
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
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _pressed ? 0.2 : 0.35),
                blurRadius: _pressed ? 6 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
