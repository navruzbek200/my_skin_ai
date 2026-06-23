import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/colors.dart';
import '../../data/yoga_data.dart';
import '../../services/video_playback_manager.dart';
import 'lesson_styles.dart';
import 'video_error_view.dart';
import 'video_placeholder.dart';

enum _VideoState { idle, loading, ready, error }

// Aspect ratio of uncropped source clips (720×1280 portrait).
const double _kSourceAspect = 720 / 1280;

class YogaVideoCard extends StatefulWidget {
  final YogaExercise exercise;
  final int index;

  const YogaVideoCard({
    super.key,
    required this.exercise,
    required this.index,
  });

  @override
  State<YogaVideoCard> createState() => _YogaVideoCardState();
}

class _YogaVideoCardState extends State<YogaVideoCard>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _ctrl;
  _VideoState _state = _VideoState.idle;
  bool _isVisible = false;

  @override
  bool get wantKeepAlive => true;

  String get _id => 'yoga_${widget.index}';

  @override
  void initState() {
    super.initState();
    VideoPlaybackManager.instance.register(_id, _onForcePause);
  }

  @override
  void dispose() {
    VideoPlaybackManager.instance.unregister(_id);
    _ctrl?.dispose();
    super.dispose();
  }

  // ── Manager callbacks ────────────────────────────────────────────────────────

  void _onForcePause() {
    if (!mounted) return;
    _ctrl?.pause();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    if (_state == _VideoState.loading || _state == _VideoState.ready) return;
    if (!mounted) return;
    setState(() => _state = _VideoState.loading);

    final ctrl = VideoPlayerController.asset(widget.exercise.videoPath);
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setVolume(0.0);
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      _ctrl = ctrl;
      setState(() => _state = _VideoState.ready);
      if (_isVisible) {
        VideoPlaybackManager.instance.requestPlay(_id);
        _ctrl?.play();
      }
    } catch (_) {
      ctrl.dispose();
      if (!mounted) return;
      setState(() => _state = _VideoState.error);
    }
  }

  void _release() {
    _ctrl?.dispose();
    _ctrl = null;
    VideoPlaybackManager.instance.notifyHidden(_id);
    if (mounted) setState(() => _state = _VideoState.idle);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final nowVisible = info.visibleFraction >= 0.5;
    if (nowVisible == _isVisible) return;
    _isVisible = nowVisible;

    if (nowVisible) {
      if (_state == _VideoState.idle || _state == _VideoState.error) {
        _initialize();
      } else if (_state == _VideoState.ready) {
        VideoPlaybackManager.instance.requestPlay(_id);
        _ctrl?.play();
      }
    } else {
      VideoPlaybackManager.instance.notifyHidden(_id);
      _ctrl?.pause();
      if (info.visibleFraction == 0.0) _release();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ex = widget.exercise;
    return VisibilityDetector(
      key: Key(_id),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: () => HapticFeedback.selectionClick(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(LessonStyles.yogaCardRadius),
            border: Border.all(color: ex.color.withValues(alpha: 0.20)),
            boxShadow: LessonStyles.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VideoRegion(
                exercise: ex,
                index: widget.index,
                state: _state,
                ctrl: _ctrl,
                onRetry: () {
                  if (!mounted) return;
                  setState(() => _state = _VideoState.idle);
                  if (_isVisible) _initialize();
                },
              ),
              _InfoPanel(exercise: ex),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 40 + widget.index * 70))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.04);
  }
}

// ── Video region ─────────────────────────────────────────────────────────────

class _VideoRegion extends StatelessWidget {
  final YogaExercise exercise;
  final int index;
  final _VideoState state;
  final VideoPlayerController? ctrl;
  final VoidCallback onRetry;

  const _VideoRegion({
    required this.exercise,
    required this.index,
    required this.state,
    required this.ctrl,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Use actual ratio when ready; handles original (portrait) and
    // ffmpeg-re-encoded (landscape) files automatically.
    final double aspect = state == _VideoState.ready && ctrl != null
        ? ctrl!.value.aspectRatio
        : _kSourceAspect;

    // Clip only for portrait source; landscape means file was re-encoded.
    final bool doClip =
        aspect < 1.0 && exercise.clipHeightFactor < 1.0;

    Widget videoCore = AspectRatio(
      aspectRatio: aspect,
      child: switch (state) {
        _VideoState.ready   => VideoPlayer(ctrl!),
        _VideoState.loading =>
          VideoPlaceholder(color: exercise.color, icon: exercise.icon),
        _VideoState.error   => VideoErrorView(
            color: exercise.color,
            icon: exercise.icon,
            onRetry: onRetry,
          ),
        _VideoState.idle    =>
          VideoPlaceholder(color: exercise.color, icon: exercise.icon),
      },
    );

    if (doClip) {
      videoCore = ClipRect(
        child: Align(
          alignment: Alignment(0, exercise.clipAlignmentY),
          heightFactor: exercise.clipHeightFactor,
          child: videoCore,
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(LessonStyles.yogaCardRadius),
      ),
      child: Stack(
        children: [
          videoCore,
          Positioned(
            top: 10,
            left: 12,
            child: _NumberBadge(number: index + 1, color: exercise.color),
          ),
        ],
      ),
    );
  }
}

// ── Info panel ───────────────────────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  final YogaExercise exercise;
  const _InfoPanel({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: name (left) + target glass chip (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _TargetChip(label: exercise.target),
            ],
          ),
          const SizedBox(height: 7),
          // Row 2: duration meta
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                exercise.duration,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 3: description (no accent bar — clean white card)
          Text(
            exercise.description,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _NumberBadge extends StatelessWidget {
  final int number;
  final Color color;
  const _NumberBadge({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  const _TargetChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
