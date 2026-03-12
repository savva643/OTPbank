import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../core/theme/otp_colors.dart';
import '../../../core/widgets/otp_offers_carousel.dart';
import '../bloc/products_bloc.dart';
import 'products_search_screen.dart';
import '../domain/product_ui_config.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const ProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductsBloc>().state;

    final searchItems = <String>{
      ...state.categories,
      'Автокредит',
      'Кредит наличными',
      'Ипотека на новостройку',
      'Загородный дом',
      'Страхование',
      'Инвестиции',
      'Путешествия',
      'Накопительный счёт',
      'Инвесткопилка',
    }.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const _HeaderGradientBackground(),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProductsHeader(
                onSearchTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductsSearchScreen(items: searchItems),
                    ),
                  );
                },
              ),
              Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == ProductsStatus.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text('Загрузка...'),
                          ),
                        _SectionHeader(
                          title: 'Кредиты',
                          action: 'Все',
                          onActionTap: () {},
                        ),
                        const SizedBox(height: 16),
                        const _HorizontalProductsRow(
                          items: [
                            _ProductCardData(
                              title: 'Автокредит',
                              subtitle: 'Новое авто или с пробегом',
                              badgeText: 'ВЫГОДНО',
                              badgeValue: 'от 4.5%',
                              variant: _ProductCardVariant.light,
                              icon: Icons.directions_car_rounded,
                            ),
                            _ProductCardData(
                              title: 'Кредит\nналичными',
                              subtitle: 'До 2 000 000 ₽',
                              badgeText: 'БЫСТРО',
                              badgeValue: 'за 5 мин',
                              variant: _ProductCardVariant.dark,
                              icon: Icons.account_balance_wallet_rounded,
                            ),
                            _ProductCardData(
                              title: 'Ипотека на\nновостройку',
                              subtitle: 'Первый взнос от 15%',
                              badgeText: 'АКЦИЯ',
                              badgeValue: '6%',
                              variant: _ProductCardVariant.purple,
                              icon: Icons.home_work_rounded,
                            ),
                            _ProductCardData(
                              title: 'Загородный дом',
                              subtitle: 'ИЖС и участки',
                              badgeText: null,
                              badgeValue: null,
                              variant: _ProductCardVariant.purple,
                              icon: Icons.house_siding_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Другое',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: _MiniTile(
                                  title: 'Страхование',
                                  subtitle: 'Жизнь и здоровье',
                                  icon: Icons.health_and_safety_rounded,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _MiniTile(
                                  title: 'Инвестиции',
                                  subtitle: 'Акции и облигации',
                                  icon: Icons.trending_up_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderGradientBackground extends StatefulWidget {
  const _HeaderGradientBackground();

  @override
  State<_HeaderGradientBackground> createState() => _HeaderGradientBackgroundState();
}

class _HeaderGradientBackgroundState extends State<_HeaderGradientBackground> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.02, 0.02),
          end: Alignment(1.02, 0.98),
          colors: [OtpColors.orangeAccent, OtpColors.lightBlue],
        ),
      ),
    );
  }
}

class _ProductsHeader extends StatefulWidget {
  const _ProductsHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  State<_ProductsHeader> createState() => _ProductsHeaderState();
}

