import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../products/presentation/product_details_screen.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final _api = ApiClient();
  bool _loading = true;
  List<_BusinessProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/products');
      final data = res.data;
      final items = <_BusinessProduct>[];
      
      if (data is Map && data['items'] is List) {
        for (final p in (data['items'] as List)) {
          if (p is! Map) continue;
          final category = p['category']?.toString() ?? '';
          if (category.toLowerCase() != 'бизнес') continue;
          
          items.add(_BusinessProduct(
            id: p['id']?.toString() ?? '',
            name: p['name']?.toString() ?? 'Продукт',
            description: p['description']?.toString() ?? '',
            icon: _iconForProduct(p['name']?.toString() ?? ''),
          ));
        }
      }
      
      setState(() => _products = items);
    } catch (_) {
      // Fallback данные
      setState(() => _products = [
        _BusinessProduct(
          id: 'business-account',
          name: 'Расчётный счёт',
          description: 'Для ИП и юридических лиц',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _BusinessProduct(
          id: 'business-card',
          name: 'Бизнес-карта',
          description: 'Корпоративные расходы',
          icon: Icons.credit_card_outlined,
        ),
        _BusinessProduct(
          id: 'business-loan',
          name: 'Овердрафт',
          description: 'Револьверная кредитная линия',
          icon: Icons.trending_up_outlined,
        ),
      ]);
    } finally {
      setState(() => _loading = false);
    }
  }

  IconData _iconForProduct(String name) {
    final n = name.toLowerCase();
    if (n.contains('счёт') || n.contains('account')) return Icons.account_balance_wallet_outlined;
    if (n.contains('карт')) return Icons.credit_card_outlined;
    if (n.contains('кредит') || n.contains('овердрафт')) return Icons.trending_up_outlined;
    return Icons.business_outlined;
  }

  void _openProduct(_BusinessProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(
          productId: product.id,
          titleFallback: product.name,
        ),
      ),
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
          const OtpUniversalAppBar(title: 'Бизнес'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Бизнес-продукты',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Решения для вашего бизнеса',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      return _BusinessProductCard(
                        product: p,
                        onTap: () => _openProduct(p),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessProduct {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  _BusinessProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class _BusinessProductCard extends StatelessWidget {
  final _BusinessProduct product;
  final VoidCallback onTap;

  const _BusinessProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFC1FF05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(product.icon, color: const Color(0xFF0F172A), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
