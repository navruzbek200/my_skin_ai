import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    // 2.2s is a product decision, not a budget: the user reads this as a brand
    // moment and has asked for it back after it was shortened. Leave it.
    //
    // It used to be load-bearing as well. The destination was read from
    // `FirebaseAuth.currentUser` while the guards on '/auth' and '/intro' read
    // AuthBloc, so a logout routed through here could be bounced straight back
    // to '/home' unless the wait outlasted the bloc catching up. Reading the
    // same source the guards read removes that race outright — the length now
    // only has to be what looks right.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.go(sl<AuthBloc>().state.isAuthenticated ? '/home' : '/intro');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
    );
    final logoScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.22, curve: Curves.easeOut),
    );
    final bgAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.18, 1.0, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: bgAnim,
            builder: (_, _) {
              final v = bgAnim.value;
              final radius = 0.28 + 0.45 * v;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: radius,
                    // Baby blue, taken off the brand's packaging: a bright
                    // tiffany core fading through teal to a deep sea green,
                    // the same ramp the bags print.
                    colors: [
                      const Color(0xFF7FD8D4).withValues(alpha: _lerp(0.0, 0.55, v)),
                      const Color(0xFF45B8B5).withValues(alpha: _lerp(0.0, 0.22, v)),
                      const Color(0xFF1E7F86).withValues(alpha: _lerp(0.0, 0.06, v)),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.42, 0.72, 1.0],
                  ),
                ),
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) {
                final scale = _lerp(0.90, 1.0, logoScale.value);
                return Opacity(
                  opacity: logoFade.value.clamp(0.0, 1.0),
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Image.asset(
                'assets/splash.png',
                width: size.width * 0.90,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