class _ProductsHeaderState extends State<_ProductsHeader> {
  @override
  Widget build(BuildContext context) {
    void openProduct(String title) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailsScreen(
            data: ProductDetailsMock.byTitle(title),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Продукты',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.20,
                    letterSpacing: -0.75,
                  ),
                ),
                _HeaderIconButton(
                  onTap: widget.onSearchTap,
                  icon: Icons.search_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            OtpOffersCarousel(
              items: [
                OtpOfferItem(
                  kicker: 'ВАШИ ПУТЕШЕСТВИЯ',
                  kickerColor: const Color(0xFF2563EB),
                  title: 'Путешествия',
                  description: 'Роуминг, страховка\nи полезные сервисы.',
                  cardBg: const Color(0xFFC8E1FC),
                  cardBorder: const Color(0xFFFFFFFF),
                  ctaLabel: 'Подробнее',
                  ctaBg: const Color(0xFFFF7D32),
                  watermarkIcon: Icons.flight_takeoff_rounded,
                  onTap: () => openProduct('Путешествия'),
                ),
                OtpOfferItem(
                  kicker: 'НЕДВИЖИМОСТЬ',
                  kickerColor: const Color(0xFF475569),
                  title: 'Ипотека 6%',
                  description: 'Акция для семей\nс детьми.',
                  cardBg: const Color(0xFFF1F5F9),
                  cardBorder: const Color(0xFFE2E8F0),
                  ctaLabel: 'Рассчитать',
                  ctaBg: const Color(0xFF0F172A),
                  watermarkIcon: Icons.home_work_rounded,
                  onTap: () => openProduct('Ипотека'),
                ),
                OtpOfferItem(
                  kicker: 'АВТО',
                  kickerColor: const Color(0xFF0F172A),
                  title: 'Автокредит',
                  description: 'Подбор условий\nи одобрение онлайн.',
                  cardBg: const Color(0xFFFFEDD5),
                  cardBorder: const Color(0xFFFFFFFF),
                  ctaLabel: 'Подобрать',
                  ctaBg: const Color(0xFF0F172A),
                  watermarkIcon: Icons.directions_car_rounded,
                  onTap: () => openProduct('Автокредит'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({required this.onTap, required this.icon});

  final VoidCallback onTap;
  final IconData icon;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Icon(widget.icon, color: Colors.white),
      ),
    );
  }
}

class _PromoCard extends StatefulWidget {
  const _PromoCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String ctaLabel;

  @override
  State<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<_PromoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 342),
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: const Color(0xCCC8E1FC),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.20)),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: ShapeDecoration(
              color: OtpColors.primaryLime,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                )
              ],
            ),
            child: Text(
              widget.badge,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: ShapeDecoration(
              color: OtpColors.purpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Text(
              widget.ctaLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsSearchDelegate extends SearchDelegate<String?> {
  _ProductsSearchDelegate({required this.items});

  final List<String> items;

  @override
  String? get searchFieldLabel => 'Поиск продукта';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 16,
        height: 1.3,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = items.where((e) => e.toLowerCase().contains(q)).toList();
    return _ResultsGrid(results: results, query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = q.isEmpty
        ? items.take(8).toList()
        : items.where((e) => e.toLowerCase().contains(q)).take(12).toList();
    return _ResultsGrid(results: results, query: query);
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.results, required this.query});

  final List<String> results;
  final String query;

  List<TextSpan> _highlight(String text, String q) {
    final needle = q.trim();
    if (needle.isEmpty) return [TextSpan(text: text)];

    final lower = text.toLowerCase();
    final lowerNeedle = needle.toLowerCase();

    final idx = lower.indexOf(lowerNeedle);
    if (idx < 0) return [TextSpan(text: text)];

    final before = text.substring(0, idx);
    final match = text.substring(idx, idx + needle.length);
    final after = text.substring(idx + needle.length);

    return [
      TextSpan(text: before),
      TextSpan(
        text: match,
        style: const TextStyle(
          color: OtpColors.purpleAccent,
          fontWeight: FontWeight.w800,
        ),
      ),
      TextSpan(text: after),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.0,
      padding: const EdgeInsets.all(16),
      children: results
          .map(
            (t) => InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.widgets_rounded, size: 18, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          children: _highlight(t, query),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DotsIndicator extends StatefulWidget {
  const _DotsIndicator({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  State<_DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<_DotsIndicator> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (i) {
        final active = i == widget.activeIndex;
        return Padding(
          padding: EdgeInsets.only(right: i == widget.count - 1 ? 0 : 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? OtpColors.purpleAccent : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatefulWidget {
  const _SectionHeader({required this.title, this.action, this.onActionTap});

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          if (widget.action != null)
            InkWell(
              onTap: widget.onActionTap,
              child: Text(
                widget.action!,
                style: const TextStyle(
                  color: Color(0xFFBAB8BA),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _ProductCardVariant { light, dark, purple }

class _ProductCardData {
  const _ProductCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.variant,
    this.badgeText,
    this.badgeValue,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _ProductCardVariant variant;
  final String? badgeText;
  final String? badgeValue;
}

class _HorizontalProductsRow extends StatefulWidget {
  const _HorizontalProductsRow({required this.items});

  final List<_ProductCardData> items;

  @override
  State<_HorizontalProductsRow> createState() => _HorizontalProductsRowState();
}

class _HorizontalProductsRowState extends State<_HorizontalProductsRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return _ProductCard(data: widget.items[index]);
        },
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.data});

  final _ProductCardData data;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  Color _textColor(_ProductCardVariant v, {required bool isDarkBg}) {
    if (v == _ProductCardVariant.dark || v == _ProductCardVariant.purple || isDarkBg) return Colors.white;
    return const Color(0xFF0F172A);
  }

  Color _subTextColor(_ProductCardVariant v, {required bool isDarkBg}) {
    if (v == _ProductCardVariant.dark || v == _ProductCardVariant.purple || isDarkBg) {
      return Colors.white.withOpacity(0.80);
    }
    return const Color(0xFF334155);
  }

  BoxDecoration _decoration(_ProductCardVariant v) {
    final cfg = ProductUiConfig.byTitle(widget.data.title.replaceAll('\n', ' '));
    if (v == _ProductCardVariant.dark) {
      return BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      );
    }
    if (v == _ProductCardVariant.purple) {
      return BoxDecoration(
        color: OtpColors.purpleAccent,
        borderRadius: BorderRadius.circular(24),
      );
    }
    return BoxDecoration(
      color: cfg.tileBg,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final cfg = ProductUiConfig.byTitle(d.title.replaceAll('\n', ' '));
    final isDarkBg = cfg.tileBg.computeLuminance() < 0.18;
    final isWide = d.title.contains('Автокредит') || d.title.contains('Ипотека');

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailsScreen(
              data: ProductDetailsMock.byTitle(cfg.title),
            ),
          ),
        );
      },
      child: Container(
        width: isWide ? 280 : 176,
        padding: const EdgeInsets.all(20),
        decoration: _decoration(d.variant),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Icon(cfg.icon, color: const Color(0xFF0F172A)),
                ),
                if (d.badgeText != null || d.badgeValue != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (d.badgeText != null)
                        Text(
                          d.badgeText!,
                          style: TextStyle(
                            color: _textColor(d.variant, isDarkBg: isDarkBg),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                            letterSpacing: 0.50,
                          ),
                        ),
                      if (d.badgeValue != null)
                        Text(
                          d.badgeValue!,
                          style: TextStyle(
                            color: _textColor(d.variant, isDarkBg: isDarkBg),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.43,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textColor(d.variant, isDarkBg: isDarkBg),
                    fontSize: isWide ? 18 : 14,
                    fontWeight: FontWeight.w700,
                    height: isWide ? 1.56 : 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _subTextColor(d.variant, isDarkBg: isDarkBg),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatefulWidget {
  const _MiniTile({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  State<_MiniTile> createState() => _MiniTileState();
}

class _MiniTileState extends State<_MiniTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {},
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-37.0, -37.0),
            radius: 1.24,
            colors: [Colors.black.withOpacity(0.02), Colors.black.withOpacity(0)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(width: 1, color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Icon(widget.icon, size: 20, color: const Color(0xFF0F172A)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
