import 'package:real_beauty_ai/core/l10n/localized_text.dart';

enum QuestionType { scale, textarea, choice }

class QuizGroup {
  const QuizGroup({required this.title, this.icon = '', required this.range});

  final LocalizedText title;
  final String icon;
  final (int, int) range;
}

/// One question, in every language the app ships in.
///
/// The copy is [LocalizedText] rather than a plain String because a
/// questionnaire is content, not interface: it grows and is reworded on its own
/// schedule, and holding the three languages side by side means a new question
/// cannot be added with a translation missing — the constructor requires all
/// three and the compiler enforces it.
class QuizQuestion {
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

  final int index;

  /// Stable across every language and every rewording — this is what the
  /// scoring engine and the stored profile key off, so it must never be
  /// derived from the copy.
  final String id;
  final LocalizedText text;
  final QuestionType type;
  final LocalizedText? startLabel;
  final LocalizedText? endLabel;
  final List<LocalizedText>? options;
  final List<LocalizedText>? scaleLabels;
  final LocalizedText? hint;
}
