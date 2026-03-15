import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/otp_colors.dart';
import '../../../core/widgets/otp_avatar_button.dart';
import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_offers_carousel.dart';
import '../../../core/widgets/otp_primary_button.dart';
import '../../../core/widgets/otp_round_action_button.dart';
import '../../../core/widgets/otp_story_tile.dart';
import '../../../core/widgets/otp_webp_image.dart';
import '../../../core/config/app_config.dart';
import '../../accounts/presentation/account_details_screen.dart';
import '../../bonuses/presentation/bonuses_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../payments/presentation/sbp_transfer_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../products/bloc/products_bloc.dart';
import '../../products/domain/product_ui_config.dart';
import '../../products/presentation/product_details_screen.dart';
import '../../products/widgets/otp_product_tile.dart';
import '../../shell/presentation/root_shell.dart';
import '../bloc/home_bloc.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../stories/presentation/story_screen.dart';
import '../../properties/presentation/properties_screen.dart';
import '../../vehicles/presentation/vehicles_screen.dart';

Color? _parseHexColor(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty) return null;
  final normalized = v.startsWith('#') ? v.substring(1) : v;
  if (normalized.length == 6) {
    final parsed = int.tryParse('FF$normalized', radix: 16);
    return parsed == null ? null : Color(parsed);
  }
  if (normalized.length == 8) {
    final parsed = int.tryParse(normalized, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
  return null;
}

class HomeTabContent extends StatefulWidget {
  const HomeTabContent({super.key});

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return 'Доброе утро';
    if (hour >= 12 && hour < 18) return 'Добрый день';
    if (hour >= 18 && hour < 23) return 'Добрый вечер';
    return 'Доброй ночи';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final userName = (state.userName ?? '').trim();
    final greeting = _greeting(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OtpAvatarButton(
                radius: 21,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                imageUrl: state.avatarUrl,
                initials: userName.isNotEmpty ? userName.substring(0, 1) : 'U',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/img/logo.png',
                      height: 16,
                      color: Colors.black,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      userName.isNotEmpty ? '$greeting, $userName' : greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded, size: 26),
              ),
              Stack(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_none_rounded, size: 26),
                  ),
                  // Badge для непрочитанных
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC1FF05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _StoriesRow(),
        const SizedBox(height: 16),
        _CardsCarousel(),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _QuickActionsRow(),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _BonusesBanner(),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _HomeAutoRow(),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _SectionTitle(title: 'Витрина продуктов'),
        ),
        const SizedBox(height: 12),
        _OffersCarouselSection(),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _RecommendedProductsGrid(),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _OpenProductButton(),
        ),
      ],
    );
  }
}

class _RecommendedProductsGrid extends StatefulWidget {
  const _RecommendedProductsGrid();

  @override
  State<_RecommendedProductsGrid> createState() => _RecommendedProductsGridState();
}

class _RecommendedProductsGridState extends State<_RecommendedProductsGrid> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductsBloc>().state;
    final items = state.bottomProducts;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final item in items)
          OtpProductTile(
            product: ProductUiConfig.byTitle(item.title),
            size: OtpProductTileSize.mediumWide,
            subtitle: (item.description ?? item.categoryName)?.trim().isNotEmpty == true
                ? (item.description ?? item.categoryName)
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProductDetailsScreen(
                    productId: item.id,
                    titleFallback: item.title,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _RecommendedProductTile extends StatefulWidget {
  const _RecommendedProductTile({
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color bg;
  final IconData icon;

  @override
  State<_RecommendedProductTile> createState() => _RecommendedProductTileState();
}

class _RecommendedProductTileState extends State<_RecommendedProductTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(width: 1, color: Colors.white.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Icon(widget.icon, color: const Color(0xFF0F172A), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OffersCarouselSection extends StatefulWidget {
  const _OffersCarouselSection();

  @override
  State<_OffersCarouselSection> createState() => _OffersCarouselSectionState();
}

class _OffersCarouselSectionState extends State<_OffersCarouselSection> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductsBloc>().state;
    final offers = state.showcaseOffers;

    void openProduct(ProductShowcaseOffer offer) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailsScreen(
            productId: offer.productId,
            titleFallback: offer.productName,
          ),
        ),
      );
    }

    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return OtpOffersCarousel(
      items: [
        for (final offer in offers)
          OtpOfferItem(
            kicker: offer.kicker,
            kickerColor: _parseHexColor(offer.ctaColor) ?? const Color(0xFF475569),
            title: offer.title,
            description: offer.description,
            cardBg: _parseHexColor(offer.bgColor) ?? const Color(0xFFF1F5F9),
            cardBorder: _parseHexColor(offer.borderColor) ?? Colors.white,
            ctaLabel: offer.ctaLabel,
            ctaBg: _parseHexColor(offer.ctaColor) ?? const Color(0xFF0F172A),
            watermarkIcon: ProductUiConfig.byTitle(offer.title).icon,
            onTap: () {
              openProduct(offer);
            },
          ),
      ],
    );
  }
}

class _SectionTitle extends StatefulWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  State<_SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<_SectionTitle> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
    );
  }
}

