import 'package:flutter/material.dart';

import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_large_bank_card.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class CardDetailsArgs {
  const CardDetailsArgs({
    required this.cardTitle,
    required this.accountTitle,
    required this.balance,
    required this.pan,
    required this.variant,
    this.validThru,
  });

  final String cardTitle;
  final String accountTitle;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
  final String? validThru;
}

class CardDetailsScreen extends StatelessWidget {
  const CardDetailsScreen({super.key, required this.args});

  final CardDetailsArgs args;

  Gradient _cardGradient() {
    return switch (args.variant) {
      OtpBankCardVariant.dark => const LinearGradient(
          begin: Alignment(0.22, -0.22),
          end: Alignment(0.78, 1.22),
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      OtpBankCardVariant.purple => const LinearGradient(
          begin: Alignment(0.22, -0.22),
          end: Alignment(0.78, 1.22),
          colors: [Color(0xFF9E6FC3), Color(0xFF4F46E5)],
        ),
      OtpBankCardVariant.orange => const LinearGradient(
          begin: Alignment(0.22, -0.22),
          end: Alignment(0.78, 1.22),
          colors: [Color(0xFFFF7D32), Color(0xFF9E6FC3)],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          OtpUniversalAppBar(title: args.cardTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OtpLargeBankCard(
                  title: args.cardTitle,
                  subtitle: 'Можно оплатить приложив',
                  variant: args.variant,
                  pan: args.pan,
                  validThru: args.validThru ?? '—',
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    const Text(
                      'Доступный остаток',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      args.balance,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _CardActionsRow(),
                const SizedBox(height: 28),
                const _SpendingAnalyticsSection(),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'История операций',
                  actionLabel: 'Все',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                const _TransactionsPreview(),
                const SizedBox(height: 28),
                const Text(
                  'Настройки карты',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsGroup(
                  items: [
                    _SettingsItemData(
                      icon: Icons.pin_rounded,
                      iconBg: Color(0x33C8E1FC),
                      title: 'Изменить ПИН-код',
                    ),
                    _SettingsItemData(
                      icon: Icons.notifications_active_rounded,
                      iconBg: Color(0x339E6FC3),
                      title: 'Уведомления об операциях',
                    ),
                    _SettingsItemData(
                      icon: Icons.block_rounded,
                      iconBg: Color(0x33FF7D32),
                      title: 'Блокировка карты',
                    ),
                    _SettingsItemData(
                      icon: Icons.tune_rounded,
                      iconBg: Color(0x33C1FF05),
                      title: 'Настроить лимиты трат',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingAnalyticsSection extends StatelessWidget {
  const _SpendingAnalyticsSection();

  @override
  Widget build(BuildContext context) {
    const values = <double>[0.40, 0.60, 0.90, 0.50, 0.75, 0.45];
    const labels = <String>['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Аналитика трат',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
            Text(
              'СЕНТЯБРЬ',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: ShapeDecoration(
            color: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 128,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (int i = 0; i < values.length; i++) ...[
                          Expanded(
                            child: _AnalyticsBar(
                              fraction: values[i],
                              highlighted: i == 2,
                              tooltipLabel: i == 2 ? '124к' : null,
                            ),
                          ),
                          if (i != values.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final l in labels)
                    Text(
                      l,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.50,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsBar extends StatelessWidget {
  const _AnalyticsBar({
    required this.fraction,
    required this.highlighted,
    this.tooltipLabel,
  });

  final double fraction;
  final bool highlighted;
  final String? tooltipLabel;

  @override
  Widget build(BuildContext context) {
    final barColor = highlighted ? const Color(0xFFC1FF05) : const Color(0x4CC8E1FC);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight * fraction;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: h,
                decoration: ShapeDecoration(
                  color: barColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
              if (tooltipLabel != null)
                Positioned(
                  top: -32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      tooltipLabel!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
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

class _CardActionsRow extends StatelessWidget {
  const _CardActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SquareActionButton(
            label: 'Заморозить',
            icon: Icons.ac_unit_rounded,
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _SquareActionButton(
            label: 'Реквизиты',
            icon: Icons.receipt_long_rounded,
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _SquareActionButton(
            label: 'Лимиты',
            icon: Icons.tune_rounded,
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _SquareActionButton(
            label: 'Перевести',
            icon: Icons.swap_horiz_rounded,
            primary: true,
          ),
        ),
      ],
    );
  }
}

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({
    required this.label,
    required this.icon,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? const Color(0x19C1FF05) : const Color(0xFFF1F5F9);
    final border = primary ? const Color(0x33C1FF05) : const Color(0xFFF1F5F9);
    final labelColor = primary ? const Color(0xFF0F172A) : const Color(0xFF475569);
    final fw = primary ? FontWeight.w800 : FontWeight.w600;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              color: bg,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: border),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF0F172A), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: fw,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
        Material(
          color: const Color(0x19C1FF05),
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Все',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionsPreview extends StatelessWidget {
  const _TransactionsPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Column(
        children: [
          _TransactionRow(
            title: 'Кофейня',
            subtitle: 'Сегодня • 12:40',
            amount: '- 320 ₽',
          ),
          _Divider(),
          _TransactionRow(
            title: 'Зарплата',
            subtitle: 'Вчера • 10:20',
            amount: '+ 120 000 ₽',
            positive: true,
          ),
          _Divider(),
          _TransactionRow(
            title: 'Такси',
            subtitle: 'Пн • 21:15',
            amount: '- 540 ₽',
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.positive = false,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final amountColor = positive ? const Color(0xFF16A34A) : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 20, color: Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.icon,
    required this.iconBg,
    required this.title,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SettingsRow(item: items[i], showDivider: i != items.length - 1),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.showDivider});

  final _SettingsItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: item.iconBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  child: Icon(item.icon, size: 20, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
