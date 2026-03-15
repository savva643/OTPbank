import 'package:flutter/material.dart';
import '../../../core/widgets/otp_search_input.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';

/// Модель данных для услуги/поставщика в категории
class PaymentService {
  final String id;
  final String name;
  final String? description;
  final IconData? icon;
  final String? imageUrl;
  final Color? iconColor;
  final Color? backgroundColor;
  final String categoryId;

  const PaymentService({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.imageUrl,
    this.iconColor,
    this.backgroundColor,
    required this.categoryId,
  });
}

/// Аргументы для экрана категории
class CategoryServicesArgs {
  final String categoryId;
  final String categoryName;
  final Color backgroundColor;
  final Color iconColor;

  const CategoryServicesArgs({
    required this.categoryId,
    required this.categoryName,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class CategoryServicesScreen extends StatefulWidget {
  final CategoryServicesArgs args;

  const CategoryServicesScreen({
    super.key,
    required this.args,
  });

  @override
  State<CategoryServicesScreen> createState() => _CategoryServicesScreenState();
}

class _CategoryServicesScreenState extends State<CategoryServicesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _api = ApiClient();
  List<PaymentService> _allServices = [];
  List<PaymentService> _filteredServices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_onSearchChanged);
  }

  String? _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${AppConfig.baseUrl}$url';
    return '${AppConfig.baseUrl}/$url';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _allServices;
      } else {
        _filteredServices = _allServices.where((service) {
          return service.name.toLowerCase().contains(query) ||
              (service.description?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final res = await _api.dio.get('/categories/${widget.args.categoryId}/services');
      final data = res.data;
      
      if (data is Map && data['items'] is List) {
        final services = (data['items'] as List).map((item) => PaymentService(
          id: item['id']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
          description: item['description']?.toString(),
          icon: _getIconData(item['icon']?.toString()),
          imageUrl: item['imageUrl']?.toString(),
          categoryId: item['categoryId']?.toString() ?? widget.args.categoryId,
          backgroundColor: _parseColor(item['bgColor']?.toString()),
          iconColor: _parseColor(item['iconColor']?.toString()),
        )).toList();
        
        setState(() {
          _allServices = services;
          _filteredServices = services;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Неверный формат данных';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'phone_android_rounded':
        return Icons.phone_android_rounded;
      case 'apartment_rounded':
        return Icons.apartment_rounded;
      case 'wifi_rounded':
        return Icons.wifi_rounded;
      case 'receipt_long_rounded':
        return Icons.receipt_long_rounded;
      case 'account_balance_rounded':
        return Icons.account_balance_rounded;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
      case 'school_rounded':
        return Icons.school_rounded;
      case 'local_hospital_rounded':
        return Icons.local_hospital_rounded;
      case 'shield_rounded':
        return Icons.shield_rounded;
      case 'account_balance_wallet_rounded':
        return Icons.account_balance_wallet_rounded;
      case 'sports_esports_rounded':
        return Icons.sports_esports_rounded;
      case 'shopping_bag_rounded':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0x')));
    } catch (_) {
      return null;
    }
  }

  List<PaymentService> _getMockServicesForCategory(String categoryId) {
    // Мок данные для каждой категории
    final servicesMap = {
      'mobile': [
        const PaymentService(
          id: '1',
          name: 'МТС',
          description: 'Мобильная связь',
          icon: Icons.phone_android_rounded,
          categoryId: 'mobile',
          backgroundColor: Color(0x33FF0033),
          iconColor: Color(0xFFFF0033),
        ),
        const PaymentService(
          id: '2',
          name: 'Билайн',
          description: 'Мобильная связь',
          icon: Icons.phone_android_rounded,
          categoryId: 'mobile',
          backgroundColor: Color(0x33FECC00),
          iconColor: Color(0xFFFECC00),
        ),
        const PaymentService(
          id: '3',
          name: 'МегаФон',
          description: 'Мобильная связь',
          icon: Icons.phone_android_rounded,
          categoryId: 'mobile',
          backgroundColor: Color(0x3300B2E5),
          iconColor: Color(0xFF00B2E5),
        ),
        const PaymentService(
          id: '4',
          name: 'Tele2',
          description: 'Мобильная связь',
          icon: Icons.phone_android_rounded,
          categoryId: 'mobile',
          backgroundColor: Color(0x33FF9900),
          iconColor: Color(0xFFFF9900),
        ),
        const PaymentService(
          id: '5',
          name: 'Yota',
          description: 'Мобильная связь',
          icon: Icons.phone_android_rounded,
          categoryId: 'mobile',
          backgroundColor: Color(0x3300B2E5),
          iconColor: Color(0xFF00B2E5),
        ),
      ],
      'utilities': [
        const PaymentService(
          id: '6',
          name: 'Мосэнергосбыт',
          description: 'Электроэнергия',
          icon: Icons.electric_bolt_rounded,
          categoryId: 'utilities',
          backgroundColor: Color(0x33F59E0B),
          iconColor: Color(0xFFF59E0B),
        ),
        const PaymentService(
          id: '7',
          name: 'Газпром Межрегионгаз',
          description: 'Газоснабжение',
          icon: Icons.local_fire_department_rounded,
          categoryId: 'utilities',
          backgroundColor: Color(0x33EF4444),
          iconColor: Color(0xFFEF4444),
        ),
        const PaymentService(
          id: '8',
          name: 'Мосводоканал',
          description: 'Водоснабжение',
          icon: Icons.water_drop_rounded,
          categoryId: 'utilities',
          backgroundColor: Color(0x333B82F6),
          iconColor: Color(0xFF3B82F6),
        ),
        const PaymentService(
          id: '9',
          name: 'МособлЕИРЦ',
          description: 'Единый расчетный центр',
          icon: Icons.apartment_rounded,
          categoryId: 'utilities',
          backgroundColor: Color(0x338B5CF6),
          iconColor: Color(0xFF8B5CF6),
        ),
      ],
      'government': [
        const PaymentService(
          id: '10',
          name: 'Госуслуги',
          description: 'Портал госуслуг',
          icon: Icons.account_balance_rounded,
          categoryId: 'government',
          backgroundColor: Color(0x330EA5E9),
          iconColor: Color(0xFF0EA5E9),
        ),
        const PaymentService(
          id: '11',
          name: 'Налоги ФНС',
          description: 'Федеральная налоговая служба',
          icon: Icons.receipt_long_rounded,
          categoryId: 'government',
          backgroundColor: Color(0x33EF4444),
          iconColor: Color(0xFFEF4444),
        ),
        const PaymentService(
          id: '12',
          name: 'Штрафы ГИБДД',
          description: 'Оплата штрафов',
          icon: Icons.local_police_rounded,
          categoryId: 'government',
          backgroundColor: Color(0x33F59E0B),
          iconColor: Color(0xFFF59E0B),
        ),
        const PaymentService(
          id: '13',
          name: 'Судебные задолженности',
          description: 'ФССП России',
          icon: Icons.gavel_rounded,
          categoryId: 'government',
          backgroundColor: Color(0x33DC2626),
          iconColor: Color(0xFFDC2626),
        ),
      ],
      'internet': [
        const PaymentService(
          id: '14',
          name: 'Ростелеком',
          description: 'Интернет и ТВ',
          icon: Icons.wifi_rounded,
          categoryId: 'internet',
          backgroundColor: Color(0x33910A60),
          iconColor: Color(0xFF910A60),
        ),
        const PaymentService(
          id: '15',
          name: 'Дом.ru',
          description: 'Интернет и ТВ',
          icon: Icons.wifi_rounded,
          categoryId: 'internet',
          backgroundColor: Color(0x33EF4444),
          iconColor: Color(0xFFEF4444),
        ),
        const PaymentService(
          id: '16',
          name: 'МТС Интернет',
          description: 'Домашний интернет',
          icon: Icons.wifi_rounded,
          categoryId: 'internet',
          backgroundColor: Color(0x33FF0033),
          iconColor: Color(0xFFFF0033),
        ),
        const PaymentService(
          id: '17',
          name: 'Билайн Интернет',
          description: 'Домашний интернет',
          icon: Icons.wifi_rounded,
          categoryId: 'internet',
          backgroundColor: Color(0x33FECC00),
          iconColor: Color(0xFFFECC00),
        ),
      ],
      'fines': [
        const PaymentService(
          id: '18',
          name: 'Штрафы ГИБДД',
          description: 'Административные штрафы',
          icon: Icons.local_police_rounded,
          categoryId: 'fines',
          backgroundColor: Color(0x33F59E0B),
          iconColor: Color(0xFFF59E0B),
        ),
        const PaymentService(
          id: '19',
          name: 'Штрафы парковки',
          description: 'Московский паркинг',
          icon: Icons.local_parking_rounded,
          categoryId: 'fines',
          backgroundColor: Color(0x33EF4444),
          iconColor: Color(0xFFEF4444),
        ),
        const PaymentService(
          id: '20',
          name: 'Налоги',
          description: 'Налоговые платежи',
          icon: Icons.receipt_long_rounded,
          categoryId: 'fines',
          backgroundColor: Color(0x330EA5E9),
          iconColor: Color(0xFF0EA5E9),
        ),
      ],
    };

    return servicesMap[categoryId] ?? _getDefaultServices(categoryId);
  }

  List<PaymentService> _getDefaultServices(String categoryId) {
    // Дефолтные сервисы для неизвестных категорий
    return [
      PaymentService(
        id: 'default_1',
        name: 'Сервис 1',
        icon: Icons.business_rounded,
        categoryId: categoryId,
        backgroundColor: widget.args.backgroundColor,
        iconColor: widget.args.iconColor,
      ),
      PaymentService(
        id: 'default_2',
        name: 'Сервис 2',
        icon: Icons.business_rounded,
        categoryId: categoryId,
        backgroundColor: widget.args.backgroundColor,
        iconColor: widget.args.iconColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: widget.args.categoryName,
            onBack: () => Navigator.pop(context),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: OtpSearchInput(
              controller: _searchController,
              hintText: 'Поиск услуги...',
              onChanged: (_) {},
            ),
          ),

          // Services list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4FF2E)),
                    ),
                  )
                : _error != null
                    ? _buildErrorState()
                    : _filteredServices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return _buildServiceTile(service);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ничего не найдено',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Попробуйте изменить запрос',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Ошибка загрузки',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadServices,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4FF2E),
              foregroundColor: const Color(0xFF0F172A),
            ),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(PaymentService service) {
    final resolvedImageUrl = _resolveImageUrl(service.imageUrl);
    return InkWell(
      onTap: () {
        _showPaymentForm(service);
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent,
      highlightColor: const Color(0xFFF1F5F9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.backgroundColor ?? const Color(0x33C4FF2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: resolvedImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        resolvedImageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => service.icon != null
                            ? Icon(
                                service.icon,
                                color: service.iconColor ?? const Color(0xFF0F172A),
                                size: 24,
                              )
                            : Icon(
                                Icons.business_rounded,
                                color: service.iconColor ?? const Color(0xFF0F172A),
                                size: 24,
                              ),
                      ),
                    )
                  : service.icon != null
                      ? Icon(
                          service.icon,
                          color: service.iconColor ?? const Color(0xFF0F172A),
                          size: 24,
                        )
                      : Icon(
                          Icons.business_rounded,
                          color: service.iconColor ?? const Color(0xFF0F172A),
                          size: 24,
                        ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (service.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.description!,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentForm(PaymentService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentFormSheet(service: service),
    );
  }
}

/// Нижний лист для формы оплаты
class _PaymentFormSheet extends StatefulWidget {
  final PaymentService service;

  const _PaymentFormSheet({required this.service});

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = widget.service.imageUrl != null && widget.service.imageUrl!.isNotEmpty
        ? (widget.service.imageUrl!.startsWith('http://') || widget.service.imageUrl!.startsWith('https://')
            ? widget.service.imageUrl!
            : (widget.service.imageUrl!.startsWith('/')
                ? '${AppConfig.baseUrl}${widget.service.imageUrl!}'
                : '${AppConfig.baseUrl}/${widget.service.imageUrl!}'))
        : null;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.service.backgroundColor ?? const Color(0x33C4FF2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: resolvedImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            resolvedImageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => widget.service.icon != null
                                ? Icon(
                                    widget.service.icon,
                                    color: widget.service.iconColor ?? const Color(0xFF0F172A),
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.business_rounded,
                                    color: widget.service.iconColor ?? const Color(0xFF0F172A),
                                    size: 24,
                                  ),
                          ),
                        )
                      : widget.service.icon != null
                          ? Icon(
                              widget.service.icon,
                              color: widget.service.iconColor ?? const Color(0xFF0F172A),
                              size: 24,
                            )
                          : Icon(
                              Icons.business_rounded,
                              color: widget.service.iconColor ?? const Color(0xFF0F172A),
                              size: 24,
                            ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.service.description != null)
                        Text(
                          widget.service.description!,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account number field
                  _buildTextField(
                    controller: _accountController,
                    label: 'Лицевой счет / Номер договора',
                    hint: 'Введите номер',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  // Amount field
                  _buildTextField(
                    controller: _amountController,
                    label: 'Сумма',
                    hint: '0.00 ₽',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Quick amounts
                  const Text(
                    'Быстрые суммы',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [100, 500, 1000, 2000, 5000].map((amount) {
                      return InkWell(
                        onTap: () {
                          _amountController.text = amount.toString();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '$amount ₽',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Pay button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Process payment
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Платеж успешно выполнен'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4FF2E),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Оплатить',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF9E6FC3),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
