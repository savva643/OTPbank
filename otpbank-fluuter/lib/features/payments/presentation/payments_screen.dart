import 'package:flutter/material.dart';

import 'payment_by_details_screen.dart';
import 'payment_by_contract_screen.dart';
import 'payment_by_card_screen.dart';
import 'category_services_screen.dart';
import 'payments_search_screen.dart';
import 'qr_payment_screen.dart';
import '../../../core/widgets/otp_search_input.dart';
import '../../../core/widgets/otp_square_action_button.dart';
import '../../../core/widgets/otp_icon.dart';
import 'sbp_transfer_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _searchController = TextEditingController();
  final _sbpController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _sbpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Платежи',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                  letterSpacing: -0.75,
                ),
              ),
              const SizedBox(height: 12),
              Hero(
                tag: PaymentsSearchScreen.heroSearchTag,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(29),
                    onTap: () async {
                      final res = await Navigator.of(context).push<String>(
                        MaterialPageRoute<String>(
                          builder: (_) => PaymentsSearchScreen(initialQuery: _searchController.text),
                        ),
                      );
                      if (!mounted) return;
                      if (res == null) return;
                      _searchController.text = res;
                      setState(() {});
                    },
                    child: IgnorePointer(
                      child: OtpSearchInput(
                        controller: _searchController,
                        hintText: 'Поиск организации или услуги',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SbpTransferCard(
                controller: _sbpController,
                onOpen: () {
                  Future<void>(() async {
                    final res = await Navigator.of(context).push<String>(
                      MaterialPageRoute<String>(
                        builder: (_) => SbpTransferScreen(initialQuery: _sbpController.text),
                      ),
                    );
                    if (!mounted) return;
                    if (res == null || res.trim().isEmpty) return;
                    _sbpController.text = res.trim();
                    setState(() {});
                  });
                },
              ),
              const SizedBox(height: 16),
              const _QuickTransferMethodsRow(),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Частые переводы',
                actionText: 'Все',
                onActionTap: () {},
              ),
              const SizedBox(height: 12),
              const _FrequentTransfersPlaceholder(),
              const SizedBox(height: 20),
              const Text(
                'Платежи',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
              const SizedBox(height: 12),
              const _PaymentsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SbpTransferCard extends StatelessWidget {
  const _SbpTransferCard({
    required this.controller,
    required this.onOpen,
  });

  final TextEditingController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x19C4FF2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: const Color(0x33C4FF2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/img/logosbp.png',
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ПЕРЕВОД С ПОМОЩЬЮ СБП',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Hero(
            tag: SbpTransferScreen.heroSearchTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(48),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(width: 2, color: const Color(0x4CC4FF2E)),
                    ),
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_rounded, size: 18, color: Color(0xFF6B7280)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.text.trim().isEmpty ? 'Имя, телефон или банк' : controller.text.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    controller.text.trim().isEmpty ? const Color(0xFF6B7280) : const Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: controller.text.trim().isEmpty ? FontWeight.w400 : FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Без комиссии до 100 000 ₽ в месяц',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTransferMethodsRow extends StatelessWidget {
  const _QuickTransferMethodsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: OtpSquareActionButton(
            label: 'По номеру\nдоговора',
            icon: Icons.description_rounded,
            iconWidget: const OtpIcon(OtpIconAsset.noteWithPen, size: 22, color: Color(0xFF0F172A)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentByContractScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OtpSquareActionButton(
            label: 'По карте',
            icon: Icons.credit_card_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentByCardScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OtpSquareActionButton(
            label: 'По\nреквизитам',
            icon: Icons.account_balance_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentByDetailsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OtpSquareActionButton(
            label: 'Оплата\nпо QR',
            icon: Icons.qr_code_rounded,
            iconWidget: const OtpIcon(OtpIconAsset.scannerQr, size: 22, color: Color(0xFF0F172A)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QrPaymentScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        InkWell(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: Color(0xFFC4FF2E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}

class _FrequentTransfersPlaceholder extends StatelessWidget {
  const _FrequentTransfersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    index == 0 ? 'Алексей' : 'Контакт',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentsGrid extends StatelessWidget {
  const _PaymentsGrid();

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Мобильная\nсвязь', Icons.phone_android_rounded, Color(0x33C8E1FC), Color(0xFFC8E1FC), 'mobile'),
      ('ЖКХ', Icons.apartment_rounded, Color(0x339E6FC3), Color(0xFF9E6FC3), 'utilities'),
      ('Госуслуги', Icons.account_balance_rounded, Color(0x33C4FF2E), Color(0xFFC4FF2E), 'government'),
      ('Интернет\nи ТВ', Icons.wifi_rounded, Color(0x33FF7D32), Color(0xFFFF7D32), 'internet'),
      ('Штрафы\nи налоги', Icons.receipt_long_rounded, Color(0xFFFEE2E2), Color(0xFFEF4444), 'fines'),
      ('Электроэнергия', Icons.electric_bolt_rounded, Color(0x33FDE68A), Color(0xFFF59E0B), 'electricity'),
      ('Газ', Icons.local_fire_department_rounded, Color(0x33FEE2E2), Color(0xFFEF4444), 'gas'),
      ('Водоснабжение', Icons.water_drop_rounded, Color(0x33DBEAFE), Color(0xFF3B82F6), 'water'),
      ('Транспорт', Icons.directions_bus_rounded, Color(0x33E1E1E1), Color(0xFF6B7280), 'transport'),
      ('Образование', Icons.school_rounded, Color(0x33F3E8FF), Color(0xFF8B5CF6), 'education'),
      ('Медицина', Icons.local_hospital_rounded, Color(0x33FEE2E2), Color(0xFFEC4899), 'medicine'),
      ('Страхование', Icons.shield_rounded, Color(0x33D1FAE5), Color(0xFF10B981), 'insurance'),
      ('Кредиты', Icons.account_balance_wallet_rounded, Color(0x33C8E1FC), Color(0xFF0369A1), 'loans'),
      ('Инвестиции', Icons.trending_up_rounded, Color(0x33FEF3C7), Color(0xFFF59E0B), 'investments'),
      ('Благотворительность', Icons.favorite_rounded, Color(0x33FEE2E2), Color(0xFFEF4444), 'charity'),
      ('Игры', Icons.sports_esports_rounded, Color(0x33E0E7FF), Color(0xFF6366F1), 'games'),
      ('Путешествия', Icons.flight_rounded, Color(0x33CFFAFE), Color(0xFF06B6D4), 'travel'),
      ('Фитнес', Icons.fitness_center_rounded, Color(0x33DBEAFE), Color(0xFF2563EB), 'fitness'),
      ('Кино', Icons.movie_rounded, Color(0x33F3E8FF), Color(0xFF9333EA), 'cinema'),
      ('Музыка', Icons.music_note_rounded, Color(0x33FEF3C7), Color(0xFFEAB308), 'music'),
      ('Книги', Icons.menu_book_rounded, Color(0x33FFEDD5), Color(0xFFF97316), 'books'),
      ('Доставка еды', Icons.delivery_dining_rounded, Color(0x33C4FF2E), Color(0xFF84CC16), 'food'),
      ('Такси', Icons.local_taxi_rounded, Color(0x33FFEDD5), Color(0xFFF97316), 'taxi'),
      ('Парковка', Icons.local_parking_rounded, Color(0x33E2E8F0), Color(0xFF475569), 'parking'),
      ('Подарочные карты', Icons.card_giftcard_rounded, Color(0x33FEE2E2), Color(0xFFE11D48), 'giftcards'),
      ('Подписки', Icons.subscriptions_rounded, Color(0x33E0E7FF), Color(0xFF4F46E5), 'subscriptions'),
      ('Хостинг', Icons.dns_rounded, Color(0x33E2E8F0), Color(0xFF374151), 'hosting'),
      ('Домен', Icons.language_rounded, Color(0x33DBEAFE), Color(0xFF0EA5E9), 'domains'),
      ('VPN', Icons.vpn_lock_rounded, Color(0x33E0E7FF), Color(0xFF6366F1), 'vpn'),
      ('Антивирус', Icons.security_rounded, Color(0x33D1FAE5), Color(0xFF22C55E), 'antivirus'),
      ('Облако', Icons.cloud_rounded, Color(0x33E0E7FF), Color(0xFF3B82F6), 'cloud'),
      ('Связь за рубеж', Icons.public_rounded, Color(0x33CFFAFE), Color(0xFF0891B2), 'international'),
      ('Курьерские услуги', Icons.local_shipping_rounded, Color(0x33FFEDD5), Color(0xFFEA580C), 'courier'),
      ('Ремонт', Icons.handyman_rounded, Color(0x33FEF3C7), Color(0xFFD97706), 'repair'),
      ('Уборка', Icons.cleaning_services_rounded, Color(0x33E0F2FE), Color(0xFF0EA5E9), 'cleaning'),
      ('Аренда авто', Icons.car_rental_rounded, Color(0x33E2E8F0), Color(0xFF4B5563), 'carrental'),
      ('Прокат велосипедов', Icons.pedal_bike_rounded, Color(0x33D1FAE5), Color(0xFF10B981), 'bikerental'),
      ('Эвакуация', Icons.car_crash_rounded, Color(0x33FEE2E2), Color(0xFFDC2626), 'evacuation'),
      ('Шиномонтаж', Icons.circle_rounded, Color(0x33F3F4F6), Color(0xFF6B7280), 'tires'),
      ('Автомойка', Icons.local_car_wash_rounded, Color(0x33DBEAFE), Color(0xFF3B82F6), 'carwash'),
      ('Заправка', Icons.local_gas_station_rounded, Color(0x33FEF3C7), Color(0xFFF59E0B), 'fuel'),
      ('СТО', Icons.garage_rounded, Color(0x33E2E8F0), Color(0xFF475569), 'service'),
      ('Школа', Icons.cast_for_education_rounded, Color(0x33F3E8FF), Color(0xFF8B5CF6), 'school'),
      ('Детский сад', Icons.child_care_rounded, Color(0x33FEE2E2), Color(0xFFF472B6), 'kindergarten'),
      ('Репетиторы', Icons.person_search_rounded, Color(0x33C8E1FC), Color(0xFF0284C7), 'tutors'),
      ('Курсы', Icons.model_training_rounded, Color(0x33FEF3C7), Color(0xFFD97706), 'courses'),
      ('Вебинары', Icons.video_call_rounded, Color(0x33E0E7FF), Color(0xFF4F46E5), 'webinars'),
      ('Консультации', Icons.psychology_rounded, Color(0x33F3E8FF), Color(0xFFA855F7), 'consulting'),
      ('Юрист', Icons.gavel_rounded, Color(0x33E2E8F0), Color(0xFF374151), 'lawyer'),
      ('Бухгалтер', Icons.calculate_rounded, Color(0x33FEF3C7), Color(0xFFEAB308), 'accountant'),
      ('Нотариус', Icons.approval_rounded, Color(0x33D1FAE5), Color(0xFF22C55E), 'notary'),
      ('Оценщик', Icons.assessment_rounded, Color(0x33FFEDD5), Color(0xFFF97316), 'appraiser'),
      ('Риелтор', Icons.real_estate_agent_rounded, Color(0x33C4FF2E), Color(0xFF84CC16), 'realtor'),
      ('Другое', Icons.grid_view_rounded, Color(0x33BAB8BA), Color(0xFFBAB8BA), 'other'),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final spacing = 12.0;
        final itemWidth = (c.maxWidth - spacing) / 2;

        // Разделяем на две колонки для Masonry layout
        final leftColumn = <Widget>[];
        final rightColumn = <Widget>[];

        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final widget = SizedBox(
            width: itemWidth,
            child: _PaymentCategoryTile(
              title: item.$1,
              icon: item.$2,
              bg: item.$3,
              iconBg: item.$4,
              categoryId: item.$5,
            ),
          );

          if (i % 2 == 0) {
            leftColumn.add(widget);
            leftColumn.add(SizedBox(height: spacing));
          } else {
            rightColumn.add(widget);
            rightColumn.add(SizedBox(height: spacing));
          }
        }

        // Удаляем последний SizedBox
        if (leftColumn.isNotEmpty) leftColumn.removeLast();
        if (rightColumn.isNotEmpty) rightColumn.removeLast();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: leftColumn,
            ),
            SizedBox(width: spacing),
            Column(
              children: rightColumn,
            ),
          ],
        );
      },
    );
  }
}

class _PaymentCategoryTile extends StatelessWidget {
  const _PaymentCategoryTile({
    required this.title,
    required this.icon,
    required this.bg,
    required this.iconBg,
    required this.categoryId,
  });

  final String title;
  final IconData icon;
  final Color bg;
  final Color iconBg;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryServicesScreen(
              args: CategoryServicesArgs(
                categoryId: categoryId,
                categoryName: title.replaceAll('\n', ' '),
                backgroundColor: bg,
                iconColor: iconBg,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
