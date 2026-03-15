import 'package:flutter/material.dart';

class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const _PageIndicator({
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFF0F172A)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _PropertyDetails extends StatelessWidget {
  final _Property property;

  const _PropertyDetails({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPropertyIcon(property.type),
                color: const Color(0xFF0F172A),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      property.address,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Платеж',
                  value: property.monthlyPayment.isEmpty ? '0 ₽/мес' : '${property.monthlyPayment} ₽/мес',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DetailItem(
                  icon: Icons.percent_outlined,
                  label: 'Кэшбэк',
                  value: '${property.cashbackPercent.toStringAsFixed(1)}%',
                  valueColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.home_outlined,
                  label: 'Тип',
                  value: _getPropertyTypeLabel(property.type),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DetailItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Добавлен',
                  value: 'Сегодня',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPropertyIcon(String type) {
    switch (type) {
      case 'house':
        return Icons.home_outlined;
      case 'apartment':
        return Icons.apartment_outlined;
      case 'country_house':
        return Icons.forest_outlined;
      default:
        return Icons.home_work_outlined;
    }
  }

  String _getPropertyTypeLabel(String type) {
    switch (type) {
      case 'house':
        return 'Дом';
      case 'apartment':
        return 'Квартира';
      case 'country_house':
        return 'Дача';
      default:
        return 'Недвижимость';
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Property {
  final String id;
  final String type;
  final String name;
  final String address;
  final String monthlyPayment;
  final double cashbackPercent;

  _Property({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.monthlyPayment,
    required this.cashbackPercent,
  });
}
