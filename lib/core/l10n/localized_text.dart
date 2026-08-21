import 'package:flutter/widgets.dart';

/// A piece of content copy in every language the app ships in.
///
/// Routine steps, lesson bodies, product blurbs and skin-problem write-ups do
/// not belong in the ARB files: those hold the interface, which is written once
/// and rarely changes, while this is editorial copy that grows with the
/// catalogue. Keeping the three languages inside one const value also means a
/// new entry cannot be added with a missing translation — the constructor
/// requires all three and the compiler enforces it.
@immutable
class LocalizedText {
  /// Positional and always in the same order — uz, ru, en — because this type
  /// appears hundreds of times in the content tables, where three named
  /// arguments per string would bury the copy in punctuation.
  const LocalizedText(this.uz, this.ru, this.en);

  /// For copy that is identical in every language — INCI ingredient names,
  /// brands, measurements. Written out rather than defaulted so a value that
  /// only *looks* translated cannot slip in unnoticed.
  const LocalizedText.same(String value)
      : uz = value,
        ru = value,
        en = value;

  final String uz;
  final String ru;
  final String en;

  String resolve(String languageCode) => switch (languageCode) {
        'ru' => ru,
        'en' => en,
        _ => uz,
      };

  /// Search matches across every language, not only the one on screen: someone
  /// reading the app in Russian still types "niacinamide" the way the tube
  /// spells it.
  bool contains(String lowercaseQuery) =>
      uz.toLowerCase().contains(lowercaseQuery) ||
      ru.toLowerCase().contains(lowercaseQuery) ||
      en.toLowerCase().contains(lowercaseQuery);

  @override
  bool operator ==(Object other) =>
      other is LocalizedText &&
      other.uz == uz &&
      other.ru == ru &&
      other.en == en;

  @override
  int get hashCode => Object.hash(uz, ru, en);

  @override
  String toString() => 'LocalizedText($uz)';
}

extension LocalizedTextContext on BuildContext {
  /// `context.tr(step.title)` — resolves content copy against the language the
  /// app is currently showing.
  String tr(LocalizedText text) =>
      text.resolve(Localizations.localeOf(this).languageCode);
}
