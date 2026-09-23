import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/data/articles_data.dart';
import 'package:real_beauty_ai/data/lessons_data.dart';
import 'package:real_beauty_ai/data/quiz_data.dart';
import 'package:real_beauty_ai/data/skin_problems_data.dart';
import 'package:real_beauty_ai/data/sources_data.dart';
import 'package:real_beauty_ai/features/scanner/presentation/pages/scanner_page.dart';
import 'package:real_beauty_ai/features/sources/presentation/pages/sources_page.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/logic/skin_copy.dart';
import 'package:real_beauty_ai/models/source.dart';
import 'package:real_beauty_ai/widgets/sources_section.dart';

import '../../support/localized_app.dart';

/// iPad Air 11" (M3) in portrait — the device App Review used for 1.2.0 (7).
const _iPadAir11 = Size(820, 1180);
const _iPhone = Size(390, 844);

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  // ── What is cited where ────────────────────────────────────────────────

  test('every skin type result carries at least one source', () {
    for (final code in SkinCopy.skinTypes.keys) {
      expect(SkinCopy.sourcesFor(code, const []), isNotEmpty, reason: code);
    }
  });

  test('a result lists each source once, however many blocks cite it', () {
    final all = SkinCopy.sourcesFor('D', const ['P0', 'Bh', 'Ad', 'S']);
    expect(all.map((s) => s.url).toSet().length, all.length);
  });

  test('the two screens App Review flagged are cited', () {
    final redness = skinProblems.firstWhere((p) => p.id == 'sensitivity');
    expect(redness.sources, containsAll(Sources.redness));
    final natural = articles.firstWhere((a) => a.id == 'natural_ingredients');
    expect(natural.sources, Sources.naturalIngredientsArticle);
  });

  test('every health-claim screen cites at least one source', () {
    for (final p in skinProblems) {
      expect(p.sources, isNotEmpty, reason: 'concern ${p.id}');
    }
    for (final a in articles) {
      expect(a.sources, isNotEmpty, reason: 'article ${a.id}');
    }
    for (final l in lessons) {
      expect(l.sources, isNotEmpty, reason: 'lesson ${l.id}');
    }
    for (final code in SkinCopy.blocks.keys) {
      expect(SkinCopy.sources[code], isNotNull, reason: 'result block $code');
    }
    expect(Sources.faceExercise, isNotEmpty);
  });

  test('no unsupported numbers or claims survive in the copy', () {
    final all = [
      for (final a in articles)
        for (final s in a.sections) ...[s.body.uz, s.body.ru, s.body.en],
      for (final l in lessons)
        for (final s in l.steps) ...[s.body.uz, s.body.ru, s.body.en],
      for (final p in skinProblems)
        ...[p.solution.ru, p.solution.en, p.note?.ru ?? '', p.note?.en ?? ''],
      for (final b in SkinCopy.blocks.values) ...[b.text.ru, b.text.en],
    ].join('\n');
    for (final banned in [
      '80%', '27–37%', '34%', 'six litres', '6 литров', 'до 30%',
      '22:00', 'somatotropin', 'caffeine', 'Sentin', 'lemon juice',
      'chamomile', 'Drink more water', 'most important mineral',
    ]) {
      expect(all.contains(banned), isFalse, reason: banned);
    }
  });

  test('the milia question is plain language and cites its term', () {
    final q = quizQuestions.firstWhere((q) => q.id == 'q19');
    expect(q.text.ru, isNot(contains('милиум')));
    expect(q.sources, Sources.milia);
  });

  test('the natural-ingredients copy no longer overclaims', () {
    final natural = articles.firstWhere((a) => a.id == 'natural_ingredients');
    for (final s in natural.sections) {
      for (final text in [s.body.uz, s.body.ru, s.body.en]) {
        expect(text.toLowerCase(), isNot(contains('romashka')));
        expect(text.toLowerCase(), isNot(contains('ромашк')));
        expect(text.toLowerCase(), isNot(contains('chamomile')));
        expect(text, isNot(contains('protect against UV')));
      }
    }
  });

  test('every cited URL is one of the vetted sources', () {
    final vetted = {
      for (final g in Sources.all) ...g.sources.map((s) => s.url),
    };
    final cited = [
      ...skinProblems.expand((p) => p.sources),
      ...articles.expand((a) => a.sources),
      ...lessons.expand((l) => l.sources),
      ...quizQuestions.expand((q) => q.sources),
      ...SkinCopy.sources.values.expand((s) => s),
    ];
    for (final s in cited) {
      expect(vetted, contains(s.url), reason: s.title);
      expect(Uri.parse(s.url).scheme, 'https', reason: s.url);
    }
  });

  // ── Layout: every language, every device class ─────────────────────────

  const devices = {
    'iPhone SE': Size(320, 568),
    'iPhone 16': Size(390, 844),
    'iPhone Pro Max': Size(430, 932),
    'iPad Air 11 portrait': _iPadAir11,
    'iPad Air 11 landscape': Size(1180, 820),
  };
  const locales = [Locale('uz'), Locale('ru'), Locale('en')];

  Future<void> pumpAt(
    WidgetTester tester,
    Widget page,
    Size size,
    Locale locale, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: localizedApp(page, locale: locale),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in locales) {
    for (final MapEntry(key: device, value: size) in devices.entries) {
      for (final scale in [1.0, 1.4]) {
        final tag = '${locale.languageCode} · $device · x$scale';

        testWidgets('sources screen: $tag', (tester) async {
          await pumpAt(
            tester,
            const SourcesScreen(),
            size,
            locale,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);

          final total = Sources.all.fold<int>(
            0,
            (n, g) => n + g.sources.length,
          );
          final tiles = find.byType(SourceTile, skipOffstage: false);
          expect(tiles, findsNWidgets(total));
          await tester.ensureVisible(tiles.last);
          await tester.pumpAndSettle();
          final r = tester.getRect(tiles.last);
          expect(r.height, greaterThanOrEqualTo(48));
          expect(r.left, greaterThanOrEqualTo(0));
          expect(r.right, lessThanOrEqualTo(size.width));
          // Held to a reading column on wide screens.
          expect(r.width, lessThanOrEqualTo(640));
        });

        testWidgets('Redness sources: $tag', (tester) async {
          final redness = skinProblems.firstWhere((p) => p.id == 'sensitivity');
          await pumpAt(
            tester,
            SkinProblemDetailPage(problem: redness),
            size,
            locale,
            textScale: scale,
          );
          final section = find.byType(SourcesSection);
          await tester.ensureVisible(section);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('Azelaic acid'), findsOneWidget);
          expect(tester.getRect(section).right, lessThanOrEqualTo(size.width));
        });
      }
    }
  }

  testWidgets('a long result list folds, then opens in full', (tester) async {
    final sources = SkinCopy.sourcesFor('D', const ['S', 'Wh', 'P']);
    expect(sources.length, greaterThan(5));
    await pumpAt(
      tester,
      Scaffold(
        body: SingleChildScrollView(child: SourcesSection(sources: sources)),
      ),
      _iPhone,
      const Locale('ru'),
    );

    expect(find.byType(SourceTile), findsNWidgets(3));
    final more = find.text(
      AppLocalizationsRu().sourcesShowMore(sources.length - 3),
    );
    expect(more, findsOneWidget);

    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(
      find.byType(SourceTile, skipOffstage: false),
      findsNWidgets(sources.length),
    );
    expect(find.text(AppLocalizationsRu().sourcesShowLess), findsOneWidget);
  });

  testWidgets('a short list is never folded', (tester) async {
    await pumpAt(
      tester,
      const Scaffold(body: SourcesSection(sources: Sources.redness)),
      _iPhone,
      const Locale('en'),
    );
    expect(find.byType(SourceTile), findsNWidgets(Sources.redness.length));
    expect(find.textContaining('more source'), findsNothing);
  });

  test('titles split into publisher, headline and site', () {
    const s = Source(
      'DermNet — Azelaic acid',
      'https://dermnetnz.org/topics/azelaic-acid',
    );
    expect(s.publisher, 'DermNet');
    expect(s.headline, 'Azelaic acid');
    expect(s.domain, 'dermnetnz.org');
    expect(Sources.carotenoids.first.domain, 'doi.org');
    expect(Sources.drySkin.first.domain, 'aad.org');
  });
}
