import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/routine/domain/routine_engine.dart';
import 'package:real_beauty_ai/features/routine/domain/routine_step.dart';
import 'package:real_beauty_ai/services/local_store.dart';

part 'routine_state.dart';

/// Owns the Bugun screen's day: which steps the profile calls for, what has
/// been ticked off, and the streak history.
///
/// All of this used to live in the widget's `setState`, which meant the screen
/// could not be tested without pumping it and the rules were interleaved with
/// layout. The widget is now a renderer: it holds no routine state of its own.
class RoutineCubit extends Cubit<RoutineState> {
  RoutineCubit({LocalStore? store, DateTime Function()? clock})
    : _store = store ?? LocalStore.instance,
      _now = clock ?? DateTime.now,
      super(const RoutineLoading());

  final LocalStore _store;

  /// Injected so tests can pin the date. The routine changes with the weekday
  /// (active nights, mask night), which is untestable against a real clock.
  final DateTime Function() _now;

  String get _todayKey => LocalStore.dateKey(_now());

  /// Builds today's plan. Safe to call repeatedly — the screen calls it again
  /// on resume to catch a midnight rollover.
  Future<void> load() async {
    try {
      final profile = _store.getSkinProfile();
      if (profile == null) {
        AppLogger.info('Routine: no skin profile yet');
        emit(const RoutineNoProfile());
        return;
      }

      final concerns = profile.additionalBlocks
          .map((b) => b['code'] ?? '')
          .where((c) => c.isNotEmpty)
          .toSet();

      final routine = RoutineEngine.generate(
        skinType: profile.skinType,
        concerns: concerns,
        date: _now(),
      );

      final day = _todayKey;
      final saved = _store.getRoutine(day);

      // Nothing here touches the network: the profile, the weekday and the
      // ticked-off steps all live on the device, so the plan is ready in one
      // emit and the screen never shows a spinner for it.
      emit(_ready(routine, saved, day));

      AppLogger.info(
        'Routine ready',
        '${routine.morning.length + routine.evening.length} steps',
      );
    } catch (e, st) {
      AppLogger.error('Routine build failed', e, st);
      emit(const RoutineFailure('Rejani tuzishda xato yuz berdi'));
    }
  }

  /// Assembles a [RoutineReady] from the pieces, including the two history
  /// maps, which both have to be overlaid with today's live counts.
  RoutineReady _ready(
    DailyRoutine routine,
    Map<String, bool> done,
    String day,
  ) {
    RoutineTask toTask(RoutineStep step) =>
        RoutineTask(step: step, done: done[step.id] == true);

    final morning = routine.morning.map(toTask).toList();
    final evening = routine.evening.map(toTask).toList();
    final total = morning.length + evening.length;
    final doneCount = [...morning, ...evening].where((t) => t.done).length;

    return RoutineReady(
      morning: morning,
      evening: evening,
      day: day,
      streaks: _streaksWithToday(total, doneCount, day),
      dailyProgress: _progressWithToday(total, doneCount, day),
    );
  }

  /// Ticks a step on or off and persists it.
  ///
  /// If the day rolled over while the app sat open, this rebuilds instead of
  /// writing — otherwise today's first tap would be filed under yesterday.
  Future<void> toggle(String taskId) async {
    final current = state;
    if (current is! RoutineReady) return;
    if (current.day != _todayKey) {
      await load();
      return;
    }

    // An id no step owns means the plan changed under a stale tap — a card
    // from yesterday's layout, or a stray call. Writing it through would put a
    // key in storage that nothing ever reads back, and the lookup below would
    // throw on the empty result.
    if (!current.all.any((t) => t.id == taskId)) {
      AppLogger.error('Routine toggle: no step "$taskId" in today\'s plan');
      return;
    }

    try {
      List<RoutineTask> flip(List<RoutineTask> tasks) => tasks
          .map((t) => t.id == taskId ? t.copyWith(done: !t.done) : t)
          .toList();

      final morning = flip(current.morning);
      final evening = flip(current.evening);
      final all = [...morning, ...evening];
      final nowDone = all.firstWhere((t) => t.id == taskId).done;
      final total = all.length;
      final doneCount = all.where((t) => t.done).length;

      emit(
        current.copyWith(
          morning: morning,
          evening: evening,
          streaks: _streaksWithToday(total, doneCount, current.day),
          dailyProgress: _progressWithToday(total, doneCount, current.day),
        ),
      );

      // Written after the emit: the tick must feel instant, and a failed write
      // is worth reporting but not worth blocking the animation on.
      await _store.setTaskDone(current.day, taskId, nowDone);
    } catch (e, st) {
      AppLogger.error('Routine toggle failed for "$taskId"', e, st);
    }
  }

  /// Rebuilds only if the calendar day has moved on. Cheap enough to call from
  /// a lifecycle callback or a rebuild.
  Future<void> refreshIfDayChanged() async {
    final current = state;
    if (current is RoutineReady && current.day == _todayKey) return;
    await load();
  }

  // ── History ──────────────────────────────────────────────────
  //
  // Stored history covers past days only; today is still in flight, so both
  // maps are overlaid with the live counts before they reach the UI.

  Map<String, bool> _streaksWithToday(int total, int doneCount, String day) {
    final streaks = _store.getStreaks(total);
    streaks[day] = LocalStore.isStreakDay(doneCount, total);
    return streaks;
  }

  Map<String, double> _progressWithToday(int total, int doneCount, String day) {
    final progress = _store.getDailyProgress(total);
    progress[day] = total > 0 ? (doneCount / total).clamp(0.0, 1.0) : 0.0;
    return progress;
  }
}
