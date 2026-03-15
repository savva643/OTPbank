import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/network/api_client.dart';

class PaymentByCardScreen extends StatefulWidget {
  const PaymentByCardScreen({super.key});

  @override
  State<PaymentByCardScreen> createState() => _PaymentByCardScreenState();
}

class _PaymentByCardScreenState extends State<PaymentByCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  final _api = ApiClient();

  // Счёта
  List<Map<String, dynamic>> _accounts = [];
  Map<String, dynamic>? _selectedAccount;
  bool _accountsLoading = false;

  bool _saveCard = false;

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
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _recipientNameController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_cardNumberController.text.length < 16 ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все обязательные поля')),
      );
      return;
    }
    // TODO: Proceed to confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переход к подтверждению перевода')),
    );
  }

  String _formatCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            OtpUniversalAppBar(
              title: 'По карте',
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
                    const SizedBox(height: 24),

                    // Recipient card
                    _buildSectionTitle('Карта получателя'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cardNumberController,
                      hint: 'Номер карты',
                      icon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(19),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = _formatCardNumber(newValue.text);
                          return TextEditingValue(
                            text: text,
                            selection: TextSelection.collapsed(offset: text.length),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _expiryController,
                            hint: 'ММ/ГГ',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                final text = newValue.text;
                                if (text.length >= 2) {
                                  final month = text.substring(0, 2);
                                  final year = text.length > 2 ? text.substring(2) : '';
                                  final formatted = '$month/${year}';
                                  return TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length),
                                  );
                                }
                                return newValue;
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cvcController,
                            hint: 'CVC',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _recipientNameController,
                      hint: 'Имя и фамилия получателя (опционально)',
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 24),

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
                          _buildQuickAmounts(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Message
                    _buildTextField(
                      controller: _messageController,
                      hint: 'Сообщение получателю (опционально)',
                      icon: Icons.message_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Save card checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _saveCard,
                          onChanged: (value) {
                            setState(() {
                              _saveCard = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFFC4FF2E),
                          checkColor: const Color(0xFF0F172A),
                        ),
                        const Expanded(
                          child: Text(
                            'Сохранить карту для будущих переводов',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Saved cards section
                    _buildSectionTitle('Сохранённые карты'),
                    const SizedBox(height: 12),
                    _buildSavedCard('4276  12**  ****  4582', 'Михаил Иванов'),
                    _buildSavedCard('2202  20**  ****  1199', 'Анна Петрова'),
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
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      obscureText: obscureText,
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

  Widget _buildQuickAmounts() {
    final amounts = ['500', '1000', '2000', '5000', '10000'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((amount) {
        return InkWell(
          onTap: () {
            _amountController.text = amount;
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSavedCard(String cardNumber, String name) {
    return InkWell(
      onTap: () {
        _cardNumberController.text = cardNumber.replaceAll(' ', '');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardNumber,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
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
