import 'package:flutter/material.dart';

class ArticleSection {
  final String heading;
  final String body;
  const ArticleSection({required this.heading, required this.body});
}

class Article {
  final IconData icon;
  // Kept for model compatibility; card UI uses AppColors.primary instead of
  // per-item iconColor to avoid a rainbow palette.
  final Color iconColor;
  final String title;
  final String duration;
  final String summary;
  final List<ArticleSection> sections;

  const Article({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.duration,
    required this.summary,
    required this.sections,
  });
}
