import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/otp_colors.dart';
import '../../../core/widgets/otp_avatar_button.dart';
import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_offers_carousel.dart';
import '../../../core/widgets/otp_primary_button.dart';
import '../../../core/widgets/otp_round_action_button.dart';
import '../../../core/widgets/otp_story_tile.dart';
import '../../accounts/presentation/account_details_screen.dart';
import '../../products/domain/product_ui_config.dart';
import '../../products/presentation/product_details_screen.dart';
import '../../products/widgets/otp_product_tile.dart';
import '../../shell/presentation/root_shell.dart';
import '../bloc/home_bloc.dart';
import '../../profile/presentation/profile_screen.dart';

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
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
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
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        OtpProductTile(
          product: ProductUiConfig.travel.copyWith(title: 'Карта для поездок'),
          size: OtpProductTileSize.mediumWide,
          subtitle: 'Кэшбэк на билеты',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailsScreen(
                  data: ProductDetailsMock.byTitle('Путешествия'),
                ),
              ),
            );
          },
        ),
        OtpProductTile(
          product: ProductUiConfig.mortgage,
          size: OtpProductTileSize.mediumWide,
          subtitle: 'Ставка от 6%',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailsScreen(
                  data: ProductDetailsMock.byTitle('Ипотека'),
                ),
              ),
            );
          },
        ),
        OtpProductTile(
          product: ProductUiConfig.autoLoan,
          size: OtpProductTileSize.mediumWide,
          subtitle: 'Одобрение онлайн',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailsScreen(
                  data: ProductDetailsMock.byTitle('Автокредит'),
                ),
              ),
            );
          },
        ),
        OtpProductTile(
          product: ProductUiConfig.savings,
          size: OtpProductTileSize.mediumWide,
          subtitle: 'Проценты каждый день',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailsScreen(
                  data: ProductDetailsMock.byTitle('Накопления'),
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
    void openProduct(String title) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailsScreen(
            data: ProductDetailsMock.byTitle(title),
          ),
        ),
      );
    }

    return OtpOffersCarousel(
      items: [
        OtpOfferItem(
          kicker: 'ВАШИ ПУТЕШЕСТВИЯ',
          kickerColor: Color(0xFF2563EB),
          title: 'Путешествия',
          description: 'Роуминг, страховка\nи полезные сервисы.',
          cardBg: Color(0xFFC8E1FC),
          cardBorder: Color(0xFFFFFFFF),
          ctaLabel: 'Подробнее',
          ctaBg: Color(0xFFFF7D32),
          watermarkIcon: Icons.flight_takeoff_rounded,
          onTap: () {
            openProduct('Путешествия');
          },
        ),
        OtpOfferItem(
          kicker: 'НЕДВИЖИМОСТЬ',
          kickerColor: Color(0xFF475569),
          title: 'Ипотека 6%',
          description: 'Акция для семей\nс детьми.',
          cardBg: Color(0xFFF1F5F9),
          cardBorder: Color(0xFFE2E8F0),
          ctaLabel: 'Рассчитать',
          ctaBg: Color(0xFF0F172A),
          watermarkIcon: Icons.home_work_rounded,
          onTap: () {
            openProduct('Ипотека');
          },
        ),
        OtpOfferItem(
          kicker: 'АВТО',
          kickerColor: Color(0xFF0F172A),
          title: 'Автокредит',
          description: 'Подбор условий\nи одобрение онлайн.',
          cardBg: Color(0xFFFFEDD5),
          cardBorder: Color(0xFFFFFFFF),
          ctaLabel: 'Подобрать',
          ctaBg: Color(0xFF0F172A),
          watermarkIcon: Icons.directions_car_rounded,
          onTap: () {
            openProduct('Автокредит');
          },
        ),
        OtpOfferItem(
          kicker: 'КРЕДИТ',
          kickerColor: Color(0xFF4F46E5),
          title: 'Кредит наличными',
          description: 'Быстро, прозрачно\nи без лишних шагов.',
          cardBg: Color(0xFFE9D5FF),
          cardBorder: Color(0xFFFFFFFF),
          ctaLabel: 'Оформить',
          ctaBg: Color(0xFF4F46E5),
          watermarkIcon: Icons.account_balance_wallet_rounded,
          onTap: () {
            openProduct('Кредит наличными');
          },
        ),
        OtpOfferItem(
          kicker: 'ЗАЙМЫ',
          kickerColor: Color(0xFF475569),
          title: 'Микрозайм',
          description: 'До зарплаты\nза пару минут.',
          cardBg: Color(0xFFFFF7ED),
          cardBorder: Color(0xFFE2E8F0),
          ctaLabel: 'Получить',
          ctaBg: Color(0xFFFF7D32),
          watermarkIcon: Icons.request_quote_rounded,
          onTap: () {
            openProduct('Микрозайм');
          },
        ),
        OtpOfferItem(
          kicker: 'СБЕРЕЖЕНИЯ',
          kickerColor: Color(0xFF16A34A),
          title: 'Накопительный счёт',
          description: 'Проценты\nкаждый день.',
          cardBg: Color(0xFFDCFCE7),
          cardBorder: Color(0xFFFFFFFF),
          ctaLabel: 'Открыть',
          ctaBg: Color(0xFF0F172A),
          watermarkIcon: Icons.savings_rounded,
          onTap: () {
            openProduct('Накопления');
          },
        ),
        OtpOfferItem(
          kicker: 'ИНВЕСТИЦИИ',
          kickerColor: Color(0xFF0F172A),
          title: 'Инвесткопилка',
          description: 'Автопополнение\nи простой старт.',
          cardBg: Color(0xFFE2E8F0),
          cardBorder: Color(0xFFFFFFFF),
          ctaLabel: 'Подключить',
          ctaBg: Color(0xFF9E6FC3),
          watermarkIcon: Icons.trending_up_rounded,
          onTap: () {
            openProduct('Инвесткопилка');
          },
        ),
        OtpOfferItem(
          kicker: 'СЕМЬЯ',
          kickerColor: Color(0xFF0F172A),
          title: 'Семейный счёт',
          description: 'Общий бюджет\nи лимиты.',
          cardBg: Color(0xFFDBEAFE),
          cardBorder: Color(0xFFFFFFFF),
          ctaLabel: 'Создать',
          ctaBg: Color(0xFF2563EB),
          watermarkIcon: Icons.group_rounded,
          onTap: () {
            openProduct('Семейный счёт');
          },
        ),
        OtpOfferItem(
          kicker: 'ПОДПИСКИ',
          kickerColor: Color(0xFF475569),
          title: 'Премиум',
          description: 'Платежи без комиссий,\nповышенный кэшбэк и поддержка.',
          cardBg: Color(0xFFF1F5F9),
          cardBorder: Color(0xFFE2E8F0),
          ctaLabel: 'Подключить',
          ctaBg: Color(0xFF0F172A),
          watermarkIcon: Icons.workspace_premium_rounded,
          onTap: () {
            openProduct('Премиум');
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
    // Figma block: horizontal stories (84x84) with label overlay.
    return SizedBox(
      height: 100,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        children: const [
          _StoryTile(label: 'Для вас', borderColor: Color(0xFFC4FF2E)),
          SizedBox(width: 12),
          _StoryTile(label: 'Кэшбэк 10%', borderColor: Color(0xFFC4FF2E)),
          SizedBox(width: 12),
          _StoryTile(label: 'Ипотека', borderColor: Color(0xFFE2E8F0), dimmed: true),
          SizedBox(width: 12),
          _StoryTile(label: 'Новое\nв приложении', borderColor: Color(0xFFC4FF2E)),
          SizedBox(width: 12),
          _StoryTile(label: 'Валюты', borderColor: Color(0xFFC4FF2E)),
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
  });

  final String label;
  final Color borderColor;
  final bool dimmed;

  @override
  State<_StoryTile> createState() => _StoryTileState();
}

class _StoryTileState extends State<_StoryTile> {
  @override
  Widget build(BuildContext context) {
    return OtpStoryTile(
      label: widget.label,
      borderColor: widget.borderColor,
      dimmed: widget.dimmed,
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
    return SizedBox(
      height: 156,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        children: [
          _BankCard(
            title: 'Основная карта',
            amount: '4 250,00 ₽',
            pan: '**** 8824',
            variant: OtpBankCardVariant.dark,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AccountDetailsScreen(
                    args: AccountDetailsArgs(
                      accountTitle: 'Основной счёт',
                      balance: '4 250,00 ₽',
                      pan: '**** 8824',
                      variant: OtpBankCardVariant.dark,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _BankCard(
            title: 'Кредитная карта',
            amount: '15 000,00 ₽',
            pan: '**** 8824',
            variant: OtpBankCardVariant.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AccountDetailsScreen(
                    args: AccountDetailsArgs(
                      accountTitle: 'Кредитный счёт',
                      balance: '15 000,00 ₽',
                      pan: '**** 8824',
                      variant: OtpBankCardVariant.purple,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _BankCard(
            title: 'Премиум карта',
            amount: '120 000,00 ₽',
            pan: '**** 4132',
            variant: OtpBankCardVariant.orange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AccountDetailsScreen(
                    args: AccountDetailsArgs(
                      accountTitle: 'Премиум счёт',
                      balance: '120 000,00 ₽',
                      pan: '**** 4132',
                      variant: OtpBankCardVariant.orange,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
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
    required this.onTap,
  });

  final String title;
  final String amount;
  final String pan;
  final OtpBankCardVariant variant;
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
            style: OtpRoundActionStyle.secondary,
            onTap: () {},
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мои бонусы и акции',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Кэшбэк более 7%',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded),
          )
        ],
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
      onPressed: () {},
    );
  }
}
