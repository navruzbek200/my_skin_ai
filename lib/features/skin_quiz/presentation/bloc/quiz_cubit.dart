import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/data/quiz_data.dart';
import 'package:real_beauty_ai/models/quiz_question.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(_initial());

  static QuizInProgress _initial() {
    final answers = List<dynamic>.generate(quizQuestions.length, (i) {
      switch (quizQuestions[i].type) {
        case QuestionType.scale:
          return 0;
        case QuestionType.choice:
          return -1;
        case QuestionType.textarea:
          return '';
      }
    });
    return QuizInProgress(
      currentIndex: 0,
      answers: answers,
      isMovingForward: true,
    );
  }

  void setAnswer(dynamic value) {
    final s = state as QuizInProgress;
    final updated = List<dynamic>.from(s.answers)..[s.currentIndex] = value;
    emit(s.copyWith(answers: updated));
  }

  void next() {
    final s = state as QuizInProgress;
    if (s.currentIndex < quizQuestions.length - 1) {
      emit(s.copyWith(
        currentIndex: s.currentIndex + 1,
        isMovingForward: true,
      ));
    } else {
      emit(QuizCompleted(List<dynamic>.from(s.answers)));
    }
  }

  void previous() {
    final s = state as QuizInProgress;
    if (s.currentIndex > 0) {
      emit(s.copyWith(
        currentIndex: s.currentIndex - 1,
        isMovingForward: false,
      ));
    }
  }

  bool isCurrentAnswered() {
    final s = state as QuizInProgress;
    if (quizQuestions[s.currentIndex].type == QuestionType.choice) {
      return s.answers[s.currentIndex] is int &&
          (s.answers[s.currentIndex] as int) >= 0;
    }
    return true;
  }

  bool get hasAnyAnswer {
    final s = state as QuizInProgress;
    for (int i = 0; i < s.answers.length; i++) {
      final q = quizQuestions[i];
      final a = s.answers[i];
      if (q.type == QuestionType.choice && a is int && a >= 0) return true;
      if (q.type == QuestionType.textarea && a is String && a.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
