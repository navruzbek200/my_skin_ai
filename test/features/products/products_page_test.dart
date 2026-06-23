import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/features/products/presentation/bloc/products_cubit.dart';
import 'package:real_beauty_ai/features/products/presentation/pages/products_page.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

final _fakeProduct = Product(
  imagePath: 'assets/products/product_1.jpg',
  brand: 'TESTBRAND',
  name: 'Test Cream',
  subtitle: 'SPF 50+',
  price: '100 000 so\'m',
  category: 'SPF',
  benefits: ['Benefit one'],
);

Widget _pump(ProductsCubit cubit) => MaterialApp(
      home: ProductsScreen(testCubit: cubit),
    );

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
    when(() => cubit.state)
        .thenReturn(ProductsError('Mahsulotlarni yuklashda xato'));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    await tester.pumpAndSettle(); // drain banner flutter_animate timer

    expect(find.text('Mahsulotlarni yuklashda xato'), findsOneWidget);
    expect(find.text('Qaytadan urinish'), findsOneWidget);
  });

  testWidgets('Loading state — CircularProgressIndicator visible',
      (tester) async {
    when(() => cubit.state).thenReturn(ProductsLoading());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(_pump(cubit));
    // pumpAndSettle would loop forever with CircularProgressIndicator;
    // pump(1s) fires the banner's flutter_animate 0ms timer and completes it.
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Loaded with multiple products — all brands visible',
      (tester) async {
    final second = Product(
      imagePath: 'assets/products/product_2.jpg',
      brand: 'BRAND2',
      name: 'Second Product',
      subtitle: 'subtitle',
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
}