class _StoriesRow extends StatefulWidget {
  const _StoriesRow();

  @override
  State<_StoriesRow> createState() => _StoriesRowState();
}

class _StoriesRowState extends State<_StoriesRow> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final items = state.stories;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _StoryTile(
              label: items[i].title,
              borderColor: const Color(0xFFC4FF2E),
              dimmed: false,
              imageUrl: (items[i].miniImageUrl ?? '').trim().isNotEmpty
                  ? ((items[i].miniImageUrl ?? '').startsWith('http')
                      ? (items[i].miniImageUrl ?? '')
                      : '${AppConfig.baseUrl}${items[i].miniImageUrl}')
                  : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StoryScreen(
                      items: [
                        for (final s in items)
                          StoryListItem(id: s.id, title: s.title, miniImageUrl: s.miniImageUrl),
                      ],
                      initialIndex: i,
                    ),
                  ),
                );
              },
            ),
            if (i != items.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _StoryTile extends StatefulWidget {
  const _StoryTile({
    required this.label,
    required this.borderColor,
    this.dimmed = false,
    this.imageUrl,
    this.onTap,
  });

  final String label;
  final Color borderColor;
  final bool dimmed;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  State<_StoryTile> createState() => _StoryTileState();
}

class _StoryTileState extends State<_StoryTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 2, color: widget.borderColor),
        color: const Color(0xFFE2E8F0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (widget.imageUrl != null)
            Positioned.fill(
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE2E8F0)),
              ),
            )
          else
            Positioned.fill(
              child: Container(color: const Color(0xFFE2E8F0)),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.70),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardsCarousel extends StatefulWidget {
  const _CardsCarousel();

  @override
  State<_CardsCarousel> createState() => _CardsCarouselState();
}

