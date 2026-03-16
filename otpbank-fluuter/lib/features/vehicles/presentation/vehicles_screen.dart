import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/widgets/otp_primary_button.dart';
import '../../home/bloc/home_bloc.dart';
import 'vehicle_details_screen.dart';
import 'autopayment_widgets.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _api = ApiClient();
  bool _loading = true;
  List<_Vehicle> _vehicles = [];
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
      final res = await _api.dio.get('/vehicles');
      final data = res.data;
      final items = <_Vehicle>[];
      
      if (data is Map && data['items'] is List) {
        for (final v in (data['items'] as List)) {
          if (v is! Map) continue;
          items.add(_Vehicle(
            id: v['id']?.toString() ?? '',
            brand: v['brand']?.toString() ?? '',
            model: v['model']?.toString() ?? '',
            year: int.tryParse(v['year']?.toString() ?? '0') ?? 0,
            licensePlate: v['licensePlate']?.toString() ?? '',
          ));
        }
      }
      
      setState(() => _vehicles = items);
      
      // Refresh HomeBloc to update home screen with new vehicle data
      if (mounted) {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
      }
    } catch (_) {
      setState(() => _vehicles = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openVehicle(_Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleDetailsScreen(vehicleId: vehicle.id),
      ),
    );
  }

  void _showAddVehicle() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddVehicleSheet(onAdded: _load),
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
            title: 'Моё авто',
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: _showAddVehicle,
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
                else if (_vehicles.isEmpty)
                  _EmptyState(onAdd: _showAddVehicle)
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
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _vehicles[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _VehicleCard(vehicle: vehicle),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Page indicator
                      _PageIndicator(
                        currentIndex: _currentIndex,
                        pageCount: _vehicles.length,
                      ),
                      const SizedBox(height: 24),
                      // Vehicle details
                      if (_vehicles.isNotEmpty)
                        _VehicleDetails(vehicle: _vehicles[_currentIndex]),
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

class _Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;

  _Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
  });

  String get displayName => '$brand $model';
}

class _VehicleCard extends StatelessWidget {
  final _Vehicle vehicle;

  const _VehicleCard({
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7D32), Color(0xFF9E6FC3)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_filled, color: Color(0xFFFF7D32), size: 28),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${vehicle.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vehicle.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.licensePlate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
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
            child: const Icon(Icons.directions_car_outlined, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'У вас пока нет авто',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте автомобиль\nчтобы отслеживать расходы',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OtpPrimaryButton(
              label: 'Добавить авто',
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  final VoidCallback onAdded;

  const _AddVehicleSheet({required this.onAdded});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _api = ApiClient();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  String _selectedYear = '';
  bool _submitting = false;

  final List<String> _years = List.generate(
    DateTime.now().year - 1899,
    (index) => (DateTime.now().year - index).toString(),
  );

  Future<void> _submit() async {
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final year = _selectedYear.isNotEmpty ? int.tryParse(_selectedYear) : null;

    if (brand.isEmpty || model.isEmpty || year == null) {
      _toast('Заполните марку, модель и год');
      return;
    }

    if (year < 1900 || year > DateTime.now().year + 1) {
      _toast('Введите корректный год');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.dio.post('/vehicles', data: {
        'type': 'car',
        'brand': brand,
        'model': model,
        'year': year,
        'licensePlate': _plateController.text.trim(),
      });
      
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAdded();
    } catch (e) {
      _toast('Не удалось добавить авто');
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
                  'Добавить авто',
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
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(
              labelText: 'Марка *',
              hintText: 'Например: Toyota',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: 'Модель *',
              hintText: 'Например: Camry',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYear.isNotEmpty ? _selectedYear : null,
                hint: const Text('Год выпуска *'),
                isExpanded: true,
                items: _years.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedYear = value ?? '');
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _plateController,
            decoration: const InputDecoration(
              labelText: 'Гос. номер',
              hintText: 'А123БС77',
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
                ? const Color(0xFFFF7D32)
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _VehicleDetails extends StatelessWidget {
  final _Vehicle vehicle;

  const _VehicleDetails({required this.vehicle});

  void _openVehicle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleDetailsScreen(vehicleId: vehicle.id),
      ),
    );
  }

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
          AutopaymentCategory(icon: Icons.local_gas_station, label: 'Топливо'),
          AutopaymentCategory(icon: Icons.local_parking, label: 'Парковка'),
          AutopaymentCategory(icon: Icons.local_car_wash, label: 'Мойка'),
          AutopaymentCategory(icon: Icons.build, label: 'СТО'),
          AutopaymentCategory(icon: Icons.shopping_cart, label: 'Запчасти'),
          AutopaymentCategory(icon: Icons.security, label: 'Страховка'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Детали авто',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => _openVehicle(context),
                child: const Text(
                  'Подробнее',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Нет автоплатежей',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddAutopaymentSheet(context),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text(
                        'Добавить',
                        style: TextStyle(
                          color: Color(0xFFC4FF2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: const Color(0xFFC4FF2E).withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Добавьте автоплатежи для автоматического списания средств на топливо, парковку, мойку и другие услуги',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
