import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/l10n/language_picker.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';

/// The first screen anybody sees, and the one place the language is chosen
/// before the app has said anything.
///
/// The picker sits at the top, above the fold and above the headline it would
/// otherwise be explaining: someone whose phone guessed Uzbek when they read
/// Russian cannot use a control they have to read Uzbek to find.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final padding = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/onboarding.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(-0.3, 0.0),
          ),

          // Top scrim. Without it the language pills sit on whatever the
          // photograph happens to be doing up there, and white-on-white is a
          // control nobody can find.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: padding.top + 110,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x73000000), Color(0x00000000)],
                ),
              ),
            ),
          ),

          Positioned(
            top: padding.top + 12,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const LanguageSegmentedControl(onSurface: true),
                const SizedBox(height: 6),
                Text(
                  l10n.introChooseLanguage,
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // Bottom fade, so the glass panel does not cut the photograph off
          // with a hard edge.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.62),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  decoration: BoxDecoration(
                    // 0.14 rather than the 0.08 it used to be: over the light
                    // part of this photograph the panel was invisible and the
                    // body copy sat straight on the image.
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.introTitle,
                        style: AppText.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ).animate(target: reduceMotion ? 1 : null)
                          .fadeIn(delay: 150.ms)
                          .slideY(begin: 0.12),
                      const SizedBox(height: 8),
                      Text(
                        l10n.introSubtitle,
                        style: AppText.bodySm.copyWith(
                          // 0.82 rather than 0.65: at 0.65 over a blurred
                          // photograph this fell under 4.5:1 and read as a
                          // greyed-out label rather than as the sentence that
                          // explains the app.
                          color: Colors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w400,
                        ),
                      ).animate(target: reduceMotion ? 1 : null)
                          .fadeIn(delay: 300.ms),
                      const SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.only(bottom: padding.bottom + 20),
                        child: _GlassCta(
                          label: l10n.introStart,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/auth');
                          },
                        ).animate(target: reduceMotion ? 1 : null)
                            .fadeIn(delay: 380.ms)
                            .slideY(begin: 0.12),
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
  const _GlassCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_GlassCta> createState() => _GlassCtaState();
}

class _GlassCtaState extends State<_GlassCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: widget.label,
      // Same reason as everywhere else ExcludeSemantics wraps a gesture: the
      // tap has to be re-declared here or the control is unusable by anyone
      // driving the app with a screen reader.
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed && !reduceMotion ? 0.97 : 1.0,
            duration: AppMotion.fast,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  width: double.infinity,
                  height: AppTouch.control,
                  decoration: BoxDecoration(
                    // Solid white on press rather than a fade-out: over a
                    // photograph, dropping the opacity made the button look
                    // like it was disappearing rather than being pressed.
                    color: _pressed
                        ? Colors.white.withValues(alpha: 0.42)
                        : Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.label,
                    style: AppText.button.copyWith(letterSpacing: 0.4),
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