class _CardsCarouselState extends State<_CardsCarousel> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final accounts = state.accounts;

    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 156,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < accounts.length; i++) ...[
            _AccountCardBlock(
              account: accounts[i],
            ),
            if (i != accounts.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

class _AccountCardBlock extends StatelessWidget {
  const _AccountCardBlock({
    required this.account,
  });

  final HomeAccountItem account;

  @override
  Widget build(BuildContext context) {
    final mainCard = account.mainCard;
    
    // Если есть основная карта - показываем её
    if (mainCard != null) {
      return SizedBox(
        width: 228,
        height: 140,
        child: _BankCard(
          title: mainCard.accountTitle,
          amount: '${mainCard.balance} ${mainCard.currency}',
          pan: () {
            final digits = mainCard.maskedCardNumber.replaceAll(RegExp(r'[^0-9]'), '');
            final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
            return last4.isEmpty ? '****' : '**** $last4';
          }(),
          variant: (mainCard.productType == 'credit' || mainCard.productType == 'credit_card')
              ? OtpBankCardVariant.purple
              : ((mainCard.productType == 'travel') ? OtpBankCardVariant.orange : OtpBankCardVariant.dark),
          customGradient: () {
            final c1 = _parseHexColor(mainCard.bgColor1);
            final c2 = _parseHexColor(mainCard.bgColor2);
            if (c1 == null || c2 == null) return null;
            return LinearGradient(
              begin: const Alignment(0.22, -0.22),
              end: const Alignment(0.78, 1.22),
              colors: [c1, c2],
            );
          }(),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AccountDetailsScreen(
                  args: AccountDetailsArgs(
                    accountId: mainCard.accountId,
                    cardId: mainCard.id,
                    accountTitle: mainCard.accountTitle,
                    balance: '${mainCard.balance} ${mainCard.currency}',
                    pan: () {
                      final digits = mainCard.maskedCardNumber.replaceAll(RegExp(r'[^0-9]'), '');
                      final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
                      return last4.isEmpty ? '****' : '**** $last4';
                    }(),
                    variant: (mainCard.productType == 'credit' || mainCard.productType == 'credit_card')
                        ? OtpBankCardVariant.purple
                        : (mainCard.productType == 'travel'
                            ? OtpBankCardVariant.orange
                            : OtpBankCardVariant.dark),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Если нет карты - показываем placeholder карту для счёта
    return SizedBox(
      width: 228,
      height: 140,
      child: _BankCard(
        title: account.title,
        amount: '${account.balance} ${account.currency}',
        pan: '****',
        variant: OtpBankCardVariant.dark,
        onTap: () {
          // TODO: Navigate to account details without card
        },
      ),
    );
  }
}

class _BankCard extends StatefulWidget {
  const _BankCard({
    required this.title,
    required this.amount,
    required this.pan,
    required this.variant,
    this.customGradient,
    required this.onTap,
  });

  final String title;
  final String amount;
  final String pan;
  final OtpBankCardVariant variant;
  final Gradient? customGradient;
  final VoidCallback onTap;

  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard> {
  @override
  Widget build(BuildContext context) {
    return OtpBankCard(
      title: widget.title,
      amount: widget.amount,
      pan: widget.pan,
      variant: widget.variant,
      customGradient: widget.customGradient,
      onTap: widget.onTap,
    );
  }
}

class _QuickActionsRow extends StatefulWidget {
  const _QuickActionsRow();

  @override
  State<_QuickActionsRow> createState() => _QuickActionsRowState();
}

class _QuickActionsRowState extends State<_QuickActionsRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OtpRoundActionButton(
            label: 'Оплатить',
            icon: Icons.payments_rounded,
            style: OtpRoundActionStyle.primary,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OtpRoundActionButton(
            label: 'QR',
            icon: Icons.qr_code_rounded,
            style: OtpRoundActionStyle.secondary,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OtpRoundActionButton(
            label: 'СБП',
            icon: Icons.swap_horiz_rounded,
            iconWidget: Image.asset(
              'assets/img/logosbp.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            style: OtpRoundActionStyle.secondary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SbpTransferScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OtpRoundActionButton(
            label: 'Пригласить',
            icon: Icons.person_add_alt_1_rounded,
            style: OtpRoundActionStyle.purple,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _BonusesBanner extends StatefulWidget {
  const _BonusesBanner();

  @override
  State<_BonusesBanner> createState() => _BonusesBannerState();
}

class _BonusesBannerState extends State<_BonusesBanner> {
  String _resolveLogo(String logo) {
    if (logo.isEmpty) return logo;
    if (logo.startsWith('http://') || logo.startsWith('https://')) return logo;
    if (logo.startsWith('/')) return '${AppConfig.baseUrl}$logo';
    return '${AppConfig.baseUrl}/$logo';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BonusesScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(width: 1, color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x33C4FF2E),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Icon(Icons.local_offer_rounded, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Мои бонусы и акции',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Кэшбэк более 7%',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _SmallPartnerLogo(url: _resolveLogo('/logos/cashback/magnit.png')),
                        const SizedBox(width: 6),
                        _SmallPartnerLogo(url: _resolveLogo('/logos/cashback/five.png')),
                        const SizedBox(width: 6),
                        _SmallPartnerLogo(url: _resolveLogo('/logos/cashback/lenta.png')),
                        const SizedBox(width: 6),
                        _SmallPartnerLogo(url: _resolveLogo('/logos/cashback/samokat.png')),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetsGrid extends StatefulWidget {
  const _WidgetsGrid();

  @override
  State<_WidgetsGrid> createState() => _WidgetsGridState();
}

class _WidgetsGridState extends State<_WidgetsGrid> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: _WidgetTile(
                title: 'Кэшбэк',
                subtitle: 'Баланс',
                iconBg: Color(0xFFDBEAFE),
                icon: Icons.savings_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _WidgetTile(
                title: 'Бонусы',
                subtitle: 'Баллы',
                iconBg: Color(0x33C4FF2E),
                icon: Icons.stars_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: _WidgetTile(
                title: 'Инвестиции',
                subtitle: 'Акции и облигации',
                iconBg: Color(0x1A9E6FC3),
                icon: Icons.trending_up_rounded,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _WidgetTile(
                title: 'Семейный счёт',
                subtitle: 'Общие финансы',
                iconBg: Color(0xFFC8E1FC),
                icon: Icons.groups_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallPartnerLogo extends StatelessWidget {
  final String url;

  const _SmallPartnerLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.local_offer_rounded,
            size: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _WidgetTile extends StatefulWidget {
  const _WidgetTile({
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color iconBg;
  final IconData icon;

  @override
  State<_WidgetTile> createState() => _WidgetTileState();
}

class _WidgetTileState extends State<_WidgetTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1, color: const Color(0x7FF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.iconBg,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Icon(widget.icon, size: 18, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAutoRow extends StatelessWidget {
  const _HomeAutoRow();

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeBloc>().state;
    final properties = homeState.properties;
    final vehicles = homeState.vehicles;

    return Row(
      children: [
        Expanded(
          child: _HomeAutoButton(
            title: 'Мой дом',
            subtitle: properties.isNotEmpty ? 'Управлять' : 'Добавить',
            description: properties.isNotEmpty
                ? (properties.first.name)
                : 'Добавьте дом',
            icon: Icons.home_outlined,
            color: const Color(0xFF0F172A),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PropertiesScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HomeAutoButton(
            title: 'Моё авто',
            subtitle: vehicles.isNotEmpty ? 'Управлять' : 'Добавить',
            description: vehicles.isNotEmpty
                ? ('${vehicles.first.brand} ${vehicles.first.model}')
                : 'Добавьте авто',
            icon: Icons.directions_car_outlined,
            color: const Color(0xFFFF7D32),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VehiclesScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeAutoButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeAutoButton({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenProductButton extends StatefulWidget {
  const _OpenProductButton();

  @override
  State<_OpenProductButton> createState() => _OpenProductButtonState();
}

class _OpenProductButtonState extends State<_OpenProductButton> {
  @override
  Widget build(BuildContext context) {
    return OtpPrimaryButton(
      label: 'Открыть новый продукт',
      icon: Icons.add_rounded,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      onPressed: () {
        RootShell.maybeOf(context)?.setIndex(4);
      },
    );
  }
}
