import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_search_input.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _api = ApiClient();
  bool _isSearching = false;
  String _query = '';
  
  // Результаты поиска
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _stores = [];

  // История поиска
  List<String> _searchHistory = [
    'Перевод Ивану',
    'Пополнить телефон',
    'Магнит бонусы',
  ];

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _query = query;
    });

    try {
      // Поиск по счетам
      final accountsRes = await _api.dio.get('/accounts');
      final accountsData = accountsRes.data;
      if (accountsData is Map && accountsData['items'] is List) {
        final allAccounts = List<Map<String, dynamic>>.from(accountsData['items']);
        _accounts = allAccounts.where((a) {
          final title = a['title']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase());
        }).toList();
      }

      // Поиск по картам
      final cardsRes = await _api.dio.get('/cards');
      final cardsData = cardsRes.data;
      if (cardsData is Map && cardsData['items'] is List) {
        final allCards = List<Map<String, dynamic>>.from(cardsData['items']);
        _cards = allCards.where((c) {
          final title = c['accountTitle']?.toString().toLowerCase() ?? '';
          final number = c['maskedCardNumber']?.toString() ?? '';
          return title.contains(query.toLowerCase()) || 
                 number.contains(query);
        }).toList();
      }

      // Поиск по транзакциям
      final txRes = await _api.dio.get('/transactions', queryParameters: {'limit': 50});
      final txData = txRes.data;
      if (txData is Map && txData['items'] is List) {
        final allTx = List<Map<String, dynamic>>.from(txData['items']);
        _transactions = allTx.where((t) {
          final merchant = t['merchantName']?.toString().toLowerCase() ?? '';
          final category = t['category']?.toString().toLowerCase() ?? '';
          return merchant.contains(query.toLowerCase()) || 
                 category.contains(query.toLowerCase());
        }).toList();
      }

      // Поиск по магазинам (бонусы)
      final storesRes = await _api.dio.get('/bonuses/stores');
      final storesData = storesRes.data;
      if (storesData is Map && storesData['items'] is List) {
        final allStores = List<Map<String, dynamic>>.from(storesData['items']);
        _stores = allStores.where((s) {
          final name = s['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }

      // Добавляем в историю
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > 10) {
            _searchHistory = _searchHistory.take(10).toList();
          }
        });
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _accounts.isNotEmpty || 
                       _cards.isNotEmpty || 
                       _transactions.isNotEmpty || 
                       _stores.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Поиск',
            onBack: () => Navigator.of(context).pop(),
          ),
          // Виджет поиска под AppBar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: OtpSearchInput(
              controller: _searchController,
              hintText: 'Поиск по приложению...',
              autofocus: true,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _query = '';
                    _accounts = [];
                    _cards = [];
                    _transactions = [];
                    _stores = [];
                  });
                }
              },
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _query.isEmpty
                    ? _buildHistory()
                    : hasResults
                        ? _buildResults()
                        : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'История поиска',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_searchHistory.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _searchHistory.clear()),
                  child: const Text('Очистить'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._searchHistory.map((query) => ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF94A3B8)),
            title: Text(query),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
            onTap: () {
              _searchController.text = query;
              _performSearch(query);
            },
          )),
          const SizedBox(height: 24),
          const Text(
            'Быстрый доступ',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                icon: Icons.swap_horiz,
                label: 'Перевод',
                onTap: () => _performSearch('перевод'),
              ),
              _QuickActionChip(
                icon: Icons.payments,
                label: 'Оплатить',
                onTap: () => _performSearch('оплата'),
              ),
              _QuickActionChip(
                icon: Icons.card_giftcard,
                label: 'Бонусы',
                onTap: () => _performSearch('бонусы'),
              ),
              _QuickActionChip(
                icon: Icons.account_balance,
                label: 'Счета',
                onTap: () => _performSearch('счет'),
              ),
              _QuickActionChip(
                icon: Icons.credit_card,
                label: 'Карты',
                onTap: () => _performSearch('карта'),
              ),
              _QuickActionChip(
                icon: Icons.receipt_long,
                label: 'История',
                onTap: () => _performSearch('транзакция'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Счета
        if (_accounts.isNotEmpty) ...[
          _SectionTitle('Счета (${_accounts.length})'),
          ..._accounts.map((a) => _AccountResultTile(
            title: a['title']?.toString() ?? 'Счёт',
            balance: '${a['balance'] ?? 0} ${a['currency'] ?? '₽'}',
            onTap: () {
              // Navigate to account
            },
          )),
          const SizedBox(height: 16),
        ],

        // Карты
        if (_cards.isNotEmpty) ...[
          _SectionTitle('Карты (${_cards.length})'),
          ..._cards.map((c) => _CardResultTile(
            title: c['accountTitle']?.toString() ?? 'Карта',
            number: c['maskedCardNumber']?.toString() ?? '****',
            type: c['productType']?.toString() ?? 'debit',
            onTap: () {
              // Navigate to card
            },
          )),
          const SizedBox(height: 16),
        ],

        // Транзакции
        if (_transactions.isNotEmpty) ...[
          _SectionTitle('Операции (${_transactions.length})'),
          ..._transactions.map((t) => _TransactionResultTile(
            merchant: t['merchantName']?.toString() ?? 'Операция',
            amount: '${t['amount'] ?? 0} ${t['currency'] ?? '₽'}',
            date: _formatDate(t['date']?.toString()),
            type: t['type']?.toString() ?? 'expense',
            onTap: () {
              // Navigate to transaction
            },
          )),
          const SizedBox(height: 16),
        ],

        // Магазины
        if (_stores.isNotEmpty) ...[
          _SectionTitle('Магазины (${_stores.length})'),
          ..._stores.map((s) => _StoreResultTile(
            name: s['name']?.toString() ?? '',
            cashback: s['cashbackPercent']?.toString() ?? '0',
            onTap: () {
              // Navigate to store
            },
          )),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Ничего не найдено',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте другой запрос',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (_) {
      return '';
    }
  }
}

// Виджеты результатов

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccountResultTile extends StatelessWidget {
  final String title;
  final String balance;
  final VoidCallback onTap;

  const _AccountResultTile({
    required this.title,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.account_balance, color: Color(0xFF0F172A)),
      ),
      title: Text(title),
      subtitle: Text(balance, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}

class _CardResultTile extends StatelessWidget {
  final String title;
  final String number;
  final String type;
  final VoidCallback onTap;

  const _CardResultTile({
    required this.title,
    required this.number,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = type == 'credit' ? Icons.credit_card : Icons.payment;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0F172A)),
      ),
      title: Text(title),
      subtitle: Text(number),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}

class _TransactionResultTile extends StatelessWidget {
  final String merchant;
  final String amount;
  final String date;
  final String type;
  final VoidCallback onTap;

  const _TransactionResultTile({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isIncome ? const Color(0x3316A34A) : const Color(0x33F1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
        ),
      ),
      title: Text(merchant),
      subtitle: Text(date),
      trailing: Text(
        '${isIncome ? '+' : ''}$amount',
        style: TextStyle(
          color: isIncome ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _StoreResultTile extends StatelessWidget {
  final String name;
  final String cashback;
  final VoidCallback onTap;

  const _StoreResultTile({
    required this.name,
    required this.cashback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x33C1FF05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.store, color: Color(0xFF0F172A)),
      ),
      title: Text(name),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFC1FF05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$cashback%',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
      label: Text(label),
      labelStyle: const TextStyle(color: Color(0xFF0F172A)),
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      onPressed: onTap,
    );
  }
}
