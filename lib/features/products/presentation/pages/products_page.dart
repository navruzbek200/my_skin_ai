import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/theme/typography.dart';
import 'package:real_beauty_ai/core/utils/price.dart';
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/features/products/presentation/bloc/products_cubit.dart';
import 'package:real_beauty_ai/widgets/buttons.dart';
import 'package:real_beauty_ai/widgets/chip_button.dart';
import 'package:real_beauty_ai/data/product_categories.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';

class ProductsScreen extends StatelessWidget {
  @visibleForTesting
  final ProductsCubit? testCubit;

  const ProductsScreen({super.key, this.testCubit});

  @override
  Widget build(BuildContext context) {
    final override = testCubit;
    if (override != null) {
      return BlocProvider.value(
        value: override,
        child: const _ProductsBody(),
      );
    }
    return BlocProvider(
      create: (_) => ProductsCubit()..load(),
      child: const _ProductsBody(),
    );
  }
}

class _ProductsBody extends StatefulWidget {
  const _ProductsBody();

  @override
  State<_ProductsBody> createState() => _ProductsBodyState();
}

class _ProductsBodyState extends State<_ProductsBody> {
  int _selectedChip = 0;
  // The chips come from `productCategories`, where each one carries a Firestore
  // key and a translated label. Filtering on the key rather than on the visible
  // text is what keeps every chip working after a language change.
  static const _chips = productCategories;

