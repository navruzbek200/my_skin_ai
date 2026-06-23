class RoutineStep {
  final String id;
  final String title;
  const RoutineStep({required this.id, required this.title});
}

class DailyRoutine {
  final List<RoutineStep> morning;
  final List<RoutineStep> evening;
  const DailyRoutine({required this.morning, required this.evening});
}
