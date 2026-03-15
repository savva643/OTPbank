import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/widgets/otp_primary_button.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _api = ApiClient();
  bool _loading = true;
  _Property? _property;
  List<_Autopayment> _autopayments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final propertyRes = await _api.dio.get('/properties/${widget.propertyId}');
      final autopayRes = await _api.dio.get('/autopayments/property/${widget.propertyId}');
      
      final p = propertyRes.data;
      if (p is Map) {
        _property = _Property(
          id: p['id']?.toString() ?? '',
          name: p['name']?.toString() ?? '',
          type: p['type']?.toString() ?? '',
          address: p['address']?.toString() ?? '',
          monthlyPayment: p['monthlyPayment']?.toString() ?? '0',
        );
      }

      final items = <_Autopayment>[];
      final autoData = autopayRes.data;
      if (autoData is Map && autoData['items'] is List) {
        for (final a in (autoData['items'] as List)) {
          if (a is! Map) continue;
          items.add(_Autopayment(
            id: a['id']?.toString() ?? '',
            name: a['name']?.toString() ?? '',
            category: a['category']?.toString() ?? '',
            amount: a['amount']?.toString() ?? '0',
            paymentDay: (a['paymentDay'] as num?)?.toInt() ?? 1,
            isActive: a['isActive'] == true,
          ));
        }
      }
      setState(() => _autopayments = items);
    } catch (_) {
      // Mock data
      _property = _Property(
        id: widget.propertyId,
        name: 'Моя квартира',
        type: 'apartment',
        address: 'ул. Ленина, 1',
        monthlyPayment: '45000',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showAddAutopayment() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddAutopaymentSheet(
        propertyId: widget.propertyId,
        onAdded: _load,
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'internet':
        return Icons.wifi_outlined;
      case 'utilities':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.electric_bolt_outlined;
      case 'gas':
        return Icons.local_fire_department_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'tv':
        return Icons.tv_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          OtpUniversalAppBar(title: _property?.name ?? 'Объект'),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ))
          else if (_property != null) ...[
            _PropertyHeader(property: _property!),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Автоплатежи',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddAutopayment,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Добавить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_autopayments.isEmpty)
                    _EmptyAutopayments(onAdd: _showAddAutopayment)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _autopayments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final a = _autopayments[index];
                        return _AutopaymentCard(
                          autopayment: a,
                          icon: _iconForCategory(a.category),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Property {
  final String id;
  final String name;
  final String type;
  final String address;
  final String monthlyPayment;

  _Property({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.monthlyPayment,
  });
}

class _Autopayment {
  final String id;
  final String name;
  final String category;
  final String amount;
  final int paymentDay;
  final bool isActive;

  _Autopayment({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.paymentDay,
    required this.isActive,
  });
}

class _PropertyHeader extends StatelessWidget {
  final _Property property;

  const _PropertyHeader({required this.property});

  IconData get _icon {
    switch (property.type) {
      case 'house':
        return Icons.home_outlined;
      case 'apartment':
        return Icons.apartment_outlined;
      default:
        return Icons.home_work_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFC1FF05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon, color: const Color(0xFF0F172A), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.address,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Расходы/мес',
                value: '${property.monthlyPayment} ₽',
              ),
              _StatItem(
                label: 'Автоплатежи',
                value: '0 активных',
              ),
              _StatItem(
                label: 'Кешбэк',
                value: 'до 5%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFC1FF05),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AutopaymentCard extends StatelessWidget {
  final _Autopayment autopayment;
  final IconData icon;

  const _AutopaymentCard({
    required this.autopayment,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFC1FF05).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  autopayment.name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${autopayment.amount} ₽ • ${autopayment.paymentDay} числа',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: autopayment.isActive,
            onChanged: (_) {},
            activeColor: const Color(0xFFC1FF05),
          ),
        ],
      ),
    );
  }
}

class _EmptyAutopayments extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAutopayments({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.schedule_outlined, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          const Text(
            'Нет автоплатежей',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Добавьте автоплатежи для ЖКХ,\nинтернета и других услуг',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          OtpPrimaryButton(
            label: 'Добавить автоплатёж',
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _AddAutopaymentSheet extends StatefulWidget {
  final String propertyId;
  final VoidCallback onAdded;

  const _AddAutopaymentSheet({
    required this.propertyId,
    required this.onAdded,
  });

  @override
  State<_AddAutopaymentSheet> createState() => _AddAutopaymentSheetState();
}

class _AddAutopaymentSheetState extends State<_AddAutopaymentSheet> {
  final _api = ApiClient();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'utilities';
  int _paymentDay = 10;
  bool _submitting = false;

  final _categories = [
    ('utilities', 'ЖКХ', Icons.water_drop_outlined),
    ('internet', 'Интернет', Icons.wifi_outlined),
    ('electricity', 'Электричество', Icons.electric_bolt_outlined),
    ('gas', 'Газ', Icons.local_fire_department_outlined),
    ('security', 'Охрана', Icons.security_outlined),
    ('phone', 'Телефон', Icons.phone_outlined),
    ('tv', 'ТВ', Icons.tv_outlined),
  ];

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty || amount == null) {
      _toast('Заполните все поля');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.dio.post('/autopayments', data: {
        'propertyId': widget.propertyId,
        'name': name,
        'category': _category,
        'amount': amount,
        'paymentDay': _paymentDay,
        'isActive': true,
      });
      
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAdded();
      _toast('Автоплатёж добавлен');
    } catch (_) {
      _toast('Не удалось добавить автоплатёж');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Новый автоплатёж',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Категория',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final (id, label, icon) = c;
              final selected = _category == id;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16),
                    const SizedBox(width: 4),
                    Text(label),
                  ],
                ),
                selected: selected,
                onSelected: (_) => setState(() => _category = id),
                selectedColor: const Color(0xFFC1FF05),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название',
              hintText: 'Например: Оплата ЖКХ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Сумма',
              suffixText: '₽',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('День платежа:'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _paymentDay,
                items: List.generate(31, (i) => i + 1).map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text('$d числа'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _paymentDay = v ?? 10),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OtpPrimaryButton(
            label: _submitting ? 'Сохранение...' : 'Сохранить',
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
