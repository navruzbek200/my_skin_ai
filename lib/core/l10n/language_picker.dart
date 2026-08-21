import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';

/// Three visible pills, for the first screen of the app.
///
/// Deliberately not a dropdown or a sheet here: someone whose phone guessed the
/// wrong language cannot read the label on a closed menu, so every option has
/// to be on screen at the moment they arrive. Two letters each, which is
/// legible in any of the three.
class LanguageSegmentedControl extends StatelessWidget {
  const LanguageSegmentedControl({super.key, this.onSurface = false});

  /// True over a photograph, where the control needs its own translucent
  /// backing to stay readable.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LocaleCubit>();
    final l10n = context.l10n;

    return Semantics(
      label: l10n.languageTitle,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: onSurface
              ? Colors.black.withValues(alpha: 0.32)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: onSurface
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final language in AppLanguage.values)
              _LanguagePill(
                language: language,
                selected: cubit.language == language,
                onSurface: onSurface,
                // The full name is what a screen reader reads out; the two
                // letters on screen would be spelled or mispronounced.
                semanticLabel: language.label(l10n),
                onTap: () {
                  HapticFeedback.selectionClick();
                  cubit.setLanguage(language);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.language,
    required this.selected,
    required this.onSurface,
    required this.semanticLabel,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final bool onSurface;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = onSurface
        ? (selected ? AppColors.heading : Colors.white)
        : (selected ? Colors.white : AppColors.muted);
    final bg = selected
        ? (onSurface ? Colors.white : AppColors.cta)
        : Colors.transparent;

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: semanticLabel,
      // ExcludeSemantics below hides the InkWell, and with it the tap action.
      // Declaring it here is what keeps the pill activatable rather than
      // merely announced.
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: AppMotion.base,
            curve: AppMotion.enter,
            // 44 tall inside a 4dp-padded bar clears the 48dp floor for the
            // control as a whole while keeping the bar itself compact.
            constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              language.short,
              style: AppText.labelSm.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The language picker as a sheet, for the account screen.
///
/// A sheet rather than three pills on a settings row: the row stays one line
/// tall, and the sheet has room to name each language in its own language
/// without squeezing — a picker that labels "Русский" as "Rus tili" is
/// unreadable to the person who needs it most.
Future<void> showLanguageSheet(BuildContext context) async {
  final cubit = context.read<LocaleCubit>();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    // The sheet has to sit above the gesture bar, and its own padding is what
    // keeps the last row tappable on a phone without a home button.
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return BlocProvider.value(
        value: cubit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetGrabber(),
                const SizedBox(height: 16),
                Text(l10n.languageTitle, style: AppText.h3),
                const SizedBox(height: 6),
                for (final language in AppLanguage.values)
                  _LanguageRow(
                    label: language.label(l10n),
                    selected: cubit.language == language,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      cubit.setLanguage(language);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: selected
                      ? AppText.body.copyWith(fontWeight: FontWeight.w800)
                      : AppText.body,
                ),
              ),
              // The tick is the second signal beside the weight change: bold
              // alone is not a state a person can be sure of at a glance.
              if (selected)
                const Icon(Icons.check_rounded,
                    size: 21, color: AppColors.cta),
            ],
          ),
        ),
      ),
    );
  }
}
