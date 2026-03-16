import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_round_action_button.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import 'card_details_screen.dart';

class AccountDetailsArgs {
  const AccountDetailsArgs({
    required this.accountId,
    required this.cardId,
    required this.accountTitle,
    required this.balance,
    required this.pan,
    required this.variant,
  });

  final String accountId;
  final String cardId;
  final String accountTitle;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
}

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key, required this.args});

  final AccountDetailsArgs args;

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final _api = ApiClient();
  bool _loadingCards = true;
  List<_AccountCardItemData> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    print('[DEBUG] _loadCards() called for accountId: ${widget.args.accountId}');
    try {
      // Загружаем все карты пользователя
      print('[DEBUG] Fetching /cards...');
      final res = await _api.dio.get('/cards');
      print('[DEBUG] /cards response: ${res.data}');
      final data = res.data;
      
      final List<_AccountCardItemData> cards = [];
      if (data is Map && data['items'] is List) {
        for (final c in (data['items'] as List)) {
          if (c is! Map) continue;
          final accountId = c['accountId']?.toString();
          print('[DEBUG] Checking card accountId: $accountId vs widget: ${widget.args.accountId}');
          // Фильтруем только карты этого счёта
          if (accountId != widget.args.accountId) continue;
          
          final id = c['id']?.toString();
          final cardTypeName = c['cardTypeName']?.toString() ?? c['card_type_name']?.toString();
          final title = cardTypeName ?? widget.args.accountTitle;
          final balance = c['balance']?.toString() ?? '0';
          final masked = c['maskedCardNumber']?.toString() ?? '****';
          final productType = c['productType']?.toString() ?? 'debit';
          final isMain = c['isMain'] == true || c['is_main'] == true;
          
          if (id == null) continue;

          final variant = (productType == 'credit' || productType == 'credit_card')
              ? OtpBankCardVariant.purple
              : (productType == 'travel' ? OtpBankCardVariant.orange : OtpBankCardVariant.dark);

          cards.add(_AccountCardItemData(
            cardId: id,
            title: title,
            cardTypeName: cardTypeName ?? '',
            balance: '$balance ${widget.args.balance.split(' ').last}',
            pan: () {
              final digits = masked.replaceAll(RegExp(r'[^0-9]'), '');
              final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
              return last4.isEmpty ? '****' : '**** $last4';
            }(),
            variant: variant,
            isDefault: isMain,
          ));
          print('[DEBUG] Added card: $id, isMain: $isMain');
        }
      }

      print('[DEBUG] Total cards found: ${cards.length}');

      // Если карт нет, добавляем placeholder из args
      if (cards.isEmpty) {
        print('[DEBUG] No cards found, adding placeholder');
        cards.add(_AccountCardItemData(
          cardId: widget.args.cardId.isNotEmpty ? widget.args.cardId : 'placeholder-${widget.args.accountId}',
          title: widget.args.accountTitle,
          cardTypeName: '',
          balance: widget.args.balance,
          pan: widget.args.pan,
          variant: widget.args.variant,
          isDefault: true,
        ));
      }

      setState(() {
        _cards = cards;
        _loadingCards = false;
      });
    } catch (e, stack) {
      print('[DEBUG] Error loading cards: $e');
      print('[DEBUG] Stack: $stack');
      setState(() {
        // В случае ошибки показываем хотя бы одну карту из args
        _cards = [
          _AccountCardItemData(
            cardId: widget.args.cardId.isNotEmpty ? widget.args.cardId : 'placeholder-${widget.args.accountId}',
            title: widget.args.accountTitle,
            cardTypeName: '',
            balance: widget.args.balance,
            pan: widget.args.pan,
            variant: widget.args.variant,
            isDefault: true,
          )
        ];
        _loadingCards = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          OtpUniversalAppBar(title: 'Счёт'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.accountTitle,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Доступный остаток',
                  style: TextStyle(
                    color: const Color(0xFF64748B).withOpacity(0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.args.balance,
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
          ),
          const SizedBox(height: 16),
          if (_loadingCards)
            const SizedBox(
              height: 184,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 184,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OtpBankCard(
                        title: card.title,
                        amount: card.balance,
                        pan: card.pan,
                        variant: card.variant,
                        onTap: () {
                          // Do not open details for placeholder cards
                          if (card.cardId.startsWith('placeholder-')) return;

                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CardDetailsScreen(
                                args: CardDetailsArgs(
                                  cardId: card.cardId,
                                  cardTitle: card.title,
                                  cardTypeName: card.cardTypeName,
                                  accountTitle: widget.args.accountTitle,
                                  balance: card.balance,
                                  pan: card.pan,
                                  variant: card.variant,
                                  validThru: '12/28',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      if (card.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'Основная',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: _cards.length,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Перевести',
                    icon: Icons.swap_horiz_rounded,
                    style: OtpRoundActionStyle.primary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Пополнить',
                    icon: Icons.add_rounded,
                    style: OtpRoundActionStyle.secondary,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Реквизиты',
                    icon: Icons.receipt_long_rounded,
                    style: OtpRoundActionStyle.secondary,
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (_) => _AccountRequisitesSheet(accountId: widget.args.accountId),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OtpRoundActionButton(
                    label: 'Лимиты',
                    icon: Icons.tune_rounded,
                    style: OtpRoundActionStyle.secondary,
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (_) => _AccountLimitsSheet(accountTitle: widget.args.accountTitle),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SpendingAnalyticsSection(accountId: widget.args.accountId),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionHeader(
              title: 'История операций',
              actionLabel: 'Все',
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: _TransactionsPreview(accountId: widget.args.accountId),
          ),
        ],
      ),
    );
  }
}

class _AccountRequisitesSheet extends StatefulWidget {
  const _AccountRequisitesSheet({required this.accountId});

  final String accountId;

  @override
  State<_AccountRequisitesSheet> createState() => _AccountRequisitesSheetState();
}

class _AccountRequisitesSheetState extends State<_AccountRequisitesSheet> {
  final Set<String> _copiedKeys = <String>{};

  Future<Map<String, dynamic>> _load() async {
    final api = ApiClient();
    final res = await api.dio.get('/accounts/${widget.accountId}');
    final data = res.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  void _toast(String text) {
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

  Future<void> _copy(String key, String title, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() => _copiedKeys.add(key));
    _toast('Скопировано: $title');
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _copiedKeys.remove(key));
    });
  }

  Widget _row(String key, String title, String value) {
    final copied = _copiedKeys.contains(key);
    return InkWell(
      onTap: () => _copy(key, title, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 18,
              color: copied ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _load(),
          builder: (context, snap) {
            final data = snap.data ?? const <String, dynamic>{};
            final req = (data['requisites'] is Map) ? (data['requisites'] as Map) : const {};
            final bankName = (req['bankName'] ?? '').toString().trim();
            final bic = (req['bic'] ?? '').toString().trim();
            final accountNumber = (req['accountNumber'] ?? '').toString().trim();
            final corrAccount = (req['corrAccount'] ?? '').toString().trim();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Реквизиты счёта',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
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
                const SizedBox(height: 6),
                const Text(
                  'Нажми на строку, чтобы скопировать',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
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
                      if (bankName.isNotEmpty) _row('bank', 'Банк', bankName),
                      if (bic.isNotEmpty) _row('bic', 'БИК', bic),
                      if (corrAccount.isNotEmpty) _row('corr', 'Корр. счёт', corrAccount),
                      if (accountNumber.isNotEmpty) _row('acc', 'Счёт', accountNumber),
                      if (bankName.isEmpty && bic.isEmpty && corrAccount.isEmpty && accountNumber.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Реквизиты недоступны',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountLimitsSheet extends StatelessWidget {
  const _AccountLimitsSheet({required this.accountTitle});

  final String accountTitle;

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Лимиты — $accountTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
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
              'Текущие лимиты для этого счёта.',
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
                  row('На одну операцию', 'Без лимита'),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  row('В день', 'Без лимита'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingAnalyticsSection extends StatelessWidget {
  const _SpendingAnalyticsSection({required this.accountId});

  final String accountId;

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
          'accountId': accountId,
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
                  .map(
                    (v) => maxVal <= 0
                        ? 0.0
                        : ((v / maxVal).clamp(0.0, 1.0) as num).toDouble(),
                  )
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

class _AccountCardItemData {
  const _AccountCardItemData({
    required this.cardId,
    required this.title,
    required this.cardTypeName,
    required this.balance,
    required this.pan,
    required this.variant,
    required this.isDefault,
  });

  final String cardId;
  final String title;
  final String cardTypeName;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
  final bool isDefault;
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
          color: const Color(0xFFF1F5F9),
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
                  fontWeight: FontWeight.w700,
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
  const _TransactionsPreview({required this.accountId});

  final String accountId;

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
          'accountId': accountId,
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
              'Операций пока нет',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
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
