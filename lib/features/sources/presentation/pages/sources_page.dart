import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/data/sources_data.dart';
import 'package:url_launcher/url_launcher.dart';

/// The citation list behind every care note in the app.
///
/// Guideline 1.4.1 asks that the sources be "easy for the user to find", so
/// this screen is linked from three places: under the disclaimer on the
/// analysis tab, at the foot of the results screen, and from the account
/// screen. Each row opens the publisher's own page in the browser.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  static Future<void> open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _warn(messenger);
    } catch (e, st) {
      AppLogger.error('Could not open source $url', e, st);
      _warn(messenger);
    }
  }

  static void _warn(ScaffoldMessengerState? messenger) {
    messenger?.showSnackBar(
      const SnackBar(content: Text("Havolani ochib bo'lmadi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // One card per publisher, so the list reads as "who says this" rather
    // than as fifteen loose links.
    final byPublisher = <String, List<SkinSource>>{};
    for (final s in skinSources) {
      byPublisher.putIfAbsent(s.publisher, () => []).add(s);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Manbalar',
          style: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(
            "Ilovadagi parvarish maslahatlari quyidagi ochiq, nufuzli "
            "manbalarga tayanadi. Har bir havolani bosib, asl matnni o'qishingiz mumkin.",
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          for (final entry in byPublisher.entries) ...[
            _PublisherCard(publisher: entry.key, sources: entry.value),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ilova kosmetik parvarish bo'yicha umumiy ma'lumot beradi "
                    "va tibbiy tashxis yoki davolash vositasi emas. "
                    "Teringiz holati bo'yicha savollaringiz bo'lsa, malakali "
                    "shifokorga murojaat qiling.",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublisherCard extends StatelessWidget {
  final String publisher;
  final List<SkinSource> sources;

  const _PublisherCard({required this.publisher, required this.sources});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              publisher,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          for (final s in sources) _SourceRow(source: s),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final SkinSource source;
  const _SourceRow({required this.source});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: '${source.title} — ${source.publisher}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => SourcesScreen.open(context, source.url),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source.title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      source.url,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 8),
                child: Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
