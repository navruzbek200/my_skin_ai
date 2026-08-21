import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';

/// The brand moment.
///
/// A baby-blue bloom opens behind the lockup and the wordmark settles into it —
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

  late final Animation<double> _logoOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
  );

  late final Animation<double> _logoScale =
      Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
    parent: _controller,
    // easeOutCubic rather than a linear ramp: the mark decelerates into place
    // instead of arriving and stopping dead.
    curve: const Interval(0.0, 0.42, curve: Curves.easeOutCubic),
  ));

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
                child: Opacity(
                  opacity:
                      reduceMotion ? 1 : _logoOpacity.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: reduceMotion ? 1 : _logoScale.value,
                    child: Semantics(
                      label: 'My Skin AI',
                      image: true,
                      child: Image.asset(
                        'assets/splash.png',
                        width: size.width * 0.86,
                        fit: BoxFit.contain,
                      ),
                    ),
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
