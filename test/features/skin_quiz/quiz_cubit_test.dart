import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/data/quiz_data.dart';
import 'package:real_beauty_ai/features/skin_quiz/presentation/bloc/quiz_cubit.dart';
import 'package:real_beauty_ai/models/quiz_question.dart';

/// Runs the quiz to the end, picking an answer on every question.
QuizCubit _completed() {
  final cubit = QuizCubit();
  for (var i = 0; i < quizQuestions.length; i++) {
    cubit.setAnswer(quizQuestions[i].type == QuestionType.textarea ? 'x' : 0);
    cubit.next();
  }
  return cubit;
}

void main() {
  group('in progress', () {
    test('starts on the first question', () {
      final state = QuizCubit().state as QuizInProgress;
      expect(state.currentIndex, 0);
      expect(state.answers.length, quizQuestions.length);
    });

    test('previous() on the first question stays put', () {
      final cubit = QuizCubit();
      cubit.previous();
      expect((cubit.state as QuizInProgress).currentIndex, 0);
    });

    test('an unanswered choice question blocks the next step', () {
      final firstChoice =
          quizQuestions.indexWhere((q) => q.type == QuestionType.choice);
      // The shipping set is all scales; this guards the rule for whenever a
      // choice question is added back.
      if (firstChoice == -1) return;

      final cubit = QuizCubit();
      for (var i = 0; i < firstChoice; i++) {
        cubit.next();
      }
      expect(cubit.isCurrentAnswered(), isFalse);
      cubit.setAnswer(1);
      expect(cubit.isCurrentAnswered(), isTrue);
    });
  });

  // A scale question starts at 0 and 0 is also a valid pick, so the answer list
  // alone cannot tell "answered" from "untouched". Every question in the
  // shipping set is a scale, which left hasAnyAnswer permanently false — and
  // that flag is what decides whether backing out of the quiz asks first.
  group('leaving the quiz', () {
    test('an untouched quiz has nothing to lose', () {
      expect(QuizCubit().hasAnyAnswer, isFalse);
    });

    test('one tap on a scale question counts as work worth keeping', () {
      final cubit = QuizCubit();
      cubit.setAnswer(0);
      expect(cubit.hasAnyAnswer, isTrue);
    });

    test('advancing without picking anything still counts as untouched', () {
      final cubit = QuizCubit();
      cubit.next();
      cubit.next();
      expect(cubit.hasAnyAnswer, isFalse);
    });
  });

  // Every one of these used to throw. The finished quiz stayed on the
  // navigator underneath the scan screen, so pressing back there landed on it
  // and called straight into methods that opened with `state as QuizInProgress`.
  group('after completion', () {
    test('reaches QuizCompleted carrying every answer', () {
      final cubit = _completed();
      final state = cubit.state as QuizCompleted;
      expect(state.answers.length, quizQuestions.length);
    });

    test('hasAnyAnswer reads the finished answers instead of throwing', () {
      expect(_completed().hasAnyAnswer, isTrue);
    });

    test('previous() is inert', () {
      final cubit = _completed();
      cubit.previous();
      expect(cubit.state, isA<QuizCompleted>());
    });

    test('next() is inert', () {
      final cubit = _completed();
      cubit.next();
      expect(cubit.state, isA<QuizCompleted>());
    });

    test('setAnswer() is inert', () {
      final cubit = _completed();
      final before = List<dynamic>.from((cubit.state as QuizCompleted).answers);
      cubit.setAnswer(99);
      expect((cubit.state as QuizCompleted).answers, before);
    });

    test('isCurrentAnswered() does not claim an unanswered question', () {
      expect(_completed().isCurrentAnswered(), isTrue);
    });
  });
}
