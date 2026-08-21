import 'package:real_beauty_ai/core/l10n/localized_text.dart';

class RoutineStep {
  const RoutineStep({required this.id, required this.title});

  /// Stable across languages. This is what per-day completion is stored under,
  /// so a title that changed with the interface language would silently reset
  /// somebody's ticks the moment they switched.
  final String id;

  /// The instruction, in every language the app ships in — the engine picks
  /// which sentence to say, the widget layer picks which language to say it in.
  final LocalizedText title;
}

class DailyRoutine {
  final List<RoutineStep> morning;
  final List<RoutineStep> evening;
  const DailyRoutine({required this.morning, required this.evening});
}
