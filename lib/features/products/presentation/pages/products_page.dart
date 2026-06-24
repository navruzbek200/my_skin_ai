import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/features/products/presentation/bloc/products_cubit.dart';
import 'package:real_beauty_ai/widgets/chip_button.dart';

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
  final _chips = ['Barchasi', 'SPF', 'Tozalovchi', 'Niqob', 'Peeling', 'Remover'];

  List<Product> _filtered(List<Product> all) {
    if (_selectedChip == 0) return all;
    final cat = _chips[_selectedChip];
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
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mahsulotlar',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            color: const Color(0xFFEAEFE8),
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5A7A52)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'Maxsus taklif',
                                            style: GoogleFonts.nunito(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF3D5C36),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Koreya brend\nmahsulotlar',
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF2A3D27),
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tabiat kuchi bilan — −20%',
                                          style: GoogleFonts.nunito(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF5A7A52),
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
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _chips
                                .asMap()
                                .entries
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8),
                                      child: ChipButton(
                                        label: e.value,
                                        selected: _selectedChip == e.key,
                                        onTap: () => setState(
                                            () => _selectedChip = e.key),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is ProductsLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (state is ProductsError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.message,
                          style: GoogleFonts.nunito(
                              fontSize: 14, color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<ProductsCubit>().load(),
                          child: Text(
                            'Qaytadan urinish',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Mahsulot topilmadi',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
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
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ProductCard(
                          product: filtered[i], index: i),
                      childCount: filtered.length,
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

// ── Product image helper ──────────────────────────────────────

Widget _productImage(Product product, {BoxFit fit = BoxFit.contain}) {
  if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: product.imageUrl!,
      fit: fit,
      placeholder: (_, _) => const Center(
        child: CircularProgressIndicator(
            strokeWidth: 1.5, color: AppColors.primary),
      ),
      errorWidget: (_, _, _) => const Icon(
          Icons.image_outlined,
          size: 40,
          color: Color(0xFFCCC8E0)),
    );
  }
  return Image.asset(
    product.imagePath,
    fit: fit,
    errorBuilder: (_, _, _) =>
        const Icon(Icons.image_outlined, size: 40, color: Color(0xFFCCC8E0)),
  );
}

// ── Product card (grid) ───────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const _ProductCard({required this.product, required this.index});

  void _openDetail(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 68,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _productImage(product),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 32,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.brand,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7060AA)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7060AA),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.25,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward_rounded,
                            size: 13, color: Color(0xFF9490B0)),
                        const SizedBox(width: 4),
                        Text(
                          'Batafsil',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9490B0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn()
        .scale(begin: const Offset(0.96, 0.96));
  }
}

// ── Product detail page ───────────────────────────────────────

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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7060AA)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7060AA),
                            ),
                          ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECF8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7060AA),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
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
                          'Foydali tomonlari',
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
                                      e.value,
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
            top: topPad + 12,
            left: 16,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5040A0).withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF4A3C90),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
