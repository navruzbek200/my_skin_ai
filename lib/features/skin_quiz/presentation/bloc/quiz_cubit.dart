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

  /// The in-progress state, or null once the quiz is finished.
  ///
  /// Every mutator used to open with `state as QuizInProgress`. That holds for
  /// as long as the only caller is a live question screen — and stops holding
  /// the moment the finished quiz is still on the navigator underneath the scan
  /// screen, because the back button there lands on it and calls straight in.
  /// A cast throws where a null check simply declines.
  QuizInProgress? get _inProgress {
    final s = state;
    return s is QuizInProgress ? s : null;
  }

  /// Whether the person has picked anything at all.
  ///
  /// It cannot be read back out of [answers]: a scale question starts at 0,
  /// which is also a legitimate choice, so "untouched" and "picked the first
  /// option" are the same value there. Every question in the current set is a
  /// scale, which made [hasAnyAnswer] permanently false — and that is what
  /// decides whether leaving the quiz asks before throwing the answers away.
  bool _interacted = false;

  void setAnswer(dynamic value) {
    final s = _inProgress;
    if (s == null) return;
    _interacted = true;
    final updated = List<dynamic>.from(s.answers)..[s.currentIndex] = value;
    emit(s.copyWith(answers: updated));
  }

  void next() {
    final s = _inProgress;
    if (s == null) return;
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
    final s = _inProgress;
    if (s == null || s.currentIndex == 0) return;
    emit(s.copyWith(
      currentIndex: s.currentIndex - 1,
      isMovingForward: false,
    ));
  }

  bool isCurrentAnswered() {
    final s = _inProgress;
    // A finished quiz answered everything it was going to; saying otherwise
    // would make the caller re-run validation on a question nobody is on.
    if (s == null) return true;
    if (quizQuestions[s.currentIndex].type == QuestionType.choice) {
      return s.answers[s.currentIndex] is int &&
          (s.answers[s.currentIndex] as int) >= 0;
    }
    return true;
  }

  /// Answers as they stand, whether the quiz is mid-flight or finished.
  List<dynamic> get answers => switch (state) {
        QuizInProgress(:final answers) => answers,
        QuizCompleted(:final answers) => answers,
        _ => const [],
      };

  /// True when leaving now would throw away work the person actually did.
  bool get hasAnyAnswer {
    if (_interacted) return true;
    final current = answers;
    for (var i = 0; i < current.length && i < quizQuestions.length; i++) {
      final q = quizQuestions[i];
      final a = current[i];
      if (q.type == QuestionType.choice && a is int && a >= 0) return true;
      if (q.type == QuestionType.textarea && a is String && a.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
