import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class BonusesScreen extends StatefulWidget {
  const BonusesScreen({super.key});

  @override
  State<BonusesScreen> createState() => _BonusesScreenState();
}

class _BonusesScreenState extends State<BonusesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _api = ApiClient();
  
  // Состояние
  bool _loadingStores = true;
  bool _loadingBalance = true;
  List<Map<String, dynamic>> _stores = [];
  Map<String, dynamic>? _balance;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStores(),
      _loadBalance(),
      _loadTransactions(),
    ]);
  }

  Future<void> _loadStores() async {
    try {
      final res = await _api.dio.get('/bonuses/stores');
      final data = res.data;
      if (data is Map && data['items'] is List) {
        setState(() {
          _stores = List<Map<String, dynamic>>.from(data['items']);
          _loadingStores = false;
        });
      }
    } catch (e) {
      setState(() => _loadingStores = false);
    }
  }

  Future<void> _loadBalance() async {
    try {
      final res = await _api.dio.get('/bonuses/balance');
      setState(() {
        _balance = res.data as Map<String, dynamic>?;
        _loadingBalance = false;
      });
    } catch (e) {
      setState(() => _loadingBalance = false);
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final res = await _api.dio.get('/bonuses/transactions');
      final data = res.data;
      if (data is Map && data['items'] is List) {
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(data['items']);
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Кэшбэк и бонусы',
            onBack: () => Navigator.of(context).pop(),
          ),
          // TabBar под AppBar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFFC1FF05),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Магазины'),
                Tab(text: 'Мои бонусы'),
                Tab(text: 'История'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StoresTab(stores: _stores, loading: _loadingStores),
                _MyBonusesTab(balance: _balance, loading: _loadingBalance),
                _HistoryTab(transactions: _transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Вкладка Магазины с каруселью
class _StoresTab extends StatelessWidget {
  final List<Map<String, dynamic>> stores;
  final bool loading;

  const _StoresTab({required this.stores, required this.loading});

  String _resolveLogo(String logo) {
    if (logo.isEmpty) return logo;
    if (logo.startsWith('http://') || logo.startsWith('https://')) return logo;
    if (logo.startsWith('/')) return '${AppConfig.baseUrl}$logo';
    return '${AppConfig.baseUrl}/$logo';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Карусель избранных
          if (stores.isNotEmpty) ...[
            const Text(
              'Популярные',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: stores.take(5).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return _StoreCard(
                    name: store['name']?.toString() ?? '',
                    logo: _resolveLogo(store['logo']?.toString() ?? ''),
                    color: _parseColor(store['color']),
                    cashback: store['cashbackPercent']?.toString() ?? '0',
                    description: store['description']?.toString() ?? '',
                    isFeatured: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Сетка всех магазинов
          const Text(
            'Все магазины',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...stores.map((store) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StoreListTile(
              name: store['name']?.toString() ?? '',
              logo: _resolveLogo(store['logo']?.toString() ?? ''),
              color: _parseColor(store['color']),
              cashback: store['cashbackPercent']?.toString() ?? '0',
              description: store['description']?.toString() ?? '',
            ),
          )),
        ],
      ),
    );
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return const Color(0xFF0F172A);
    try {
      final hex = colorValue.toString().replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF0F172A);
    }
  }
}

// Карточка магазина для карусели
class _StoreCard extends StatelessWidget {
  final String name;
  final String logo;
  final Color color;
  final String cashback;
  final String description;
  final bool isFeatured;

  const _StoreCard({
    required this.name,
    required this.logo,
    required this.color,
    required this.cashback,
    required this.description,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.store, color: color),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC1FF05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cashback%',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Элемент списка магазинов
class _StoreListTile extends StatelessWidget {
  final String name;
  final String logo;
  final Color color;
  final String cashback;
  final String description;

  const _StoreListTile({
    required this.name,
    required this.logo,
    required this.color,
    required this.cashback,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.store, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC1FF05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$cashback%',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Вкладка Мои бонусы
class _MyBonusesTab extends StatelessWidget {
  final Map<String, dynamic>? balance;
  final bool loading;

  const _MyBonusesTab({this.balance, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final points = balance?['points'] ?? 0;
    final equivalent = balance?['equivalent'] ?? 0;
    final expiringSoon = balance?['expiringSoon'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Карточка баланса
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Ваш баланс',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'баллов',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '≈ $equivalent ₽',
                  style: const TextStyle(
                    color: Color(0xFFC1FF05),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (expiringSoon > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFC1C1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$expiringSoon баллов сгорят через 30 дней',
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Инструкция
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF64748B)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '1 балл = 1 ₽. Баллы начисляются при оплате картой OTP Bank в партнёрских магазинах.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
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

// Вкладка История
class _HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const _HistoryTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'История пуста',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isEarn = t['type'] == 'earn';
        final amount = t['amount'] ?? 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isEarn 
                      ? const Color(0x33C1FF05) 
                      : const Color(0x33FF6B6B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEarn ? Icons.add : Icons.remove,
                  color: isEarn ? const Color(0xFF16A34A) : const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['storeName']?.toString() ?? '',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t['description']?.toString() ?? '',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isEarn ? '+' : ''}$amount',
                style: TextStyle(
                  color: isEarn ? const Color(0xFF16A34A) : const Color(0xFFFF6B6B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
