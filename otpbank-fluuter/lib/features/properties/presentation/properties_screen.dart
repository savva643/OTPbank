import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/widgets/otp_primary_button.dart';
import '../../home/bloc/home_bloc.dart';
import 'property_details_screen.dart';
import 'properties_widgets.dart';
import 'property_autopayment_widgets.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final _api = ApiClient();
  bool _loading = true;
  List<_Property> _properties = [];
  int _currentIndex = 0;
  final _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/properties');
      final data = res.data;
      final items = <_Property>[];

      if (data is Map && data['items'] is List) {
        for (final p in (data['items'] as List)) {
          if (p is! Map) continue;
          items.add(_Property(
            id: p['id']?.toString() ?? '',
            type: p['type']?.toString() ?? 'apartment',
            name: p['name']?.toString() ?? 'Мой дом',
            address: p['address']?.toString() ?? '',
            monthlyPayment: p['monthlyPayment']?.toString() ?? '0',
            cashbackPercent: double.tryParse(p['cashbackPercent']?.toString() ?? '0') ?? 0,
          ));
        }
      }

      setState(() => _properties = items);

      // Refresh HomeBloc to update home screen with new property data
      if (mounted) {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
      }
    } catch (_) {
      setState(() => _properties = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openProperty(_Property property) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailsScreen(propertyId: property.id),
      ),
    );
  }

  void _showAddProperty() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddPropertySheet(onAdded: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          OtpUniversalAppBar(
            title: 'Мой дом',
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: _showAddProperty,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_properties.isEmpty)
                  _EmptyState(onAdd: _showAddProperty)
                else
                  Column(
                    children: [
                      // Carousel
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                          },
                          itemCount: _properties.length,
                          itemBuilder: (context, index) {
                            final property = _properties[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _PropertyCard(property: property),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Page indicator
                      _PageIndicator(
                        currentIndex: _currentIndex,
                        pageCount: _properties.length,
                      ),
                      const SizedBox(height: 24),
                      // Property details
                      if (_properties.isNotEmpty)
                        _PropertyDetails(property: _properties[_currentIndex]),
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

class _PropertyCard extends StatelessWidget {
  final _Property property;

  const _PropertyCard({
    required this.property,
  });

  IconData get _icon {
    switch (property.type) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: const Color(0xFFC1FF05), size: 28),
              const Spacer(),
              if (property.cashbackPercent > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1FF05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${property.cashbackPercent.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            property.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            property.address,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Платеж',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.monthlyPayment.isEmpty ? '0 ₽/мес' : '${property.monthlyPayment} ₽/мес',
                      style: const TextStyle(
                        color: Color(0xFFC1FF05),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (property.cashbackPercent > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Кэшбэк',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${property.cashbackPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home_outlined, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'У вас пока нет объектов',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте дом или квартиру\nчтобы отслеживать расходы',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          OtpPrimaryButton(
            label: 'Добавить объект',
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _AddPropertySheet extends StatefulWidget {
  final VoidCallback onAdded;

  const _AddPropertySheet({required this.onAdded});

  @override
  State<_AddPropertySheet> createState() => _AddPropertySheetState();
}

class _AddPropertySheetState extends State<_AddPropertySheet> {
  final _api = ApiClient();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedType = 'apartment';
  bool _submitting = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _toast('Введите название');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.dio.post('/properties', data: {
        'type': _selectedType,
        'name': name,
        'address': _addressController.text.trim(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAdded();
    } catch (_) {
      _toast('Не удалось добавить объект');
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
                  'Добавить объект',
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
          const SizedBox(height: 20),
          Row(
            children: [
              _TypeChip(
                label: 'Квартира',
                icon: Icons.apartment_outlined,
                selected: _selectedType == 'apartment',
                onTap: () => setState(() => _selectedType = 'apartment'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Дом',
                icon: Icons.home_outlined,
                selected: _selectedType == 'house',
                onTap: () => setState(() => _selectedType = 'house'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Дача',
                icon: Icons.forest_outlined,
                selected: _selectedType == 'country_house',
                onTap: () => setState(() => _selectedType = 'country_house'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название (например: Моя квартира)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Адрес',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OtpPrimaryButton(
              label: _submitting ? 'Добавление...' : 'Добавить',
              onPressed: _submitting ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFC1FF05) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFFC1FF05) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF0F172A), size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      children: List.generate(pageCount, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index
                ? const Color(0xFF0F172A)
                : const Color(0xFFE2E8F0),
          ),
        );
      }),
    );
  }
}

class _PropertyDetails extends StatelessWidget {
  final _Property property;

  const _PropertyDetails({required this.property});

  void _showAddAutopaymentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddAutopaymentSheet(
        categories: const [
          AutopaymentCategory(icon: Icons.home_work_outlined, label: 'ЖКХ'),
          AutopaymentCategory(icon: Icons.wifi_outlined, label: 'Интернет'),
          AutopaymentCategory(icon: Icons.electrical_services_outlined, label: 'Электричество'),
          AutopaymentCategory(icon: Icons.local_fire_department_outlined, label: 'Газ'),
          AutopaymentCategory(icon: Icons.security_outlined, label: 'Охрана'),
          AutopaymentCategory(icon: Icons.water_drop_outlined, label: 'Вода'),
          AutopaymentCategory(icon: Icons.more_horiz, label: 'Другое'),
        ],
        onAdded: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Автоплатеж добавлен'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Детали объекта',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Нет автоплатежей',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Добавьте автоплатежи для автоматической оплаты ЖКХ, интернета, охраны и других услуг',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (property.cashbackPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1FF05).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Кэшбэк',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${property.cashbackPercent.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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