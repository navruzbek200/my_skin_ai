import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';

enum LessonStepType { intro, fact, list, tip }

class LessonStep {
  const LessonStep({
    required this.type,
    required this.title,
    required this.body,
    this.items,
    this.keyword,
  });

  final LessonStepType type;
  final LocalizedText title;
  final LocalizedText body;
  final List<LocalizedText>? items;

  /// The word pulled out and set large behind the step. Some are ingredient
  /// names, identical in every language; others are ordinary words that have
  /// to be translated, which is why this is a [LocalizedText] and not a String.
  final LocalizedText? keyword;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.duration,
    required this.level,
    required this.color,
    required this.steps,
  });

  /// Stable across languages and rewordings.
  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final LocalizedText category;
  final LocalizedText duration;
  final LocalizedText level;
  final Color color;
  final List<LessonStep> steps;
}
