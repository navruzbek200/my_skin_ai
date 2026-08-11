import 'package:flutter/material.dart';

class ArticleSection {
  final String heading;
  final String body;
  const ArticleSection({required this.heading, required this.body});
}

class Article {
  final IconData icon;

  /// Accent for this article: the icon, the "Maqola" label and the bar on the
  /// left edge of its card all take their colour from here.
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
