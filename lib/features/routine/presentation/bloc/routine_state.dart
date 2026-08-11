part of 'routine_cubit.dart';

/// One line of the day's plan: what to do, and whether it is done.
class RoutineTask extends Equatable {
  final RoutineStep step;
  final bool done;

  const RoutineTask({required this.step, required this.done});

  String get id => step.id;

  RoutineTask copyWith({bool? done}) => RoutineTask(
        step: step,
        done: done ?? this.done,
      );

  @override
  List<Object?> get props => [step.id, step.title, done];
}

sealed class RoutineState extends Equatable {
  const RoutineState();

  @override
  List<Object?> get props => [];
}

class RoutineLoading extends RoutineState {
  const RoutineLoading();
}

/// The quiz has not been taken, so there is nothing to plan yet.
class RoutineNoProfile extends RoutineState {
  const RoutineNoProfile();
}

class RoutineReady extends RoutineState {
  final List<RoutineTask> morning;
  final List<RoutineTask> evening;

  /// Day key the tasks were built for. Used to notice a midnight rollover.
  final String day;

  /// day key → whether that day cleared the streak threshold.
  final Map<String, bool> streaks;

  /// day key → 0..1 completion.
  final Map<String, double> dailyProgress;

  const RoutineReady({
    required this.morning,
    required this.evening,
    required this.day,
    required this.streaks,
    required this.dailyProgress,
  });

  List<RoutineTask> get all => [...morning, ...evening];

  int get total => morning.length + evening.length;
  int get doneCount => all.where((t) => t.done).length;
  double get progress => total > 0 ? doneCount / total : 0.0;

  int get morningDone => morning.where((t) => t.done).length;
  int get eveningDone => evening.where((t) => t.done).length;

  /// Consecutive days ending today that cleared the threshold.
  int get currentStreak {
    final today = DateTime.now();
    var streak = 0;
    if (streaks[LocalStore.dateKey(today)] == true) streak++;
    for (var i = 1; i <= 365; i++) {
      final d = today.subtract(Duration(days: i));
      if (streaks[LocalStore.dateKey(d)] != true) break;
      streak++;
    }
    return streak;
  }

  RoutineReady copyWith({
    List<RoutineTask>? morning,
    List<RoutineTask>? evening,
    Map<String, bool>? streaks,
    Map<String, double>? dailyProgress,
  }) =>
      RoutineReady(
        morning: morning ?? this.morning,
        evening: evening ?? this.evening,
        day: day,
        streaks: streaks ?? this.streaks,
        dailyProgress: dailyProgress ?? this.dailyProgress,
      );

  @override
  List<Object?> get props =>
      [morning, evening, day, streaks, dailyProgress];
}

/// The profile exists but the plan could not be built. Rare — the engine is
/// pure — but a corrupt stored profile lands here rather than on a blank page.
class RoutineFailure extends RoutineState {
  final String message;
  const RoutineFailure(this.message);

  @override
  List<Object?> get props => [message];
}
