import 'package:flutter/material.dart';

import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../goals/presentation/piggy_bank_screen.dart';
import '../domain/product_ui_config.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.data});

  final ProductDetailsData data;

  @override
  Widget build(BuildContext context) {
    final headerLuminance = data.gradientColors.isEmpty
        ? 1.0
        : data.gradientColors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) /
            data.gradientColors.length;
    final isDarkHeader = headerLuminance < 0.42;
    final headerTitleColor = isDarkHeader ? Colors.white : const Color(0xFF0F172A);
    final headerSubColor = isDarkHeader ? Colors.white.withOpacity(0.86) : const Color(0xCC1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _HeaderBackground(gradientColors: data.gradientColors),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              OtpUniversalAppBar(
                title: data.title,
                backHasBackground: true,
                backgroundColor: Colors.transparent,
                textColor: headerTitleColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.headerIcon != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(24, 18),
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.12,
                              child: Icon(
                                data.headerIcon,
                                size: 128,
                                color: isDarkHeader ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      data.heroTitle,
                      style: TextStyle(
                        color: headerTitleColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.heroSubtitle,
                      style: TextStyle(
                        color: headerSubColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (data.headerCard != null) _HeaderActionCard(data: data.headerCard!),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Material(
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: const Color(0x1A000000),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 128),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final section in data.sections) ...[
                            _SectionTitle(title: section.title),
                            const SizedBox(height: 16),
                            for (final item in section.items) ...[
                              _InfoCtaCard(item: item),
                              const SizedBox(height: 16),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
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

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.gradientColors});

  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.36, -0.11),
          end: const Alignment(0.64, 1.11),
          colors: gradientColors,
        ),
      ),
      child: Opacity(
        opacity: 0.20,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.0, 0.0),
              radius: 1.51,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0),
                Colors.white.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.4,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _HeaderActionCard extends StatelessWidget {
  const _HeaderActionCard({required this.data});

  final ProductHeaderCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.50)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(6),
            decoration: ShapeDecoration(
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Icon(data.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.kicker,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
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

class _InfoCtaCard extends StatelessWidget {
  const _InfoCtaCard({required this.item});

  final ProductActionCardData item;

  @override
  Widget build(BuildContext context) {
    final ctaOnTap = item.onTap ??
        (item.ctaLabel == 'Открыть копилку'
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PiggyBankScreen(),
                  ),
                );
              }
            : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: ShapeDecoration(
                  color: item.iconBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(item.icon, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PillButton(label: item.ctaLabel, onTap: ctaOnTap),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9999),
        child: InkWell(
          borderRadius: BorderRadius.circular(9999),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsData {
  const ProductDetailsData({
    required this.title,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.gradientColors,
    required this.sections,
    this.headerCard,
    this.headerIcon,
  });

  final String title;
  final String heroTitle;
  final String heroSubtitle;
  final List<Color> gradientColors;
  final ProductHeaderCardData? headerCard;
  final IconData? headerIcon;
  final List<ProductDetailsSectionData> sections;
}

class ProductHeaderCardData {
  const ProductHeaderCardData({
    required this.kicker,
    required this.title,
    required this.icon,
  });

  final String kicker;
  final String title;
  final IconData icon;
}

class ProductDetailsSectionData {
  const ProductDetailsSectionData({required this.title, required this.items});

  final String title;
  final List<ProductActionCardData> items;
}

class ProductActionCardData {
  const ProductActionCardData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onTap;
}

class ProductDetailsMock {
  static ProductDetailsData byTitle(String title) {
    final cfg = ProductUiConfig.byTitle(title);
    if (title.toLowerCase() == 'путешествия') {
      return const ProductDetailsData(
        title: 'Путешествия',
        heroTitle: 'Ваш мир,\nоткрыт.',
        heroSubtitle: 'Умные инструменты для роуминга',
        gradientColors: [
          Color(0xFFC4FF2E),
          Color(0xFFA8E600),
          Color(0xFFC8E1FC),
        ],
        headerIcon: Icons.flight_takeoff_rounded,
        headerCard: ProductHeaderCardData(
          kicker: 'СПЛАНИРУЙТЕ ПОЕЗДКУ',
          title: 'Куда вы отправляетесь?',
          icon: Icons.near_me_rounded,
        ),
        sections: [
          ProductDetailsSectionData(
            title: 'ПЕРЕД ПОЕЗДКОЙ',
            items: [
              ProductActionCardData(
                icon: Icons.savings_rounded,
                iconBg: Color(0x26FF7D32),
                title: 'Копилка на отпуск',
                subtitle: 'Автоматические накопления на\nнаправление вашей мечты.',
                ctaLabel: 'Начать копить',
              ),
              ProductActionCardData(
                icon: Icons.currency_exchange_rounded,
                iconBg: Color(0x33C4FF2E),
                title: 'Обмен валюты',
                subtitle: 'Мгновенная конвертация для\nболее чем 80 валют.',
                ctaLabel: 'Обменять',
              ),
              ProductActionCardData(
                icon: Icons.health_and_safety_rounded,
                iconBg: Color(0x269E6FC3),
                title: 'Страхование',
                subtitle: 'Умное покрытие здоровья и\nбагажа.',
                ctaLabel: 'Оформить страховку',
              ),
              ProductActionCardData(
                icon: Icons.receipt_long_rounded,
                iconBg: Color(0xFFF1F5F9),
                title: 'Траты в поездке',
                subtitle: 'Контроль бюджета с\nуведомлениями в реальном\nвремени.',
                ctaLabel: 'Открыть трекер',
              ),
            ],
          ),
        ],
      );
    }

    if (title.toLowerCase() == 'инвесткопилка') {
      return ProductDetailsData(
        title: 'Инвесткопилка',
        heroTitle: 'Инвесткопилка',
        heroSubtitle: 'Округляйте покупки и копите незаметно.',
        gradientColors: cfg.gradientColors,
        headerCard: const ProductHeaderCardData(
          kicker: 'СБЕРЕЖЕНИЯ + ИНВЕСТИЦИИ',
          title: 'Автопополнение и прогнозы рынка',
          icon: Icons.auto_graph_rounded,
        ),
        headerIcon: cfg.icon,
        sections: [
          ProductDetailsSectionData(
            title: 'ВОЗМОЖНОСТИ',
            items: [
              ProductActionCardData(
                icon: Icons.savings_rounded,
                iconBg: const Color(0x19C1FF05),
                title: 'Копилка',
                subtitle: 'Создавайте цели, выбирайте иконку\nи пополняйте в 1 тап.',
                ctaLabel: 'Открыть копилку',
                onTap: null,
              ),
            ],
          ),
        ],
      );
    }

    return ProductDetailsData(
      title: cfg.title,
      heroTitle: cfg.title,
      heroSubtitle: 'Описание продукта',
      gradientColors: cfg.gradientColors,
      headerCard: null,
      headerIcon: cfg.icon,
      sections: const [
        ProductDetailsSectionData(
          title: 'ВОЗМОЖНОСТИ',
          items: [
            ProductActionCardData(
              icon: Icons.widgets_rounded,
              iconBg: Color(0xFFF1F5F9),
              title: 'Функция',
              subtitle: 'Описание функции продукта',
              ctaLabel: 'Открыть',
            ),
          ],
        ),
      ],
    );
  }
}
