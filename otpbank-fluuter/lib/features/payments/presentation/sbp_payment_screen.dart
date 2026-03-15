import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../home/bloc/home_bloc.dart';

class SbpPaymentScreen extends StatefulWidget {
  const SbpPaymentScreen({
    super.key,
    required this.recipientName,
    required this.recipientPhoneDigits,
    required this.isInternalRecipient,
  });

  final String? recipientName;
  final String recipientPhoneDigits;
  final bool isInternalRecipient;

  @override
  State<SbpPaymentScreen> createState() => _SbpPaymentScreenState();
}

class _SbpPaymentScreenState extends State<SbpPaymentScreen> {
  late final TextEditingController _amountController;
  late final List<_BankInfo> _discoveredBanks;
  _BankInfo? _selectedBank;
  final _api = ApiClient();

  // Счёта
  List<Map<String, dynamic>> _accounts = [];
  Map<String, dynamic>? _selectedAccount;
  bool _accountsLoading = false;

  static const _allBanks = <_BankInfo>[
    _BankInfo(
      id: 'otp',
      title: 'ОТП Банк',
      assetPath: 'assets/img/bank/otp.png',
      color: Color(0xFFC1FF05),
      isOur: true,
    ),
    _BankInfo(
      id: 'sber',
      title: 'Сбер',
      assetPath: 'assets/img/bank/sber.png',
      color: Color(0xFF1AB248),
    ),
    _BankInfo(
      id: 'tbank',
      title: 'Т-Банк',
      assetPath: 'assets/img/bank/tbank.png',
      color: Color(0xFFFFDD2D),
    ),
    _BankInfo(
      id: 'alfa',
      title: 'Альфа-Банк',
      assetPath: 'assets/img/bank/alfa.png',
      color: Color(0xFFED1C24),
    ),
    _BankInfo(
      id: 'vtb',
      title: 'ВТБ',
      assetPath: 'assets/img/bank/vtb.png',
      color: Color(0xFF032973),
    ),
    _BankInfo(
      id: 'gazprom',
      title: 'Газпромбанк',
      assetPath: 'assets/img/bank/gazprom.png',
      color: Color(0xFF00457C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '0');
    _amountController.addListener(_onAmountChanged);
    _loadAccounts();

    final our = _allBanks.firstWhere((b) => b.isOur);
    final external = _allBanks.where((b) => !b.isOur).toList(growable: false);

    final seed = widget.recipientPhoneDigits.hashCode;
    final rnd = Random(seed);
    final count = rnd.nextInt(4);

    final shuffled = external.toList()..shuffle(rnd);
    _discoveredBanks = [our, ...shuffled.take(count)];

    _selectedBank = widget.isInternalRecipient ? our : (_discoveredBanks.length > 1 ? _discoveredBanks[1] : our);
  }

  Future<void> _loadAccounts() async {
    setState(() => _accountsLoading = true);
    try {
      final res = await _api.dio.get('/accounts');
      final data = res.data;
      final list = data is Map && data['items'] is List
          ? List<Map<String, dynamic>>.from(data['items'])
          : <Map<String, dynamic>>[];
      setState(() {
        _accounts = list;
        _selectedAccount = list.isNotEmpty ? list.first : null;
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _accountsLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    // Если поле пустое, ставим 0
    if (text.isEmpty) {
      _amountController.value = const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
      return;
    }
    // Если начинается с 0 и длина > 1, убираем ведущий 0
    if (text.startsWith('0') && text.length > 1 && !text.startsWith('0.')) {
      final newText = text.substring(1);
      _amountController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  String _formatAsPhone(String digits) {
    if (digits.length == 11 && digits.startsWith('7')) {
      final a = digits.substring(1, 4);
      final b = digits.substring(4, 7);
      final c = digits.substring(7, 9);
      final d = digits.substring(9, 11);
      return '+7 $a $b-$c-$d';
    }

    if (digits.length == 10) {
      final a = digits.substring(0, 3);
      final b = digits.substring(3, 6);
      final c = digits.substring(6, 8);
      final d = digits.substring(8, 10);
      return '+7 $a $b-$c-$d';
    }

    return digits;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final a = parts[0].isEmpty ? '' : parts[0][0];
    final b = parts.length < 2 || parts[1].isEmpty ? '' : parts[1][0];
    return (a + b).toUpperCase();
  }

  Future<void> _pickOtherBank() async {
    final bank = await showModalBottomSheet<_BankInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _BanksBottomSheet(allBanks: _allBanks),
    );

    if (!mounted) return;
    if (bank == null) return;
    setState(() {
      _selectedBank = bank;
      if (!_discoveredBanks.contains(bank)) {
        _discoveredBanks.add(bank);
      }
    });
  }

  Future<void> _pay() async {
    final amount = double.tryParse(_amountController.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажи сумму перевода')),
      );
      return;
    }

    final bank = _selectedBank;
    if (bank == null) return;

    if (!bank.isOur) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Перевод в другой банк временно недоступно')),
      );
      return;
    }

    final balance = double.tryParse((_selectedAccount?['balance'] ?? '0').toString()) ?? 0;
    if (balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно средств на счёте')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Перевод выполнен')),
    );

    // Trigger balance update on home screen
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeBalanceUpdated());
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.recipientName;
    final phone = _formatAsPhone(widget.recipientPhoneDigits);
    final initials = _initials(name ?? phone);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Перевод СБП',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/img/logosbp.png',
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _RecipientCard(
                    initials: initials,
                    name: name,
                    phone: phone,
                    isInternal: widget.isInternalRecipient,
                  ),
                  const SizedBox(height: 12),
                  if (_accountsLoading)
                    const SizedBox(
                      height: 96,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_accounts.isNotEmpty)
                    _AccountCarousel(
                      accounts: _accounts,
                      selected: _selectedAccount,
                      onSelect: (acc) => setState(() => _selectedAccount = acc),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'ВЫБОР БАНКА',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                      letterSpacing: 0.60,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BanksRow(
                    banks: _discoveredBanks,
                    selected: _selectedBank,
                    highlightOurBank: widget.isInternalRecipient,
                    onSelect: (b) => setState(() => _selectedBank = b),
                    onPickOtherBank: _pickOtherBank,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'СУММА ПЕРЕВОДА',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.33,
                            letterSpacing: 0.60,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixText: '₽',
                            suffixStyle: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            filled: false, // Убираем заливку
                            isDense: true,
                            contentPadding: EdgeInsets.zero, // Убираем внутренние отступы
                          ),
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Комиссия за перевод 0 ₽. Лимит на месяц: 100 000 ₽',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                border: const Border(top: BorderSide(width: 1, color: Color(0xFFF1F5F9))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC1FF05),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Оплатить',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.56),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCarousel extends StatelessWidget {
  const _AccountCarousel({
    required this.accounts,
    required this.selected,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> accounts;
  final Map<String, dynamic>? selected;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final acc = accounts[index];
          final isSelected = selected?['id'] == acc['id'];
          return _AccountTile(
            account: acc,
            isSelected: isSelected,
            onTap: () => onSelect(acc),
          );
        },
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, dynamic> account;
  final bool isSelected;
  final VoidCallback onTap;

  static String _getAccountName(Map<String, dynamic> account) {
    // Сначала пробуем получить название карты (если это карта)
    final cardName = account['card_name']?.toString();
    if (cardName != null && cardName.isNotEmpty && cardName != 'Основной счёт') {
      return cardName;
    }
    // Пробуем получить тип счета/карты из card_type или account_type
    final cardType = account['card_type']?.toString();
    if (cardType != null && cardType.isNotEmpty) {
      return cardType;
    }
    // Пробуем name если есть
    final name = account['name']?.toString();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    // По умолчанию
    return 'Основной счёт';
  }

  @override
  Widget build(BuildContext context) {
    final balanceStr = account['balance']?.toString() ?? '0';
    final balance = double.tryParse(balanceStr) ?? 0;
    final formattedBalance = balance.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    final accountNumber = account['account_number'] as String? ?? '****';
    final shortNumber = accountNumber.length >= 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC1FF05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFC1FF05) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _AccountTile._getAccountName(account),
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$formattedBalance ₽',
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({
    required this.initials,
    required this.name,
    required this.phone,
    required this.isInternal,
  });

  final String initials;
  final String? name;
  final String phone;
  final bool isInternal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              color: isInternal ? const Color(0xFFC1FF05) : const Color(0xFF9E6FC3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
                if (name != null)
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.43,
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

class _BanksRow extends StatelessWidget {
  const _BanksRow({
    required this.banks,
    required this.selected,
    required this.highlightOurBank,
    required this.onSelect,
    required this.onPickOtherBank,
  });

  final List<_BankInfo> banks;
  final _BankInfo? selected;
  final bool highlightOurBank;
  final ValueChanged<_BankInfo> onSelect;
  final VoidCallback onPickOtherBank;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final b in banks) ...[
            _BankTile(
              bank: b,
              selected: selected?.id == b.id,
              highlightOurBank: highlightOurBank,
              onTap: () => onSelect(b),
            ),
            const SizedBox(width: 12),
          ],
          _OtherBankTile(onTap: onPickOtherBank),
        ],
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  const _BankTile({
    required this.bank,
    required this.selected,
    required this.highlightOurBank,
    required this.onTap,
  });

  final _BankInfo bank;
  final bool selected;
  final bool highlightOurBank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = highlightOurBank && bank.isOur;
    final borderColor = selected
        ? const Color(0xFFC1FF05)
        : isHighlighted
            ? const Color(0xFFC1FF05)
            : const Color(0xFFE5E7EB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: bank.color,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                bank.assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              bank.shortTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: bank.isDarkText ? Colors.black : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherBankTile extends StatelessWidget {
  const _OtherBankTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_rounded, color: Color(0xFF9CA3AF)),
            SizedBox(height: 6),
            Text(
              'Другой\nбанк',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BanksBottomSheet extends StatefulWidget {
  const _BanksBottomSheet({required this.allBanks});

  final List<_BankInfo> allBanks;

  @override
  State<_BanksBottomSheet> createState() => _BanksBottomSheetState();
}

class _BanksBottomSheetState extends State<_BanksBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _controller.text.trim().toLowerCase();
    final banks = q.isEmpty
        ? widget.allBanks
        : widget.allBanks.where((b) => b.title.toLowerCase().contains(q)).toList(growable: false);

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Выбор банка',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Поиск банка',
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: banks.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final b = banks[index];
                return ListTile(
                  onTap: () => Navigator.of(context).pop(b),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      b.assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  title: Text(
                    b.title,
                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BankInfo {
  const _BankInfo({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.color,
    this.isOur = false,
  });

  final String id;
  final String title;
  final String assetPath;
  final Color color;
  final bool isOur;

  bool get isDarkText {
    return id == 'tbank' || id == 'otp';
  }

  String get shortTitle {
    if (id == 'alfa') return 'АЛЬФА';
    if (id == 'tbank') return 'Т-Банк';
    if (id == 'gazprom') return 'ГПБ';
    if (id == 'otp') return 'ОТП';
    return title.toUpperCase();
  }
}
