import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final botPad = mq.padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/onboarding.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(-0.3, 0.0),
          ),

          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.60),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Glass panel
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.20), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading
                      Text(
                        'Sog\'lom teri —\nchiroyli hayot',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.12),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Shaxsiy teri tahlili va koreya parvarish tavsiyalari',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.65),
                          height: 1.45,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 16),

                      // CTA — glass button
                      Padding(
                        padding: EdgeInsets.only(bottom: botPad + 20),
                        child: _GlassCta(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/auth');
                          },
                        ).animate().fadeIn(delay: 380.ms).slideY(begin: 0.12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCta extends StatefulWidget {
  final VoidCallback onTap;
  const _GlassCta({required this.onTap});

  @override
  State<_GlassCta> createState() => _GlassCtaState();
}

class _GlassCtaState extends State<_GlassCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.75 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.50),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Boshlash',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
