import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/features/home/presentation/pages/bugun_page.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Minimal valid SkinResult JSON — oily skin with Bh concern.
// RoutineEngine will generate "Ko'pikli tozalash" as first AM step.
const _profileJson =
    '{"skinType":"Yog\'li","skinTypeCode":"O","baseRecommendation":"test",'
    '"additionalBlocks":[{"code":"Bh","title":"t","text":"t"}]}';

// Time to advance per test — covers Future.delayed(index*50ms) up to 400ms
// plus card animation (300ms) plus flutter_animate fadeIns (≤400ms).
const _settle = Duration(seconds: 2);

void main() {
  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({'skin_profile_v1': _profileJson});
    await LocalStore.instance.init();
  });

  Widget wrap() => const MaterialApp(home: BugunScreen());

  testWidgets('renders 9 tasks and shows 0 / 9 vazifa initially', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(_settle);

    expect(find.text('0 / 9 vazifa'), findsOneWidget);
    expect(find.text('Ertalab'), findsOneWidget);
    expect(find.text('Kechqurun'), findsOneWidget);
    // SPF is always the 4th AM slot
    expect(find.text('SPF 50 quyosh kremi'), findsOneWidget);
  });

  testWidgets('tapping a task card increments done count', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(_settle);

    // Oily skin AM cleanse label
    final taskFinder = find.text("Ko'pikli tozalash");
    expect(taskFinder, findsOneWidget);

    await tester.tap(taskFinder);
    await tester.pump(); // process setState — text updates synchronously
    expect(find.text('1 / 9 vazifa'), findsOneWidget);
    await tester.pump(_settle); // drain animate restarts from rebuild
  });

  testWidgets('tapping same task twice toggles back to 0', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(_settle);

    final taskFinder = find.text("Ko'pikli tozalash");
    await tester.tap(taskFinder);
    await tester.pump();
    expect(find.text('1 / 9 vazifa'), findsOneWidget);
    await tester.pump(_settle);

    await tester.tap(taskFinder);
    await tester.pump();
    expect(find.text('0 / 9 vazifa'), findsOneWidget);
    await tester.pump(_settle);
  });

  testWidgets('shows progress badge when all 9 tasks done', (tester) async {
    // Pre-populate all 9 task IDs as done in SharedPreferences.
    final today = LocalStore.dateKey(DateTime.now());
    SharedPreferences.setMockInitialValues({
      'skin_profile_v1': _profileJson,
      'routine:$today': '{"am_cleanse":true,"am_toner":true,"am_serum":true,'
          '"am_spf":true,"pm_cleanse":true,"pm_toner":true,'
          '"pm_treatment":true,"pm_moist":true,"pm_last":true}',
    });
    // Reinit LocalStore with updated prefs.
    await LocalStore.instance.init();

    await tester.pumpWidget(wrap());
    await tester.pump(_settle);

    expect(find.text('9 / 9 vazifa'), findsOneWidget);
    expect(find.text('Hammasi bajarildi!'), findsOneWidget);
  });
}
