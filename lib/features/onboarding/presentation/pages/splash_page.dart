import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';

/// The brand moment.
///
/// The logo is drawn at exactly the size and place the native launch screen
/// draws it (86% of the width, centred — see LaunchScreen.storyboard), and it
/// is fully visible from the first frame. The hand-off from the OS launch
/// screen to Flutter is therefore invisible: the mark never jumps, shrinks or
/// blinks out, and only the bloom behind it moves. It used to fade in from
/// nothing at 90% scale, which on a cold start read as small logo → blank
/// screen → big logo.
///
/// A baby-blue bloom opens behind the lockup —
/// the ramp is taken off the brand's packaging, where a bright tiffany core
/// fades through teal into white. Nothing is written under the mark: the logo
/// already carries the tagline, and a second line of type only delays the app
/// by the time it takes to read it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash is guaranteed to stay up. Long enough to read as
  /// intentional, short enough that a returning user is not kept waiting.
  ///
  /// This is a product decision, not a budget: the user has asked for it back
  /// once after it was shortened. Leave it.
  static const Duration hold = Duration(milliseconds: 2200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  late final Animation<double> _bloom = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.10, 1.0, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();

    // The destination is read from AuthBloc — the same source the '/auth' and
    // '/intro' guards read. Reading FirebaseAuth directly here instead used to
    // race them: a logout routed through this screen could be bounced straight
    // back to '/home' unless the wait outlasted the bloc catching up.
    Future.delayed(SplashScreen.hold, () {
      if (!mounted) return;
      final session = sl<AuthBloc>().state;
      if (!session.isAuthenticated) {
        context.go('/intro');
        return;
      }
      // A sign-up that never confirmed its address lands on the gate rather
      // than on the app. Sending it to '/home' would work — the router would
      // redirect — but it would flash the shell for a frame first.
      context.go(session.needsVerificationGate ? '/verify-email' : '/home');
    });
  }

  /// Must match the width multiplier in ios/Runner/Base.lproj/
  /// LaunchScreen.storyboard, or the logo jumps on the hand-off.
  static const _logoWidthFraction = 0.86;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/splash.png'), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // With animations disabled the whole thing is drawn in its final state —
    // the brand still reads, nothing moves.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final bloom = reduceMotion ? 1.0 : _bloom.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.30 + 0.55 * bloom,
                    // Baby blue, taken off the brand's packaging: a bright
                    // tiffany core fading through teal to a deep sea green,
                    // the same ramp the bags print.
                    colors: [
                      const Color(0xFF7FD8D4).withValues(alpha: 0.50 * bloom),
                      const Color(0xFF45B8B5).withValues(alpha: 0.20 * bloom),
                      const Color(0xFF1E7F86).withValues(alpha: 0.06 * bloom),
                      const Color(0x00FFFFFF),
                    ],
                    stops: const [0.0, 0.42, 0.72, 1.0],
                  ),
                ),
              ),
              Center(
                child: Semantics(
                  label: 'My Skin AI',
                  image: true,
                  // Same box as the launch screen's image view: a square,
                  // 86% of the width. gaplessPlayback plus the precache in
                  // didChangeDependencies keep the first frame from being
                  // drawn without it.
                  child: Image.asset(
                    'assets/splash.png',
                    width: size.width * _logoWidthFraction,
                    height: size.width * _logoWidthFraction,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
