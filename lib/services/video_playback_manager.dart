import 'package:flutter/widgets.dart';

/// LRU singleton that enforces at most [_maxConcurrent] playing/initialized
/// VideoPlayerControllers at once. When a new card requests play and the
/// limit is reached, the least-recently-visible controller is force-paused
/// and its slot freed.
///
/// Also observes app lifecycle and pauses all controllers on background.
class VideoPlaybackManager with WidgetsBindingObserver {
  VideoPlaybackManager._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static final VideoPlaybackManager instance = VideoPlaybackManager._();

  static const int _maxConcurrent = 2;

  /// Most-recently-active id at index 0.
  final List<String> _active = [];
  final Map<String, VoidCallback> _pauseCallbacks = {};

  // ── Registration ──────────────────────────────────────────

  void register(String id, VoidCallback onForcePause) {
    _pauseCallbacks[id] = onForcePause;
  }

  void unregister(String id) {
    _active.remove(id);
    _pauseCallbacks.remove(id);
  }

  // ── Playback control ──────────────────────────────────────

  /// Card calls this when it becomes visible and is ready to play.
  void requestPlay(String id) {
    _active.remove(id);

    // Evict LRU until under limit
    while (_active.length >= _maxConcurrent) {
      final lru = _active.removeLast();
      _pauseCallbacks[lru]?.call();
      assert(() {
        debugPrint('[VideoPlaybackManager] evicted "$lru" (LRU, active=${_active.length})');
        return true;
      }());
    }

    _active.insert(0, id);

    assert(() {
      debugPrint('[VideoPlaybackManager] playing "$id" — active=${_active.length}/$_maxConcurrent');
      return true;
    }());
  }

  /// Card calls this when it scrolls out of view (before releasing controller).
  void notifyHidden(String id) {
    _active.remove(id);
  }

  /// Pause every tracked controller (called on app background).
  void pauseAll() {
    for (final id in List<String>.from(_active)) {
      _pauseCallbacks[id]?.call();
    }
    _active.clear();
  }

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pauseAll();
    }
    // On resumed: VisibilityDetector callbacks re-fire for visible cards.
  }

  /// Visible active count (useful for debug assertions in tests).
  int get activeCount => _active.length;
}
