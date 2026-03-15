import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/widgets/otp_primary_button.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _api = ApiClient();
  bool _loading = true;
  _Vehicle? _vehicle;
  List<_Autopayment> _autopayments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final vehicleRes = await _api.dio.get('/vehicles/${widget.vehicleId}');
      final autopayRes = await _api.dio.get('/autopayments/vehicle/${widget.vehicleId}');
      
      final v = vehicleRes.data;
      if (v is Map) {
        _vehicle = _Vehicle(
          id: v['id']?.toString() ?? '',
          brand: v['brand']?.toString() ?? '',
          model: v['model']?.toString() ?? '',
          year: (v['year'] as num?)?.toInt() ?? 0,
          licensePlate: v['licensePlate']?.toString() ?? '',
          monthlyFuelCost: v['monthlyFuelCost']?.toString() ?? '0',
          monthlyInsurance: v['monthlyInsurance']?.toString() ?? '0',
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
      _vehicle = _Vehicle(
        id: widget.vehicleId,
        brand: 'Toyota',
        model: 'Camry',
        year: 2020,
        licensePlate: 'А123БС77',
        monthlyFuelCost: '15000',
        monthlyInsurance: '8000',
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
      builder: (_) => _AddVehicleAutopaymentSheet(
        vehicleId: widget.vehicleId,
        onAdded: _load,
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'fuel':
        return Icons.local_gas_station_outlined;
      case 'insurance':
        return Icons.shield_outlined;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      case 'tax':
        return Icons.receipt_outlined;
      default:
        return Icons.payments_outlined;
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
          OtpUniversalAppBar(title: _vehicle?.displayName ?? 'Автомобиль'),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ))
          else if (_vehicle != null) ...[
            _VehicleHeader(vehicle: _vehicle!),
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

class _Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String monthlyFuelCost;
  final String monthlyInsurance;

  _Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.monthlyFuelCost,
    required this.monthlyInsurance,
  });

  String get displayName => '$brand $model';
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

class _VehicleHeader extends StatelessWidget {
  final _Vehicle vehicle;

  const _VehicleHeader({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7D32), Color(0xFF9E6FC3)],
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.directions_car_filled, color: Color(0xFFFF7D32), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} • ${vehicle.licensePlate}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Топливо/мес',
                value: '${vehicle.monthlyFuelCost} ₽',
              ),
              _StatItem(
                label: 'Страховка',
                value: '${vehicle.monthlyInsurance} ₽',
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
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
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
              color: const Color(0xFFFF7D32).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF7D32), size: 20),
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
            activeColor: const Color(0xFFFF7D32),
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
            'Добавьте автоплатежи для топлива,\nстраховки и других расходов',
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

class _AddVehicleAutopaymentSheet extends StatefulWidget {
  final String vehicleId;
  final VoidCallback onAdded;

  const _AddVehicleAutopaymentSheet({
    required this.vehicleId,
    required this.onAdded,
  });

  @override
  State<_AddVehicleAutopaymentSheet> createState() => _AddVehicleAutopaymentSheetState();
}

class _AddVehicleAutopaymentSheetState extends State<_AddVehicleAutopaymentSheet> {
  final _api = ApiClient();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'fuel';
  int _paymentDay = 15;
  bool _submitting = false;

  final _categories = [
    ('fuel', 'Топливо', Icons.local_gas_station_outlined),
    ('insurance', 'Страховка', Icons.shield_outlined),
    ('parking', 'Паркинг', Icons.local_parking_outlined),
    ('maintenance', 'ТО и ремонт', Icons.build_outlined),
    ('tax', 'Транспортный налог', Icons.receipt_outlined),
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
        'vehicleId': widget.vehicleId,
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
                selectedColor: const Color(0xFFFF7D32).withOpacity(0.3),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название',
              hintText: 'Например: Заправка Shell',
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
                onChanged: (v) => setState(() => _paymentDay = v ?? 15),
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
