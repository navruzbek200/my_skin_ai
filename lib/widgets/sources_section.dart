import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/models/source.dart';

/// Opens a citation in Safari (or the system browser on Android).
///
/// Not the in-app browser view: on the iOS 18.6 simulator it opened as a blank
/// white sheet and stayed that way, while Safari loaded the same pages at
/// once. A reviewer who taps a citation and sees nothing reads that as "no
/// citation", so this goes the way the privacy-policy link already does, and a
/// failure to open is reported rather than swallowed.
Future<void> openSource(BuildContext context, Source source) async {
  HapticFeedback.selectionClick();
  final uri = Uri.parse(source.url);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failed = context.l10n.sourcesOpenFailed;
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e, st) {
    AppLogger.error('Source link threw: ${source.url}', e, st);
  }
  if (ok) {
    AppLogger.info('Source opened', source.url);
  } else {
    AppLogger.warning('Source did not open', source.url);
    messenger?.showSnackBar(SnackBar(content: Text(failed)));
  }
}

/// The references under a recommendation, a concern page or an article.
///
/// Renders nothing when [sources] is empty, so a screen can always include it
/// and only copy that has citations shows the card. Long lists — a result
/// with several concern blocks cites a dozen papers — open on the first
/// [collapsedCount] with the rest one tap away, so the card never outweighs
/// the advice it supports.
class SourcesSection extends StatefulWidget {
  const SourcesSection({
    super.key,
    required this.sources,
    this.onSeeAll,
    this.collapsedCount = 3,
  });

  final List<Source> sources;

  /// When set, a last row leads to the full "Sources & methodology" screen.
  final VoidCallback? onSeeAll;

  /// How many rows show before "N more". A list only collapses when hiding
  /// would save at least two rows — folding away a single row just adds a tap.
  final int collapsedCount;

  @override
  State<SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<SourcesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final sources = widget.sources;
    if (sources.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final collapsible = sources.length - widget.collapsedCount >= 2;
    final visible = collapsible && !_expanded
        ? sources.take(widget.collapsedCount).toList()
        : sources;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // A Material, not a coloured box: the rows' ink has to paint on the
      // card itself, or every tap ripples invisibly underneath it.
      child: Material(
        color: AppColors.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(count: sources.length, title: l10n.sourcesTitle),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: SourceList(sources: visible),
            ),
            if (collapsible)
              _FooterRow(
                label: _expanded
                    ? l10n.sourcesShowLess
                    : l10n.sourcesShowMore(sources.length - visible.length),
                icon: _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
            if (widget.onSeeAll != null)
              _FooterRow(
                label: l10n.sourcesSeeAll,
                icon: Icons.chevron_right_rounded,
                onTap: widget.onSeeAll!,
              ),
          ],
        ),
      ),
    );
  }
}

/// A run of [SourceTile]s with hairlines between them, numbered from
/// [firstNumber]. Shared by the in-context card and the full sources screen
/// so a citation looks the same wherever it is met.
class SourceList extends StatelessWidget {
  const SourceList({super.key, required this.sources, this.firstNumber = 1});

  final List<Source> sources;
  final int firstNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sources.length; i++) ...[
          if (i > 0) const _Hairline(),
          SourceTile(source: sources[i], number: firstNumber + i),
        ],
      ],
    );
  }
}

/// One citation: a numbered row with the headline first, then who published
/// it and the site it opens, and an outward arrow that says "leaves the app".
class SourceTile extends StatelessWidget {
  const SourceTile({super.key, required this.source, required this.number});

  final Source source;
  final int number;

  @override
  Widget build(BuildContext context) {
    // Non-breaking on both sides of the dot: a wrap then carries the last word
    // of the publisher, the dot and the site down together, instead of
    // leaving a dangling "·" at the end of a line.
    final meta = [
      if (source.publisher.isNotEmpty) source.publisher,
      source.domain,
    ].join('\u00A0\u00A0·\u00A0\u00A0');

    return MergeSemantics(
      child: Semantics(
        link: true,
        hint: source.domain,
        child: InkWell(
          onTap: () => openSource(context, source),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(child: _NumberBadge(number: number)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.headline,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          meta,
                          style: GoogleFonts.nunito(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bottom sheet holding [sources] — for places, like a quiz question, where
/// pushing a whole screen would lose the reader's place.
Future<void> showSourcesSheet(BuildContext context, List<Source> sources) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SourcesSection(sources: sources),
    ),
  );
}

// ── Pieces ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.title});

  final int count;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 17,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$number',
        style: GoogleFonts.nunito(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        Semantics(
          button: true,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppTouch.min),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(icon, size: 20, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    // Inset to the text column, iOS-list style, so the numbers read as one
    // unbroken gutter.
    return const Padding(
      padding: EdgeInsets.only(left: 52),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}
