import 'package:flutter/material.dart';

import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_round_action_button.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import 'card_details_screen.dart';

class AccountDetailsArgs {
  const AccountDetailsArgs({
    required this.accountTitle,
    required this.balance,
    required this.pan,
    required this.variant,
  });

  final String accountTitle;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
}

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({super.key, required this.args});

  final AccountDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final cards = <_AccountCardItemData>[
      _AccountCardItemData(
        title: args.accountTitle,
        balance: args.balance,
        pan: args.pan,
        variant: args.variant,
        isDefault: true,
      ),
      _AccountCardItemData(
        title: 'Виртуальная карта',
        balance: args.balance,
        pan: '**** 1102',
        variant: OtpBankCardVariant.dark,
        isDefault: false,
      ),
      _AccountCardItemData(
        title: 'Доп. карта',
        balance: args.balance,
        pan: '**** 5419',
        variant: OtpBankCardVariant.purple,
        isDefault: false,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          OtpUniversalAppBar(title: 'Счёт'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args.accountTitle,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Доступный остаток',
                  style: TextStyle(
                    color: const Color(0xFF64748B).withOpacity(0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  args.balance,
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
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 184,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final card = cards[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OtpBankCard(
                      title: card.title,
                      amount: card.balance,
                      pan: card.pan,
                      variant: card.variant,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CardDetailsScreen(
                              args: CardDetailsArgs(
                                cardTitle: card.title,
                                accountTitle: args.accountTitle,
                                balance: card.balance,
                                pan: card.pan,
                                variant: card.variant,
                                validThru: '12/28',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    if (card.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Основная',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: cards.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Перевести',
                    icon: Icons.swap_horiz_rounded,
                    style: OtpRoundActionStyle.primary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Пополнить',
                    icon: Icons.add_rounded,
                    style: OtpRoundActionStyle.secondary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Реквизиты',
                    icon: Icons.receipt_long_rounded,
                    style: OtpRoundActionStyle.secondary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Лимиты',
                    icon: Icons.tune_rounded,
                    style: OtpRoundActionStyle.secondary,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SpendingAnalyticsSection(),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionHeader(
              title: 'История операций',
              actionLabel: 'Все',
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: _TransactionsPreview(),
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

class _AccountCardItemData {
  const _AccountCardItemData({
    required this.title,
    required this.balance,
    required this.pan,
    required this.variant,
    required this.isDefault,
  });

  final String title;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
  final bool isDefault;
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
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
        children: const [
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
