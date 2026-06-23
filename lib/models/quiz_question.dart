enum QuestionType { scale, textarea, choice }

class QuizGroup {
  final String title;
  final String icon;
  final (int, int) range;
  const QuizGroup({required this.title, this.icon = '', required this.range});
}

class QuizQuestion {
  final int index;
  final String id;
  final String text;
  final QuestionType type;
  final String? startLabel;
  final String? endLabel;
  final List<String>? options;
  final List<String>? scaleLabels;
  final String? hint;

  const QuizQuestion({
    required this.index,
    required this.id,
    required this.text,
    required this.type,
    this.startLabel,
    this.endLabel,
    this.options,
    this.scaleLabels,
    this.hint,
  });
}
