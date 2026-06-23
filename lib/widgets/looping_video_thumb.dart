import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/colors.dart';

enum _ThumbState { loading, ready, error }

/// Muted, looping video thumbnail that fills its parent with BoxFit.cover.
///
/// [pauseSignal] — when true pauses playback, when false resumes. Designed for
/// a single screen-level WidgetsBindingObserver toggling one notifier for all
/// visible thumbs rather than one observer per widget.
class LoopingVideoThumb extends StatefulWidget {
  final String assetPath;
  final ValueListenable<bool>? pauseSignal;

  const LoopingVideoThumb({
    super.key,
    required this.assetPath,
    this.pauseSignal,
  });

  @override
  State<LoopingVideoThumb> createState() => _LoopingVideoThumbState();
}

class _LoopingVideoThumbState extends State<LoopingVideoThumb> {
  VideoPlayerController? _ctrl;
  _ThumbState _state = _ThumbState.loading;

  @override
  void initState() {
    super.initState();
    widget.pauseSignal?.addListener(_onPauseSignal);
    _initialize();
  }

  @override
  void dispose() {
    widget.pauseSignal?.removeListener(_onPauseSignal);
    _ctrl?.dispose();
    super.dispose();
  }

  void _onPauseSignal() {
    if (widget.pauseSignal!.value) {
      _ctrl?.pause();
    } else if (_state == _ThumbState.ready) {
      _ctrl?.play();
    }
  }

  Future<void> _initialize() async {
    final ctrl = VideoPlayerController.asset(widget.assetPath);
    try {
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setVolume(0);
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      _ctrl = ctrl;
      setState(() => _state = _ThumbState.ready);
      // Don't autoplay if backgrounded during init
      if (widget.pauseSignal?.value != true) {
        ctrl.play();
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint(
          'LoopingVideoThumb failed for "${widget.assetPath}": $error',
        );
        debugPrintStack(stackTrace: stack);
      }
      await ctrl.dispose();
      if (!mounted) return;
      setState(() => _state = _ThumbState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _ThumbState.ready => RepaintBoundary(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _ctrl!.value.size.width,
                height: _ctrl!.value.size.height,
                child: VideoPlayer(_ctrl!),
              ),
            ),
          ),
        ),
      _ThumbState.loading => const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.muted),
              ),
            ),
          ),
        ),
      _ThumbState.error => const ColoredBox(
          color: Color(0xFFF0F0F0),
          child: Center(
            child: Icon(Icons.image_outlined, size: 28, color: AppColors.muted),
          ),
        ),
    };
  }
}
