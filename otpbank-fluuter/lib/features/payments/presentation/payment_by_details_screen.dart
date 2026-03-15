import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/network/api_client.dart';

class PaymentByDetailsScreen extends StatefulWidget {
  const PaymentByDetailsScreen({super.key});

  @override
  State<PaymentByDetailsScreen> createState() => _PaymentByDetailsScreenState();
}

class _PaymentByDetailsScreenState extends State<PaymentByDetailsScreen> {
  final _recipientController = TextEditingController();
  final _innController = TextEditingController();
  final _kppController = TextEditingController();
  final _accountController = TextEditingController();
  final _bankController = TextEditingController();
  final _bikController = TextEditingController();
  final _correspondentAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _api = ApiClient();

  // Счёта
  List<Map<String, dynamic>> _accounts = [];
  Map<String, dynamic>? _selectedAccount;
  bool _accountsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
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
    _recipientController.dispose();
    _innController.dispose();
    _kppController.dispose();
    _accountController.dispose();
    _bankController.dispose();
    _bikController.dispose();
    _correspondentAccountController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // TODO: Validate and proceed to confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переход к подтверждению платежа')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            OtpUniversalAppBar(
              title: 'По реквизитам',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source account carousel
                    _buildSectionTitle('СПИСАТЬ СО СЧЁТА'),
                    const SizedBox(height: 8),
                    if (_accountsLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_accounts.isNotEmpty)
                      _buildAccountCarousel()
                    else
                      const Text(
                        'Нет доступных счетов',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    const SizedBox(height: 20),

                    // Recipient details
                    _buildSectionTitle('Получатель'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _recipientController,
                      hint: 'Название организации или ФИО',
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _innController,
                            hint: 'ИНН',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _kppController,
                            hint: 'КПП',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Account details
                    _buildSectionTitle('Банк получателя'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _bankController,
                      hint: 'Наименование банка',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _bikController,
                      hint: 'БИК',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _accountController,
                      hint: 'Расчётный счёт',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _correspondentAccountController,
                      hint: 'Корреспондентский счёт',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amount card with shadow
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
                            'СУММА И НАЗНАЧЕНИЕ',
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffixText: '₽',
                              suffixStyle: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _purposeController,
                            hint: 'Назначение платежа',
                            icon: Icons.edit_note_rounded,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC4FF2E),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0.60,
      ),
    );
  }

  Widget _buildAccountCarousel() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final acc = _accounts[index];
          final isSelected = _selectedAccount?['id'] == acc['id'];
          return _AccountTile(
            account: acc,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedAccount = acc),
          );
        },
      ),
    );
  }

  Widget _buildAccountSelector() {
    return InkWell(
      onTap: () {
        // TODO: Show account selector
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Основной счёт',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '•••• 1234',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefix,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF64748B), size: 20)
            : prefix,
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
          borderSide: const BorderSide(color: Color(0xFFC4FF2E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
