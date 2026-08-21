import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/features/products/presentation/bloc/products_cubit.dart';
import 'package:real_beauty_ai/features/products/presentation/pages/products_page.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';

import '../../support/localized_app.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

final _fakeProduct = Product(
  imagePath: 'assets/products/product_1.jpg',
  brand: 'TESTBRAND',
  name: 'Test Cream',
  subtitle: LocalizedText.same('SPF 50+'),
  price: '100 000 so\'m',
  category: 'SPF',
  benefits: [LocalizedText.same('Benefit one')],
);

Widget _pump(ProductsCubit cubit) =>
    localizedApp(ProductsScreen(testCubit: cubit));

void main() {
  late MockProductsCubit cubit;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    cubit = MockProductsCubit();
  });

  testWidgets('Loaded state — product brand and name visible', (tester) async {
    when(() => cubit.state).thenReturn(ProductsLoaded([_fakeProduct]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle(); // drain flutter_animate card timers

    expect(find.text('TESTBRAND'), findsOneWidget);
    expect(find.text('Test Cream'), findsOneWidget);
  });

  testWidgets('Error state — error message and retry button visible',
      (tester) async {
    // The state carries no sentence of its own any more — the screen owns the
    // copy, so it can say it in whichever language is on.
    when(() => cubit.state).thenReturn(ProductsError());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle(); // drain banner flutter_animate timer

    expect(find.text('Mahsulotlarni yuklashda xato'), findsOneWidget);
    // One retry label for the whole app now: the products screen used to say
    // "Qaytadan urinish" while every other failure said "Qayta urinish".
    expect(find.text('Qayta urinish'), findsOneWidget);
  });

  testWidgets('Loading state — shimmer skeleton grid visible',
      (tester) async {
    when(() => cubit.state).thenReturn(ProductsLoading());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    // pumpAndSettle would loop forever with the repeating shimmer;
    // pump(1s) fires the banner's flutter_animate 0ms timer and completes it.
    await tester.pump(const Duration(seconds: 1));

    // Loading renders a grid of skeleton placeholders instead of a spinner.
    expect(find.byType(SliverGrid), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Loaded with multiple products — all brands visible',
      (tester) async {
    final second = Product(
      imagePath: 'assets/products/product_2.jpg',
      brand: 'BRAND2',
      name: 'Second Product',
      subtitle: LocalizedText.same('subtitle'),
      price: '50 000',
      category: 'Tozalovchi',
      benefits: [],
    );
    when(() => cubit.state)
        .thenReturn(ProductsLoaded([_fakeProduct, second]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle(); // drain flutter_animate card timers

    expect(find.text('TESTBRAND'), findsOneWidget);
    expect(find.text('BRAND2'), findsOneWidget);
  });

  // ── The shopping surface ─────────────────────────────────────────────

  testWidgets('a card shows the price — the number the grid exists for',
      (tester) async {
    when(() => cubit.state).thenReturn(ProductsLoaded([_fakeProduct]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle();

    // Stored as "100 000 so'm"; the currency word comes from the ARB so a
    // Russian reader is not shown "so'm" inside their own interface.
    expect(find.textContaining('100'), findsWidgets);
    expect(find.textContaining("so'm"), findsOneWidget);
  });

  testWidgets('the price is rendered in the chosen language', (tester) async {
    when(() => cubit.state).thenReturn(ProductsLoaded([_fakeProduct]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      localizedApp(ProductsScreen(testCubit: cubit),
          locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('сум'), findsOneWidget);
    expect(find.textContaining("so'm"), findsNothing);
  });

  testWidgets('the header counts what is on the shelf', (tester) async {
    when(() => cubit.state)
        .thenReturn(ProductsLoaded([_fakeProduct, _fakeProduct]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsUz().productsCount(2)), findsOneWidget);
  });

  testWidgets('a card announces itself as one control, not four fragments',
      (tester) async {
    final handle = tester.ensureSemantics();
    when(() => cubit.state).thenReturn(ProductsLoaded([_fakeProduct]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle();

    // Brand, name and price in one sentence, and a tap action — the card sits
    // inside an ExcludeSemantics, so without a declared action a screen reader
    // would announce a button it cannot press.
    final node = tester.getSemantics(
      find.bySemanticsLabel(RegExp(r'TESTBRAND\. Test Cream\.')),
    );
    expect(
      node,
      matchesSemantics(isButton: true, hasTapAction: true),
    );
    // Brand, name and price in one sentence. The price carries a non-breaking
    // space so a long number never wraps mid-figure on a narrow card, which is
    // why the label is not compared as a literal.
    expect(node.label.replaceAll('\u00A0', ' '),
        "TESTBRAND. Test Cream. 100 000 so'm");
    handle.dispose();
  });

  testWidgets('the empty state offers the thing that fixes it',
      (tester) async {
    final l10n = AppLocalizationsUz();
    when(() => cubit.state).thenReturn(ProductsLoaded([_fakeProduct]));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle();

    // The fake product is filed under "SPF", which is not one of the real
    // chips, so picking any real category filters it out.
    await tester.tap(find.text('Tozalovchi'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.productsEmpty), findsOneWidget);
    expect(find.text(l10n.productsEmptyBody), findsOneWidget);
    // Clearing the filter was two taps away with nothing pointing at it.
    expect(find.text(l10n.productsFilterAll), findsWidgets);
  });

  testWidgets('the error state offers a retry, not a dead end', (tester) async {
    final l10n = AppLocalizationsUz();
    when(() => cubit.state).thenReturn(ProductsError());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.load()).thenAnswer((_) async {});

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.productsError), findsOneWidget);
    expect(find.text(l10n.productsErrorBody), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();
    verify(() => cubit.load()).called(1);
  });
}
