import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/otp_colors.dart';
import '../../../core/widgets/otp_search_input.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedCardFilter = 'Все карты';
  String _selectedDateFilter = 'За месяц';
  String _selectedCategoryFilter = 'Все категории';
  String _selectedTypeFilter = 'Все операции';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCardFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Выберите счёт или карту',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _FilterOption(
                label: 'Все карты',
                isSelected: _selectedCardFilter == 'Все карты',
                onTap: () {
                  setState(() => _selectedCardFilter = 'Все карты');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'Дебетовая карта •••• 1234',
                isSelected: _selectedCardFilter == 'Дебетовая карта',
                onTap: () {
                  setState(() => _selectedCardFilter = 'Дебетовая карта');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'Кредитная карта •••• 5678',
                isSelected: _selectedCardFilter == 'Кредитная карта',
                onTap: () {
                  setState(() => _selectedCardFilter = 'Кредитная карта');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'Накопительный счёт',
                isSelected: _selectedCardFilter == 'Накопительный счёт',
                onTap: () {
                  setState(() => _selectedCardFilter = 'Накопительный счёт');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDateFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Период',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _FilterOption(
                label: 'За неделю',
                isSelected: _selectedDateFilter == 'За неделю',
                onTap: () {
                  setState(() => _selectedDateFilter = 'За неделю');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'За месяц',
                isSelected: _selectedDateFilter == 'За месяц',
                onTap: () {
                  setState(() => _selectedDateFilter = 'За месяц');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'За 3 месяца',
                isSelected: _selectedDateFilter == 'За 3 месяца',
                onTap: () {
                  setState(() => _selectedDateFilter = 'За 3 месяца');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'За год',
                isSelected: _selectedDateFilter == 'За год',
                onTap: () {
                  setState(() => _selectedDateFilter = 'За год');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'Весь период',
                isSelected: _selectedDateFilter == 'Весь период',
                onTap: () {
                  setState(() => _selectedDateFilter = 'Весь период');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilterSheet() {
    final categories = [
      'Все категории',
      'Продукты',
      'Транспорт',
      'Кафе и рестораны',
      'Развлечения',
      'Здоровье',
      'Одежда',
      'Коммунальные услуги',
      'Переводы',
      'Пополнения',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Категория',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _FilterOption(
                      label: category,
                      isSelected: _selectedCategoryFilter == category,
                      onTap: () {
                        setState(() => _selectedCategoryFilter = category);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showTypeFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Тип операции',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _FilterOption(
                label: 'Все операции',
                isSelected: _selectedTypeFilter == 'Все операции',
                onTap: () {
                  setState(() => _selectedTypeFilter = 'Все операции');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'Только расходы',
                isSelected: _selectedTypeFilter == 'Только расходы',
                onTap: () {
                  setState(() => _selectedTypeFilter = 'Только расходы');
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: 'Только доходы',
                isSelected: _selectedTypeFilter == 'Только доходы',
                onTap: () {
                  setState(() => _selectedTypeFilter = 'Только доходы');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'История',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.20,
                      letterSpacing: -0.75,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OtpSearchInput(
                controller: _searchController,
                hintText: 'Поиск по операциям',
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips - full width scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: _selectedCardFilter,
                      isActive: _selectedCardFilter != 'Все карты',
                      onTap: _showCardFilterSheet,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _selectedDateFilter,
                      isActive: true,
                      onTap: _showDateFilterSheet,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _selectedCategoryFilter == 'Все категории'
                          ? 'Категории'
                          : _selectedCategoryFilter,
                      isActive: _selectedCategoryFilter != 'Все категории',
                      onTap: _showCategoryFilterSheet,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _selectedTypeFilter == 'Все операции'
                          ? 'Тип операции'
                          : _selectedTypeFilter,
                      isActive: _selectedTypeFilter != 'Все операции',
                      onTap: _showTypeFilterSheet,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transactions list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _DateSection(
                    dateLabel: 'СЕГОДНЯ',
                    transactions: [
                      _TransactionData(
                        title: 'ВкусВилл',
                        category: 'Продукты',
                        amount: -1240.50,
                        iconBg: Color(0x19FF7D32),
                        icon: Icons.shopping_basket_rounded,
                      ),
                      _TransactionData(
                        title: 'Yandex Go',
                        category: 'Транспорт',
                        amount: -450.00,
                        iconBg: Color(0x199E6FC3),
                        icon: Icons.local_taxi_rounded,
                      ),
                      _TransactionData(
                        title: 'Перевод от Ивана',
                        category: 'Пополнения',
                        amount: 5000.00,
                        iconBg: Color(0x33C4FF2E),
                        icon: Icons.arrow_downward_rounded,
                        isIncome: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _DateSection(
                    dateLabel: 'ВЧЕРА, 12 ОКТЯБРЯ',
                    transactions: [
                      _TransactionData(
                        title: 'Starbucks',
                        category: 'Кафе и рестораны',
                        amount: -320.00,
                        iconBg: Color(0xFF1E293B),
                        icon: Icons.coffee_rounded,
                        iconColor: Colors.white,
                      ),
                      _TransactionData(
                        title: 'Netflix',
                        category: 'Подписки',
                        amount: -999.00,
                        iconBg: Color(0xFFE2E8F0),
                        icon: Icons.movie_rounded,
                      ),
                      _TransactionData(
                        title: 'World Class',
                        category: 'Спорт',
                        amount: -4500.00,
                        iconBg: Color(0x19FF7D32),
                        icon: Icons.fitness_center_rounded,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _DateSection(
                    dateLabel: '11 ОКТЯБРЯ',
                    transactions: [
                      _TransactionData(
                        title: 'Ozon',
                        category: 'Маркетплейсы',
                        amount: -2180.00,
                        iconBg: Color(0xFFE2E8F0),
                        icon: Icons.local_shipping_rounded,
                      ),
                    ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isActive ? const Color(0xFFC4FF2E) : const Color(0xFFF1F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF0F172A) : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFF334155),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: OtpColors.purpleAccent,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData({
    required this.title,
    required this.category,
    required this.amount,
    required this.iconBg,
    required this.icon,
    this.iconColor,
    this.isIncome = false,
  });

  final String title;
  final String category;
  final double amount;
  final Color iconBg;
  final IconData icon;
  final Color? iconColor;
  final bool isIncome;
}

class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.dateLabel,
    required this.transactions,
  });

  final String dateLabel;
  final List<_TransactionData> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            dateLabel,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.33,
              letterSpacing: 1.20,
            ),
          ),
        ),
        // Transactions
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                _TransactionTile(data: transactions[i]),
                if (i < transactions.length - 1)
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFF1F5F9),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data});

  final _TransactionData data;

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 2,
    );
    return formatter.format(amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = data.isIncome || data.amount > 0;
    final amountText = '${isIncome ? '+' : '-'}${_formatAmount(data.amount)}';

    return InkWell(
      onTap: () {
        // TODO: Navigate to transaction details
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Icon(
                data.icon,
                size: 22,
                color: data.iconColor ?? const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 12),
            // Title and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.category,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              amountText,
              style: TextStyle(
                color: isIncome ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
