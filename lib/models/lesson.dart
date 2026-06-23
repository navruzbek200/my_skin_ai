import 'package:flutter/material.dart';

enum LessonStepType { intro, fact, list, tip }

class LessonStep {
  final LessonStepType type;
  final String title;
  final String body;
  final List<String>? items;
  final String? keyword;

  const LessonStep({
    required this.type,
    required this.title,
    required this.body,
    this.items,
    this.keyword,
  });
}

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String duration;
  final String level;
  final Color color;
  final List<LessonStep> steps;

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
}
