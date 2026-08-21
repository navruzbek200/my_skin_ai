import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/data/articles_data.dart';
import 'package:real_beauty_ai/data/lessons_data.dart';
import 'package:real_beauty_ai/data/product_categories.dart';
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/data/quiz_data.dart';
import 'package:real_beauty_ai/data/skin_problems_data.dart';
import 'package:real_beauty_ai/data/yoga_data.dart';
import 'package:real_beauty_ai/features/routine/domain/routine_engine.dart';
import 'package:real_beauty_ai/logic/skin_copy.dart';

/// Guards the content catalogues against a translation quietly going missing.
///
/// The compiler already forces all three languages to be *present* — the
/// [LocalizedText] constructor is positional and required. What it cannot catch
/// is the copy-paste: three arguments where two of them are still the Uzbek
/// sentence, which compiles, ships, and shows Uzbek to a Russian reader.
void main() {
  /// Collects everything worth checking, labelled so a failure names the entry
  /// rather than an index.
  final entries = <String, LocalizedText>{};

  void add(String label, LocalizedText? text) {
    if (text != null) entries[label] = text;
  }

  setUpAll(() {
    for (final q in quizQuestions) {
      add('quiz ${q.id} text', q.text);
      add('quiz ${q.id} hint', q.hint);
      q.scaleLabels?.asMap().forEach(
          (i, l) => add('quiz ${q.id} scale $i', l));
      q.options?.asMap().forEach((i, o) => add('quiz ${q.id} option $i', o));
    }
    for (final g in quizGroups) {
      add('quiz group ${g.range}', g.title);
    }

    for (final p in skinProblems) {
      add('problem ${p.id} name', p.name);
      add('problem ${p.id} cause', p.cause);
      add('problem ${p.id} solution', p.solution);
      add('problem ${p.id} note', p.note);
    }

    for (final p in products) {
      add('product ${p.name} subtitle', p.subtitle);
      p.benefits.asMap().forEach(
          (i, b) => add('product ${p.name} benefit $i', b));
    }
    for (final c in productCategories) {
      add('category ${c.key}', c.label);
    }

    for (final l in lessons) {
      add('lesson ${l.id} title', l.title);
      add('lesson ${l.id} subtitle', l.subtitle);
      add('lesson ${l.id} category', l.category);
      add('lesson ${l.id} duration', l.duration);
      add('lesson ${l.id} level', l.level);
      l.steps.asMap().forEach((i, s) {
        add('lesson ${l.id} step $i title', s.title);
        add('lesson ${l.id} step $i body', s.body);
        add('lesson ${l.id} step $i keyword', s.keyword);
        s.items?.asMap().forEach(
            (j, item) => add('lesson ${l.id} step $i item $j', item));
      });
    }

    for (final a in articles) {
      add('article ${a.id} title', a.title);
      add('article ${a.id} summary', a.summary);
      add('article ${a.id} duration', a.duration);
      a.sections.asMap().forEach((i, s) {
        add('article ${a.id} section $i heading', s.heading);
        add('article ${a.id} section $i body', s.body);
      });
    }

    for (final e in [...yogaExercises, ...yogaVoiceExercises]) {
      add('yoga ${e.videoPath} name', e.name);
      add('yoga ${e.videoPath} target', e.target);
      add('yoga ${e.videoPath} duration', e.duration);
      add('yoga ${e.videoPath} description', e.description);
    }

    SkinCopy.skinTypes.forEach((k, v) => add('skin type $k', v));
    SkinCopy.baseRecommendations
        .forEach((k, v) => add('base recommendation $k', v));
    SkinCopy.blocks.forEach((k, v) {
      add('concern $k title', v.title);
      add('concern $k text', v.text);
    });

    // Every branch of the routine engine, driven through the inputs that
    // select them: four skin types, the concern codes, and the weekdays that
    // decide an active night from a mask night.
    for (final skin in ['Normal', 'Quruq', "Yog'li", 'Aralash']) {
      for (final concerns in [
        <String>{},
        {'S'},
        {'P'},
        {'Bh'},
        {'Ew'},
      ]) {
        for (var day = 15; day <= 21; day++) {
          final routine = RoutineEngine.generate(
            skinType: skin,
            concerns: concerns,
            date: DateTime(2024, 1, day),
          );
          for (final step in [...routine.morning, ...routine.evening]) {
            add('routine ${step.id}', step.title);
          }
        }
      }
    }
  });

  test('every entry carries three distinct translations', () {
    final untranslated = <String>[];
    for (final entry in entries.entries) {
      final t = entry.value;
      // An empty value is the deliberate "this step has no body" case, and a
      // value identical across all three is a `LocalizedText.same` — a brand,
      // an INCI name, a measurement. Neither is a missing translation.
      if (t.uz.isEmpty) continue;
      if (t.uz == t.ru && t.ru == t.en) continue;
      // A single word that happens to be spelled the same in two languages is
      // ordinary — "Retinol" and "Normal" are the same in Uzbek and English.
      // A whole phrase coinciding is not; that is the copy-paste this test
      // exists to catch, so the check applies from two words up.
      bool isPhrase(String value) => value.trim().contains(' ');
      if (t.ru == t.uz && isPhrase(t.uz)) {
        untranslated.add('${entry.key} (ru == uz)');
      }
      if (t.en == t.uz && isPhrase(t.uz)) {
        untranslated.add('${entry.key} (en == uz)');
      }
    }
    expect(untranslated, isEmpty,
        reason: 'These entries were never translated:\n'
            '${untranslated.join('\n')}');
  });

  test('no entry is blank in one language and filled in another', () {
    final ragged = <String>[];
    for (final entry in entries.entries) {
      final t = entry.value;
      final filled = [t.uz, t.ru, t.en].where((s) => s.trim().isNotEmpty).length;
      if (filled != 0 && filled != 3) ragged.add(entry.key);
    }
    expect(ragged, isEmpty,
        reason: 'These entries are filled in some languages only:\n'
            '${ragged.join('\n')}');
  });

  test('resolve() answers with the language it was asked for', () {
    const text = LocalizedText('uz', 'ru', 'en');
    expect(text.resolve('uz'), 'uz');
    expect(text.resolve('ru'), 'ru');
    expect(text.resolve('en'), 'en');
    // Anything we do not ship falls back to the template language rather than
    // returning an empty string.
    expect(text.resolve('de'), 'uz');
  });
}
