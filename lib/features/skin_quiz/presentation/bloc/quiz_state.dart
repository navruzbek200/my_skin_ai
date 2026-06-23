part of 'quiz_cubit.dart';

abstract class QuizState {}

class QuizInProgress extends QuizState {
  final int currentIndex;
  final List<dynamic> answers;
  final bool isMovingForward;

  QuizInProgress({
    required this.currentIndex,
    required this.answers,
    required this.isMovingForward,
  });

  QuizInProgress copyWith({
    int? currentIndex,
    List<dynamic>? answers,
    bool? isMovingForward,
  }) =>
      QuizInProgress(
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        isMovingForward: isMovingForward ?? this.isMovingForward,
      );
}

class QuizCompleted extends QuizState {
  final List<dynamic> answers;
  QuizCompleted(this.answers);
}
