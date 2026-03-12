import 'package:flutter/material.dart';

import '../../../core/widgets/otp_universal_app_bar.dart';

class PiggyBankScreen extends StatefulWidget {
  const PiggyBankScreen({super.key});

  @override
  State<PiggyBankScreen> createState() => _PiggyBankScreenState();
}

class _PiggyBankScreenState extends State<PiggyBankScreen> {
  final List<_PiggyGoal> _goals = [
    _PiggyGoal(
      id: '1',
      name: 'На отпуск',
      iconId: 'beach',
      targetAmount: 120000,
      savedAmount: 42000,
      currency: 'RUB',
    ),
    _PiggyGoal(
      id: '2',
      name: 'Новый телефон',
      iconId: 'phone',
      targetAmount: 90000,
      savedAmount: 18000,
      currency: 'RUB',
    ),
    _PiggyGoal(
      id: '3',
      name: 'Инвесткопилка',
      iconId: 'invest',
      targetAmount: 5000,
      savedAmount: 2750,
      currency: 'USD',
    ),
  ];

  void _openCreateGoal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CreateGoalSheet(
          onCreate: (goal) {
            setState(() {
              _goals.insert(0, goal);
            });
          },
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
          ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),
              const OtpUniversalAppBar(title: 'Копилка'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        Material(
                          color: const Color(0x19C1FF05),
                          borderRadius: BorderRadius.circular(9999),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9999),
                            onTap: _openCreateGoal,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.add_rounded, size: 18, color: Color(0xFF0F172A)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Создать',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final g in _goals) ...[
                      _GoalCard(
                        goal: g,
                        onAdd: () {
                          setState(() {
                            g.savedAmount += (g.currency == 'RUB' ? 2500 : 25);
                            if (g.savedAmount > g.targetAmount) g.savedAmount = g.targetAmount;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _PrimaryCtaButton(
              label: 'Создать цель',
              onTap: _openCreateGoal,
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
  });

  final String id;
  final String name;
  final String iconId;
  final int targetAmount;
  int savedAmount;
  final String currency;

  int get progressPercent {
    if (targetAmount <= 0) return 0;
    final p = (savedAmount / targetAmount) * 100;
    return p.clamp(0, 100).round();
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onAdd});

  final _PiggyGoal goal;
  final VoidCallback onAdd;

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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryCtaButton(
                  label: 'Пополнить',
                  onTap: onAdd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryCtaButton(
                  label: 'Настроить',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Мок: настройки цели')),
                    );
                  },
                ),
              ),
            ],
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
  const _CreateGoalSheet({required this.onCreate});

  final ValueChanged<_PiggyGoal> onCreate;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
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

  void _submit() {
    final name = _nameCtrl.text.trim();
    final target = int.tryParse(_targetCtrl.text.trim()) ?? 0;

    if (name.isEmpty || target <= 0) {
      Navigator.of(context).pop();
      return;
    }

    widget.onCreate(
      _PiggyGoal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        iconId: _iconId,
        targetAmount: target,
        savedAmount: 0,
        currency: _currency,
      ),
    );

    Navigator.of(context).pop();
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
