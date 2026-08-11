// Throwaway entrypoint for capturing Play Store screenshots.
//
// The real app gates everything behind sign-in and a completed skin quiz, and
// there is no way to drive a tap from here — so this seeds a profile, skips
// auth, and walks the shell's tabs on a timer while screenshots are taken.
//
// Delete after use. Never referenced by the app.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/shell/main_shell.dart';
import 'package:real_beauty_ai/firebase_options.dart';
import 'package:real_beauty_ai/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _profileJson =
    '{"skinType":"Yog\'li","skinTypeCode":"O",'
    '"baseRecommendation":"Yog\'li teri uchun yengil, namlantiruvchi parvarish. '
    'Kuniga ikki marta tozalash va har kuni quyoshdan himoya tavsiya etiladi.",'
    '"additionalBlocks":[{"code":"Bh","title":"Qora nuqtalar",'
    '"text":"Haftada 1-2 marta yumshoq peeling"}]}';

/// Seconds each tab stays on screen before the next one. The capture script
/// sleeps in step with this.
const _dwell = Duration(seconds: 10);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('skin_profile_v1', _profileJson);
  await prefs.setBool('privacy_accepted_v1', true);

  // A partly-ticked day and a few finished ones behind it, so the progress bar
  // and the week strip both have something to show.
  final today = DateTime.now();
  String key(int daysAgo) =>
      LocalStore.dateKey(today.subtract(Duration(days: daysAgo)));
  const allDone = '{"am_cleanse":true,"am_toner":true,"am_serum":true,'
      '"am_spf":true,"pm_cleanse":true,"pm_toner":true,"pm_treatment":true,'
      '"pm_moist":true,"pm_last":true}';
  await prefs.setString('routine:${key(0)}',
      '{"am_cleanse":true,"am_toner":true,"am_serum":true,"am_spf":true}');
  for (final d in [1, 2, 3, 4]) {
    await prefs.setString('routine:${key(d)}', allDone);
  }

  await LocalStore.instance.init();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  runApp(const _Shots());
}

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, _) => const _Cycler()),
    GoRoute(path: '/quiz', builder: (_, _) => const SizedBox()),
    GoRoute(path: '/account', builder: (_, _) => const SizedBox()),
    GoRoute(path: '/lesson-detail', builder: (_, _) => const SizedBox()),
    GoRoute(path: '/article-detail', builder: (_, _) => const SizedBox()),
    GoRoute(path: '/cosmetolog-detail', builder: (_, _) => const SizedBox()),
    GoRoute(path: '/scan-instructions', builder: (_, _) => const SizedBox()),
  ],
);

class _Shots extends StatelessWidget {
  const _Shots();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: (context, child) {
        final scaler = MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Rebuilds the shell on a new tab every [_dwell]. The key forces a fresh
/// State so `initialIndex` is read again.
class _Cycler extends StatefulWidget {
  const _Cycler();

  @override
  State<_Cycler> createState() => _CyclerState();
}

class _CyclerState extends State<_Cycler> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    Future.delayed(_dwell, () {
      if (!mounted) return;
      setState(() => _i = (_i + 1) % 5);
      _schedule();
    });
  }

  @override
  Widget build(BuildContext context) =>
      MainShell(key: ValueKey(_i), initialIndex: _i);
}
