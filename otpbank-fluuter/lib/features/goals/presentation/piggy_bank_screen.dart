import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class PiggyBankScreen extends StatefulWidget {
  const PiggyBankScreen({super.key});

  @override
  State<PiggyBankScreen> createState() => _PiggyBankScreenState();
}

class _PiggyBankScreenState extends State<PiggyBankScreen> {
  final _api = ApiClient();
  bool _loading = true;
  List<_PiggyGoal> _goals = const [];

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/goals');
      final data = res.data;
      final list = <_PiggyGoal>[];
      if (data is Map && data['items'] is List) {
        for (final g in (data['items'] as List)) {
          if (g is! Map) continue;
          list.add(_PiggyGoal.fromJson(g));
        }
      }

      if (!mounted) return;
      setState(() => _goals = list);
    } catch (_) {
      if (!mounted) return;
      _toast('Не удалось загрузить цели');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _goalsCount => _goals.length;

  int get _totalSavedRub {
    var sum = 0;
    for (final g in _goals) {
      if (g.currency.toUpperCase() == 'RUB') sum += g.savedAmount;
    }
    return sum;
  }

  void _openCreateGoal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CreateGoalSheet(
          onCreated: () => _load(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFF9E6FC3),
            onRefresh: _load,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                const OtpUniversalAppBar(title: 'Копилка'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFC4FF2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Opacity(
                              opacity: 0.80,
                              child: Text(
                                'Всего накоплено',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_totalSavedRub.toString()} ₽',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                if (_loading)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: ShapeDecoration(
                                color: Colors.white.withOpacity(0.30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                              ),
                              child: Text(
                                '$_goalsCount ЦЕЛЕЙ',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Копилка — это цели и накопления. Накопительный счёт — банковский счёт с процентами.',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Мои цели',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(width: 1),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!_loading && _goals.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Целей пока нет. Создайте первую копилку.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      for (final g in _goals) ...[
                        _GoalCard(goal: g),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 8),
                      _PrimaryCtaButton(
                        label: _goals.isEmpty ? 'Создать первую цель' : 'Создать цель',
                        onTap: _openCreateGoal,
                      ),
                    ],
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

class _PiggyGoal {
  _PiggyGoal({
    required this.id,
    required this.name,
    required this.iconId,
    required this.targetAmount,
    required this.savedAmount,
    required this.currency,
    required this.progressPercent,
  });

  final String id;
  final String name;
  final String iconId;
  final int targetAmount;
  final int savedAmount;
  final String currency;
  final int progressPercent;

  factory _PiggyGoal.fromJson(Map data) {
    final saved = (double.tryParse(data['savedAmount']?.toString() ?? '') ?? 0).round();
    final target = (double.tryParse(data['targetAmount']?.toString() ?? '') ?? 0).round();
    return _PiggyGoal(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Цель',
      iconId: (data['icon']?.toString().trim().isNotEmpty == true) ? data['icon']!.toString().trim() : 'savings',
      targetAmount: target,
      savedAmount: saved,
      currency: data['currency']?.toString() ?? 'RUB',
      progressPercent: (data['progressPercent'] is int)
          ? (data['progressPercent'] as int)
          : (data['progressPercent'] is num)
              ? (data['progressPercent'] as num).round()
              : (target <= 0)
                  ? 0
                  : ((saved / target) * 100).clamp(0, 100).round(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final _PiggyGoal goal;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GoalIcon(iconId: goal.iconId),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${goal.savedAmount} / ${goal.targetAmount} ${goal.currency}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x19C1FF05),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0x33C1FF05)),
                ),
                child: Text(
                  '${goal.progressPercent}%',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: goal.targetAmount <= 0 ? 0 : (goal.savedAmount / goal.targetAmount).clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC1FF05)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalIcon extends StatelessWidget {
  const _GoalIcon({required this.iconId});

  final String iconId;

  IconData get _icon {
    return switch (iconId) {
      'beach' => Icons.beach_access_rounded,
      'phone' => Icons.smartphone_rounded,
      'car' => Icons.directions_car_rounded,
      'home' => Icons.home_rounded,
      'gift' => Icons.card_giftcard_rounded,
      'invest' => Icons.trending_up_rounded,
      'savings' => Icons.savings_rounded,
      _ => Icons.savings_rounded,
    };
  }

  Color get _bg {
    return switch (iconId) {
      'beach' => const Color(0x26FF7D32),
      'phone' => const Color(0x26C8E1FC),
      'car' => const Color(0x26C4FF2E),
      'home' => const Color(0x26E9D5FF),
      'gift' => const Color(0x26FDE68A),
      'invest' => const Color(0x26DBEAFE),
      _ => const Color(0x26C4FF2E),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: ShapeDecoration(
        color: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Icon(_icon, color: const Color(0xFF0F172A), size: 22),
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryCtaButton extends StatelessWidget {
  const _SecondaryCtaButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet({required this.onCreated});

  final VoidCallback onCreated;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _api = ApiClient();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '50000');

  String _currency = 'RUB';
  String _iconId = 'beach';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;

    if (name.isEmpty || target <= 0) {
      Navigator.of(context).pop();
      return;
    }

    try {
      await _api.dio.post(
        '/goals',
        data: {
          'name': name,
          'icon': _iconId,
          'targetAmount': target,
          'currency': _currency,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Новая цель',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Название',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Сумма',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currency,
                        items: const [
                          DropdownMenuItem(value: 'RUB', child: Text('RUB')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _currency = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Иконка',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final iconId in const ['beach', 'phone', 'car', 'home', 'gift', 'invest'])
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _iconId = iconId),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _iconId == iconId ? const Color(0xFFC1FF05) : const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _GoalIcon(iconId: iconId),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _PrimaryCtaButton(label: 'Создать', onTap: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
