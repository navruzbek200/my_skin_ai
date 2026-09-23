import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/models/source.dart';

class ArticleSection {
  const ArticleSection({required this.heading, required this.body});

  final LocalizedText heading;
  final LocalizedText body;
}

class Article {
  const Article({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.duration,
    required this.summary,
    required this.sections,
    this.sources = const [],
  });

  /// Stable across languages and rewordings — used for the hero tag between
  /// the card and the detail page.
  final String id;
  final IconData icon;

  /// Accent for this article: the icon, the "Maqola" label and the bar on the
  /// left edge of its card all take their colour from here.
  final Color iconColor;
  final LocalizedText title;
  final LocalizedText duration;
  final LocalizedText summary;
  final List<ArticleSection> sections;

  /// References for the claims above, listed at the end of the article.
  final List<Source> sources;
}