  List<Product> _filtered(List<Product> all) {
    if (_selectedChip == 0) return all;
    final cat = _chips[_selectedChip].key;
    return all.where((p) => p.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final List<Product> items =
            state is ProductsLoaded ? state.items : [];
        final List<Product> filtered = _filtered(items);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            // Build and start fetching roughly a screen ahead of the viewport,
            // so a fast flick lands on cards whose images are already in
            // flight rather than on empty ones.
            cacheExtent: 1200,
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(context.l10n.productsHeading,
                                style: AppText.h2),
                            const SizedBox(width: 10),
                            // How many are on the shelf right now. A catalogue
                            // that never says how big it is leaves the person
                            // scrolling to find out.
                            if (state is ProductsLoaded)
                              Text(
                                context.l10n.productsCount(filtered.length),
                                style: AppText.caption,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            // Was an off-brand sage green that belonged to
                            // nothing else on the screen.
                            color: AppColors.accentSoft,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 55,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 16, 0, 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.productsTitle,
                                          style: AppText.h3.copyWith(
                                            color: AppColors.heading,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 45,
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Image.asset(
                                        'assets/products_banner.jpg',
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
              // Its own sliver rather than a row inside the padded column
              // above: the strip runs edge to edge and pads itself back in, so
              // the last chip scrolls fully clear of the gutter instead of
              // being clipped by the page's 20dp padding.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: SizedBox(
                    height: AppTouch.min,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _chips.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => Center(
                        child: ChipButton(
                          label: context.tr(_chips[i].label),
                          selected: _selectedChip == i,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedChip = i);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (state is ProductsLoading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      // Matches the real grid below, so the skeleton does not
                      // reflow into a different shape the moment data lands.
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEAF8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(
                            duration: const Duration(milliseconds: 1200),
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                      childCount: 6,
                    ),
                  ),
                )
              else if (state is ProductsError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _StateBlock(
                    icon: Icons.wifi_off_rounded,
                    title: context.l10n.productsError,
                    body: context.l10n.productsErrorBody,
                    // An error state without a way out is a dead end: the
                    // whole screen is unusable and the only recourse was to
                    // leave the tab and come back.
                    action: context.l10n.commonRetry,
                    onAction: () => context.read<ProductsCubit>().load(),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _StateBlock(
                    icon: Icons.search_off_rounded,
                    title: context.l10n.productsEmpty,
                    body: context.l10n.productsEmptyBody,
                    // Clearing the filter is the actual fix for this state,
                    // and it was two taps away with nothing pointing at it.
                    action: _selectedChip == 0
                        ? null
                        : context.l10n.productsFilterAll,
                    onAction: () => setState(() => _selectedChip = 0),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      // 0.62 rather than 0.65: the card gained a price line,
                      // and at the old ratio the name and the price fought
                      // over the same few pixels at the largest text scale.
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ProductCard(product: filtered[i]),
                      childCount: filtered.length,
                      // Deliberately no keep-alives: the cards are stateless,
                      // so there is nothing to keep, and holding 54 elements
                      // alive would only cost memory. What actually stops a
                      // scrolled-past card from re-fetching is the raised
                      // image cache in main.dart, which holds the decoded
                      // thumbnails for the whole grid.
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Opens the product detail sheet from anywhere in the app.
///
/// The page itself stays private: it is an implementation detail of this
/// screen, and exporting the widget would invite other features to build it
/// with their own transition. Exporting the *action* keeps one entry point, so
/// a product opened from the Bugun routine animates exactly like one opened
/// from the catalogue.
void openProductDetail(BuildContext context, Product product) {
  HapticFeedback.selectionClick();
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, _, _) => _ProductDetailPage(product: product),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 280),
    ),
  );
}

// ── Product image helper ──────────────────────────────────────

/// Widest bitmap we ever decode. Matches the width the build pipeline caps
/// stored images at, so asking for more would only upscale.
const _maxDecodeWidth = 1400;

/// Decodes at exactly the number of physical pixels the widget will occupy —
/// box width in logical pixels times the device pixel ratio.
///
/// A fixed number cannot work here: the same 180dp grid cell is 360 real
/// pixels on a cheap 2x phone and 720 on a 4x flagship. Guessing low makes a
/// blurry picture on good screens; guessing high wastes memory on cheap ones,
/// and product packaging is covered in fine print that shows both mistakes
/// immediately.
Widget _productImage(
  Product product, {
  BoxFit fit = BoxFit.contain,
  bool thumb = false,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final logical = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final decodeWidth = (logical * dpr).round().clamp(1, _maxDecodeWidth);

      final url = thumb && (product.thumbUrl?.isNotEmpty ?? false)
          ? product.thumbUrl!
          : product.imageUrl;

      if (url != null && url.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          memCacheWidth: decodeWidth,
          // The default half-second cross-fade runs even for an image already
          // on disk, which on a grid reads as everything arriving late.
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          // A spinner per cell turns an ordinary load into visible waiting.
          // An empty card is quieter and the picture simply appears.
          placeholder: (_, _) => const ColoredBox(color: Colors.white),
          errorWidget: (_, _, _) => const Icon(
              Icons.image_outlined,
              size: 40,
              color: Color(0xFFCCC8E0)),
        );
      }
      return Image.asset(
        product.imagePath,
        fit: fit,
        cacheWidth: decodeWidth,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.image_outlined, size: 40, color: Color(0xFFCCC8E0)),
      );
    },
  );
}

// ── Product card (grid) ───────────────────────────────────────

/// One cell of the catalogue grid.
///
/// Stateful only to hold the pressed flag: this is the primary way into every
/// product, and a card that does not move under a finger reads as a picture
/// rather than as a control.
class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final priceLabel = context.priceOrNull(product.price);

    return Semantics(
      button: true,
      // One sentence covering everything the card shows, so a screen reader
      // does not read out brand, chip, name and price as four unrelated
      // fragments.
      label: '${product.brand}. ${product.name}. '
          '${priceLabel ?? context.tr(product.subtitle)}',
      onTap: () => openProductDetail(context, product),
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            openProductDetail(context, product);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed && !reduceMotion ? 0.97 : 1.0,
            duration: AppMotion.fast,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy
                        .withValues(alpha: _pressed ? 0.05 : 0.09),
                    blurRadius: _pressed ? 8 : 16,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    // 62/38 rather than 58/42: the packaging is what
                    // distinguishes one white tube from another at a glance,
                    // and the text block below only carries three short lines.
                    flex: 62,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.lg)),
                            child: ColoredBox(
                              color: AppColors.card,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: _productImage(product, thumb: true),
                              ),
                            ),
                          ),
                        ),
                        // Over the picture rather than in the text block: the
                        // block below is the readable half of the card and
                        // every line in it now has to earn its place.
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _CategoryChip(
                            label:
                                context.tr(labelForCategory(product.category)),
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 38,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Packed to the top with measured gaps rather than
                        // spaceBetween, which spread three short lines across
                        // the whole block and left the card looking empty.
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // 11 rather than the 10 this was: brand names are
                            // set in caps and small caps go illegible first.
                            style: AppText.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            // 13, up from 12. This is the line people actually
                            // read to tell two tubes apart.
                            style: AppText.caption.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                              height: 1.25,
                            ),
                          ),
                          const Spacer(),
                          // The card carried no third line at all. Price is
                          // what a shopping cell exists to deliver, so it wins
                          // when there is one — but `price` is an optional
                          // column and the shelf is currently unpriced, so the
                          // claim on the tube stands in rather than fifty-four
                          // identical "price on request" lines.
                          if (priceLabel != null)
                            Text(
                              priceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bodySm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.heading,
                                // Tabular figures: without them the prices in
                                // two columns do not line up, and a grid of
                                // misaligned numbers reads as sloppy.
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            )
                          else
                            Text(
                              context.tr(product.subtitle),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cta,
                              ),
                            ),
                        ],
                      ),
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

