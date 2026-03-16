import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_large_bank_card.dart';
import '../../../core/widgets/otp_square_action_button.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class CardDetailsArgs {
  const CardDetailsArgs({
    required this.cardId,
    required this.cardTitle,
    required this.cardTypeName,
    required this.accountTitle,
    required this.balance,
    required this.pan,
    required this.variant,
    this.validThru,
    this.openLimitsOnStart = false,
  });

  final String cardId;
  final String cardTitle;
  final String cardTypeName;
  final String accountTitle;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
  final String? validThru;
  final bool openLimitsOnStart;
}

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({super.key, required this.args});

  final CardDetailsArgs args;

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final _api = ApiClient();
  bool _loading = false;
  String? _status;
  String? _limitPerTx;
  String? _limitPerDay;
  bool _showRequisitesBack = false;
  final Set<String> _copiedKeys = <String>{};
  bool? _notificationsEnabled;
  String? _cvc;
  bool _requisitesLoading = false;
  String? _fullMaskedPan;
  String? _validThru;

  static String _requisiteValue(String s) {
    final v = s.trim();
    return v.isEmpty ? '—' : v;
  }

  static String _copyValue(String s) {
    final v = s.trim();
    return v.isEmpty ? '—' : v;
  }

  void _toggleRequisites() {
    _toggleRequisitesAsync();
  }

  Future<void> _toggleRequisitesAsync() async {
    if (_requisitesLoading) return;

    if (_showRequisitesBack) {
      setState(() {
        _showRequisitesBack = false;
        _copiedKeys.clear();
      });
      return;
    }

    setState(() => _requisitesLoading = true);
    try {
      // Fetch full card details to get validThru and CVC
      final cardRes = await _api.dio.get('/cards/${widget.args.cardId}');
      final cardData = cardRes.data;
      final reqRes = await _api.dio.get('/cards/${widget.args.cardId}/requisites');
      final reqData = reqRes.data;
      if (!mounted) return;
      if (cardData is Map && reqData is Map) {
        final cvc = reqData['cvc']?.toString();
        final fullPan = reqData['fullPan']?.toString() ?? reqData['full_pan']?.toString();
        final validThru = cardData['validThru']?.toString() ?? cardData['valid_thru']?.toString();
        final masked = cardData['maskedCardNumber']?.toString() ?? cardData['masked_card_number']?.toString() ?? widget.args.pan;
        setState(() {
          _cvc = (cvc == null || cvc.trim().isEmpty) ? null : cvc.trim();
          _fullMaskedPan = (fullPan == null || fullPan.trim().isEmpty) ? masked : fullPan.trim();
          _validThru = (validThru == null || validThru.trim().isEmpty) ? null : validThru.trim();
          _showRequisitesBack = true;
        });
      } else {
        _showToast('Не удалось получить реквизиты');
      }
    } catch (_) {
      if (!mounted) return;
      _showToast('Не удалось получить реквизиты');
    } finally {
      if (mounted) setState(() => _requisitesLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _status = null;
    _load();
    _loadNotificationsPref();

    if (widget.args.openLimitsOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showLimits();
      });
    }
  }

  void _showToast(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String get _notificationsPrefKey => 'card_tx_notifications_${widget.args.cardId}';

  Future<void> _loadNotificationsPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(_notificationsPrefKey);
      if (!mounted) return;
      setState(() => _notificationsEnabled = value ?? true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _notificationsEnabled = true);
    }
  }

  Future<void> _openNotifications() async {
    if (_loading) return;

    final prefs = await SharedPreferences.getInstance();
    final initialValue = _notificationsEnabled ?? prefs.getBool(_notificationsPrefKey) ?? true;
    if (!mounted) return;

    var value = initialValue;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Уведомления об операциях',
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
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Показывать уведомления о покупках и списаниях по карте.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SwitchListTile(
                      value: value,
                      onChanged: (v) {
                        value = v;
                        setLocal(() {});
                      },
                      title: const Text(
                        'Уведомления',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      activeColor: const Color(0xFF9E6FC3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(value),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC1FF05),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == null) return;
    await prefs.setBool(_notificationsPrefKey, result);
    if (!mounted) return;
    setState(() => _notificationsEnabled = result);
    _showToast(result ? 'Уведомления включены' : 'Уведомления выключены');
  }

  Future<void> _copyWithFeedback({
    required String key,
    required String title,
    required String value,
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() => _copiedKeys.add(key));
    _showToast('Скопировано: $title');
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _copiedKeys.remove(key));
    });
  }

  Future<void> _load() async {
    try {
      final res = await _api.dio.get('/cards/${widget.args.cardId}');
      final data = res.data;
      if (!mounted) return;
      if (data is Map) {
        final limits = data['limits'];
        setState(() {
          _status = data['status']?.toString();
          if (limits is Map) {
            _limitPerTx = limits['perTransaction']?.toString();
            _limitPerDay = limits['perDay']?.toString();
          }
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _toggleFreeze() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final isFrozen = (_status ?? '') == 'frozen';
      final path = isFrozen ? '/cards/${widget.args.cardId}/unfreeze' : '/cards/${widget.args.cardId}/freeze';
      final res = await _api.dio.post(path);
      final data = res.data;
      if (mounted && data is Map) {
        setState(() => _status = data['status']?.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBlock() async {
    if (_loading) return;

    final isBlocked = (_status ?? '') == 'blocked';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isBlocked ? 'Разблокировать карту?' : 'Заблокировать карту?',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isBlocked
                    ? 'Карта снова станет доступна для операций.'
                    : 'Операции по карте будут недоступны до разблокировки.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Отмена', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC1FF05),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isBlocked ? 'Разблокировать' : 'Заблокировать',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      final path = isBlocked ? '/cards/${widget.args.cardId}/unblock' : '/cards/${widget.args.cardId}/block';
      final res = await _api.dio.post(path);
      final data = res.data;
      if (mounted && data is Map) {
        setState(() => _status = data['status']?.toString());
      }
      if (!mounted) return;
      _showToast(isBlocked ? 'Карта разблокирована' : 'Карта заблокирована');
    } catch (_) {
      if (!mounted) return;
      _showToast('Не удалось изменить статус карты');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePin() async {
    if (_loading) return;

    final controller = TextEditingController();
    final pin = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              final raw = controller.text.trim();
              final isValid = RegExp(r'^\d{4}$').hasMatch(raw);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Смена ПИН-кода',
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
                  const SizedBox(height: 6),
                  const Text(
                    'Введите 4 цифры. Мы не показываем ПИН на экране.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    onChanged: (_) => setLocal(() {}),
                    decoration: InputDecoration(
                      hintText: '••••',
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValid ? () => Navigator.of(context).pop(raw) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC1FF05),
                        foregroundColor: const Color(0xFF0F172A),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (pin == null || pin.isEmpty) return;

    setState(() => _loading = true);
    try {
      await _api.dio.post('/cards/${widget.args.cardId}/pin', data: {'pin': pin});
      if (!mounted) return;
      _showToast('ПИН-код обновлён');
    } catch (_) {
      if (!mounted) return;
      _showToast('Не удалось обновить ПИН-код');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _digitsOnly(String s) {
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _editLimits() async {
    if (_loading) return;

    final perTxController = TextEditingController(text: _limitPerTx ?? '');
    final perDayController = TextEditingController(text: _limitPerDay ?? '');

    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              final perTxRaw = _digitsOnly(perTxController.text.trim());
              final perDayRaw = _digitsOnly(perDayController.text.trim());
              final perTx = perTxRaw.isEmpty ? null : double.tryParse(perTxRaw);
              final perDay = perDayRaw.isEmpty ? null : double.tryParse(perDayRaw);
              final ok = (perTx == null || perTx >= 0) && (perDay == null || perDay >= 0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Лимиты трат',
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
                  const SizedBox(height: 6),
                  const Text(
                    'Оставь поле пустым, чтобы лимит не применялся.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: perTxController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setLocal(() {}),
                    decoration: InputDecoration(
                      labelText: 'На одну операцию (₽)',
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: perDayController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setLocal(() {}),
                    decoration: InputDecoration(
                      labelText: 'В день (₽)',
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ok
                          ? () {
                              Navigator.of(context).pop({
                                'perTransaction': perTxRaw.isEmpty ? null : perTxRaw,
                                'perDay': perDayRaw.isEmpty ? null : perDayRaw,
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC1FF05),
                        foregroundColor: const Color(0xFF0F172A),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == null) return;

    setState(() => _loading = true);
    try {
      final res = await _api.dio.post('/cards/${widget.args.cardId}/limits', data: result);
      final data = res.data;
      if (mounted && data is Map) {
        final limits = data['limits'];
        setState(() {
          if (limits is Map) {
            _limitPerTx = limits['perTransaction']?.toString();
            _limitPerDay = limits['perDay']?.toString();
          }
        });
      }
      if (!mounted) return;
      _showToast('Лимиты обновлены');
    } catch (_) {
      if (!mounted) return;
      _showToast('Не удалось обновить лимиты');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showLimits() async {
    if (_loading) return;

    final perTx = _limitPerTx;
    final perDay = _limitPerDay;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Widget row(String title, String value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        }

        String fmtRub(String? v) {
          final raw = (v ?? '').trim();
          if (raw.isEmpty) return 'Без лимита';
          return '$raw ₽';
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Лимиты',
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
              const SizedBox(height: 6),
              const Text(
                'Текущие лимиты для этой карты.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    row('На одну операцию', fmtRub(perTx)),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                    row('В день', fmtRub(perDay)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editLimits();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC1FF05),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Изменить', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Gradient _cardGradient() {
    return switch (widget.args.variant) {
      OtpBankCardVariant.dark => const LinearGradient(
        begin: Alignment(0.22, -0.22),
        end: Alignment(0.78, 1.22),
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ),
      OtpBankCardVariant.purple => const LinearGradient(
        begin: Alignment(0.22, -0.22),
        end: Alignment(0.78, 1.22),
        colors: [Color(0xFF9E6FC3), Color(0xFF4F46E5)],
      ),
      OtpBankCardVariant.orange => const LinearGradient(
        begin: Alignment(0.22, -0.22),
        end: Alignment(0.78, 1.22),
        colors: [Color(0xFFFF7D32), Color(0xFF9E6FC3)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final isFrozen = (_status ?? '') == 'frozen';
    final isBlocked = (_status ?? '') == 'blocked';

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          OtpUniversalAppBar(title: args.cardTypeName.isNotEmpty ? args.cardTypeName : args.cardTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeInOutCubic,
                  tween: Tween<double>(begin: 0, end: _showRequisitesBack ? 1 : 0),
                  builder: (context, v, _) {
                    final angle = 3.1415926535 * v;
                    final isBack = v >= 0.5;

                    final m = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle);

                    return Transform(
                      transform: m,
                      alignment: Alignment.center,
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          IgnorePointer(
                            ignoring: isBack,
                            child: Opacity(
                              opacity: isBack ? 0 : 1,
                              child: OtpLargeBankCard(
                                title: args.cardTitle,
                                subtitle: 'Можно оплатить приложив',
                                variant: args.variant,
                                pan: args.pan,
                                validThru: args.validThru ?? '—',
                              ),
                            ),
                          ),
                          IgnorePointer(
                            ignoring: !isBack,
                            child: Opacity(
                              opacity: isBack ? 1 : 0,
                              child: Transform(
                                transform: Matrix4.identity()..rotateY(3.1415926535),
                                alignment: Alignment.center,
                                child: _CardRequisitesBack(
                                  pan: _fullMaskedPan ?? args.pan,
                                  validThru: _validThru ?? args.validThru ?? '—',
                                  cvc: _cvc,
                                  variant: args.variant,
                                  copiedKeys: _copiedKeys,
                                  onCopy: _copyWithFeedback,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    const Text(
                      'Доступный остаток',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      args.balance,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _CardActionsRow(
                  frozen: isFrozen,
                  blocked: isBlocked,
                  loading: _loading || _requisitesLoading,
                  onFreezeToggle: _toggleFreeze,
                  requisitesOpened: _showRequisitesBack,
                  onRequisitesTap: _toggleRequisites,
                  onLimitsTap: _showLimits,
                ),
                const SizedBox(height: 28),
                _SpendingAnalyticsSection(cardId: args.cardId),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'История операций',
                  actionLabel: 'Все',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _TransactionsPreview(cardId: args.cardId),
                const SizedBox(height: 28),
                const Text(
                  'Настройки карты',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsGroup(
                  items: [
                    _SettingsItemData(
                      icon: Icons.pin_rounded,
                      iconBg: const Color(0x33C8E1FC),
                      title: 'Изменить ПИН-код',
                      onTap: _loading ? null : _changePin,
                    ),
                    _SettingsItemData(
                      icon: Icons.notifications_active_rounded,
                      iconBg: const Color(0x339E6FC3),
                      title: 'Уведомления об операциях',
                      onTap: _openNotifications,
                    ),
                    _SettingsItemData(
                      icon: isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                      iconBg: const Color(0x33FF7D32),
                      title: isBlocked ? 'Разблокировать карту' : 'Заблокировать карту',
                      onTap: _loading ? null : _toggleBlock,
                    ),
                    _SettingsItemData(
                      icon: Icons.tune_rounded,
                      iconBg: const Color(0x33C1FF05),
                      title: 'Настроить лимиты трат',
                      onTap: _loading ? null : _editLimits,
                    ),
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

class _CardActionsRow extends StatelessWidget {
  const _CardActionsRow({
    required this.frozen,
    required this.blocked,
    required this.loading,
    required this.onFreezeToggle,
    required this.requisitesOpened,
    required this.onRequisitesTap,
    required this.onLimitsTap,
  });

  final bool frozen;
  final bool blocked;
  final bool loading;
  final VoidCallback onFreezeToggle;
  final bool requisitesOpened;
  final VoidCallback onRequisitesTap;
  final VoidCallback onLimitsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OtpSquareActionButton(
            label: frozen ? 'Разморозить' : 'Заморозить',
            icon: frozen ? Icons.play_circle_fill_rounded : Icons.ac_unit_rounded,
            disabled: loading || blocked,
            onTap: onFreezeToggle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: OtpSquareActionButton(
            label: 'Реквизиты',
            icon: requisitesOpened ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            disabled: loading,
            onTap: onRequisitesTap,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: OtpSquareActionButton(
            label: 'Лимиты',
            icon: Icons.tune_rounded,
            disabled: loading,
            onTap: onLimitsTap,
          ),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: OtpSquareActionButton(
            label: 'Перевести',
            icon: Icons.swap_horiz_rounded,
            primary: true,
          ),
        ),
      ],
    );
  }
}

class _CardRequisitesBack extends StatelessWidget {
  const _CardRequisitesBack({
    super.key,
    required this.pan,
    required this.validThru,
    this.cvc,
    required this.variant,
    required this.copiedKeys,
    required this.onCopy,
  });

  final String pan;
  final String validThru;
  final String? cvc;
  final OtpBankCardVariant variant;
  final Set<String> copiedKeys;
  final Future<void> Function({required String key, required String title, required String value}) onCopy;

  Gradient get _gradient {
    return switch (variant) {
      OtpBankCardVariant.dark => const LinearGradient(
        begin: Alignment(0.22, -0.22),
        end: Alignment(0.78, 1.22),
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ),
      OtpBankCardVariant.purple => const LinearGradient(
        begin: Alignment(0.22, -0.22),
        end: Alignment(0.78, 1.22),
        colors: [Color(0xFF9E6FC3), Color(0xFF4F46E5)],
      ),
      OtpBankCardVariant.orange => const LinearGradient(
        begin: Alignment(0.22, -0.22),
        end: Alignment(0.78, 1.22),
        colors: [Color(0xFFFF7D32), Color(0xFF9E6FC3)],
      ),
    };
  }

  Widget _copyRow({
    required BuildContext context,
    required String key,
    required String label,
    required String value,
  }) {
    final copied = copiedKeys.contains(key);
    return InkWell(
      onTap: () => onCopy(key: key, title: label, value: value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Icon(copied ? Icons.check_rounded : Icons.copy_rounded, color: copied ? const Color(0xFFC1FF05) : Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safePan = _CardDetailsScreenState._requisiteValue(pan);
    final safeValidThru = _CardDetailsScreenState._requisiteValue(validThru);
    final safeCvc = cvc == null ? null : _CardDetailsScreenState._requisiteValue(cvc!);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 50,
              offset: Offset(0, 25),
              spreadRadius: -12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _gradient),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 14),
                    _copyRow(context: context, key: 'pan', label: 'Номер карты', value: safePan),
                    const SizedBox(height: 6),
                    if (safeCvc == null)
                      _copyRow(
                        context: context,
                        key: 'validThru',
                        label: 'VALID THRU',
                        value: safeValidThru,
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _copyRow(
                              context: context,
                              key: 'validThru',
                              label: 'VALID THRU',
                              value: safeValidThru,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _copyRow(
                              context: context,
                              key: 'cvc',
                              label: 'CVC',
                              value: safeCvc,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.showDivider});

  final _SettingsItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: item.iconBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  child: Icon(item.icon, size: 20, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final VoidCallback? onTap;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SettingsRow(item: items[i], showDivider: i != items.length - 1),
          ],
        ],
      ),
    );
  }
}

class _SpendingAnalyticsSection extends StatelessWidget {
  const _SpendingAnalyticsSection({required this.cardId});

  final String cardId;

  static String _monthTitle(DateTime now) {
    const months = <String>[
      'ЯНВАРЬ',
      'ФЕВРАЛЬ',
      'МАРТ',
      'АПРЕЛЬ',
      'МАЙ',
      'ИЮНЬ',
      'ИЮЛЬ',
      'АВГУСТ',
      'СЕНТЯБРЬ',
      'ОКТЯБРЬ',
      'НОЯБРЬ',
      'ДЕКАБРЬ',
    ];
    return months[now.month - 1];
  }

  static String _fmtIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static double _safeDouble(dynamic v) {
    if (v == null) return 0;
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    Future<List<Map<String, dynamic>>> load() async {
      final res = await api.dio.get(
        '/transactions',
        queryParameters: {
          'cardId': cardId,
          'from': _fmtIso(from),
          'to': _fmtIso(to),
          'limit': 100,
          'offset': 0,
        },
      );
      final data = res.data;
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }
      return const [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Аналитика трат',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
            Text(
              _monthTitle(now),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: ShapeDecoration(
            color: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: load(),
            builder: (context, snap) {
              final items = snap.data ?? const [];
              final buckets = <String, double>{};
              for (int i = 5; i >= 0; i--) {
                final d = now.subtract(Duration(days: i));
                final key = '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
                buckets[key] = 0;
              }

              for (final t in items) {
                final type = (t['type'] ?? '').toString();
                if (type != 'expense') continue;
                final date = DateTime.tryParse((t['date'] ?? '').toString());
                if (date == null) continue;
                final key = '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
                if (!buckets.containsKey(key)) continue;
                buckets[key] = (buckets[key] ?? 0) + _safeDouble(t['amount']);
              }

              final values = buckets.values.toList(growable: false);
              final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
              final fractions = values
                  .map((v) => maxVal <= 0 ? 0.0 : ((v / maxVal).clamp(0.0, 1.0) as num).toDouble())
                  .toList(growable: false);
              final labels = buckets.keys.toList(growable: false);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 128,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < fractions.length; i++) ...[
                              Expanded(
                                child: _AnalyticsBar(
                                  fraction: fractions[i],
                                  highlighted: i == fractions.length - 2,
                                  tooltipLabel: null,
                                ),
                              ),
                              if (i != fractions.length - 1) const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final l in labels)
                        Text(
                          l,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                            letterSpacing: 0.50,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalyticsBar extends StatelessWidget {
  const _AnalyticsBar({
    required this.fraction,
    required this.highlighted,
    this.tooltipLabel,
  });

  final double fraction;
  final bool highlighted;
  final String? tooltipLabel;

  @override
  Widget build(BuildContext context) {
    final barColor = highlighted ? const Color(0xFFC1FF05) : const Color(0x4CC8E1FC);

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight * fraction;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: h,
                decoration: ShapeDecoration(
                  color: barColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
              if (tooltipLabel != null)
                Positioned(
                  top: -32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      tooltipLabel!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
        Material(
          color: const Color(0x19C1FF05),
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionsPreview extends StatelessWidget {
  const _TransactionsPreview({required this.cardId});

  final String cardId;

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _fmtDateTime(DateTime d) {
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day;
    final hhmm = '${_two(d.hour)}:${_two(d.minute)}';
    if (isToday) return 'Сегодня • $hhmm';
    if (isYesterday) return 'Вчера • $hhmm';
    return '${_two(d.day)}.${_two(d.month)} • $hhmm';
  }

  static String _fmtAmount(String type, String raw, String currency) {
    final v = double.tryParse(raw) ?? 0;
    final sign = type == 'income' ? '+' : '-';
    final abs = v.abs().toStringAsFixed(0);
    return '$sign $abs $currency';
  }

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();

    Future<List<Map<String, dynamic>>> load() async {
      final res = await api.dio.get(
        '/transactions',
        queryParameters: {
          'cardId': cardId,
          'limit': 3,
          'offset': 0,
        },
      );
      final data = res.data;
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }
      return const [];
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: load(),
      builder: (context, snap) {
        final items = snap.data ?? const [];
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Операций по карте пока нет',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _TransactionRow(
                  title: (items[i]['merchantName'] ?? items[i]['category'] ?? 'Операция').toString(),
                  subtitle: () {
                    final d = DateTime.tryParse((items[i]['date'] ?? '').toString());
                    return d == null ? '' : _fmtDateTime(d);
                  }(),
                  amount: _fmtAmount(
                    (items[i]['type'] ?? '').toString(),
                    (items[i]['amount'] ?? '0').toString(),
                    (items[i]['currency'] ?? '₽').toString(),
                  ),
                  positive: (items[i]['type'] ?? '').toString() == 'income',
                ),
                if (i != items.length - 1) const _Divider(),
              ]
            ],
          ),
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.positive = false,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final amountColor = positive ? const Color(0xFF16A34A) : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 20, color: Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}