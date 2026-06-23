import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      duration: const Duration(milliseconds: 3000),
    )..forward();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      final dest = FirebaseAuth.instance.currentUser != null ? '/home' : '/intro';
      context.go(dest);
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
                    colors: [
                      const Color(0xFFB8A8E8).withValues(alpha: _lerp(0.0, 0.55, v)),
                      const Color(0xFF9B7DD4).withValues(alpha: _lerp(0.0, 0.22, v)),
                      const Color(0xFF7060AA).withValues(alpha: _lerp(0.0, 0.06, v)),
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
                width: size.width * 0.72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