/// Empty and error states, which are the same shape: say what happened, say
/// what it means, and offer the one thing that fixes it.
///
/// Both used to be an icon and a line of grey text with nothing to press —
/// which leaves somebody staring at a screen that has stopped working with no
/// idea what to do about it.
class _StateBlock extends StatelessWidget {
  const _StateBlock({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Null when there is nothing useful to offer — an empty "all products"
  /// catalogue cannot be fixed by clearing a filter that is not set.
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.cta),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: AppText.h3),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: AppText.bodyMuted),
            if (action != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: SecondaryPillButton(
                  label: action!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The category pill, in two sizes — one for the grid cell, one for the
/// detail page. Defined once so the two can never drift apart.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        // Opaque rather than a 10% tint: on the grid this sits over product
        // photography, where a translucent fill let the packaging show through
        // and the label stopped being readable.
        color: compact ? AppColors.accentSoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: AppColors.cta,
        ),
      ),
    );
  }
}

class _ProductDetailPage extends StatelessWidget {
  final Product product;
  const _ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FC),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.50,
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, topPad + 48, 16, 0),
                child: _productImage(product),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.38,
            left: 0,
            right: 0,
            height: size.height * 0.12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.6),
                    const Color(0xFFF5F2FC),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.46,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x185040A0),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    EdgeInsets.fromLTRB(24, 16, 24, bottomPad + 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0DCF0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          product.brand,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        _CategoryChip(
                          label:
                              context.tr(labelForCategory(product.category)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2050),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              context.tr(product.subtitle),
                              style: AppText.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.cta,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // The page had no price on it at all. It is the one
                        // fact somebody opens a product to find, so it sits at
                        // the top beside the name rather than buried below.
                        Text(
                          context.price(product.price),
                          style: AppText.h3.copyWith(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    const Divider(color: Color(0xFFECE8F5), thickness: 1),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.productsBenefits,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D2050),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...product.benefits.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7060AA)
                                        .withValues(alpha: 0.09),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${e.key + 1}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF7060AA),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 9),
                                    child: Text(
                                      context.tr(e.value),
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4A3C90),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topPad + 8,
            left: 12,
            child: Material(
              color: AppColors.card,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: AppColors.navy.withValues(alpha: 0.25),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                // Was a 42dp GestureDetector with no label: under the tap
                // floor, and silent to a screen reader.
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                iconSize: 20,
                constraints: const BoxConstraints.tightFor(
                  width: AppTouch.min,
                  height: AppTouch.min,
                ),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.cta),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
