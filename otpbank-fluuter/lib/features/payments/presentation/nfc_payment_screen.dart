import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_large_bank_card.dart';
import '../../home/bloc/home_bloc.dart';

class NfcPaymentScreen extends StatefulWidget {
  const NfcPaymentScreen({super.key});

  @override
  State<NfcPaymentScreen> createState() => _NfcPaymentScreenState();
}

class _NfcPaymentScreenState extends State<NfcPaymentScreen> {
  String? _selectedCardId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<HomeBloc>().state;
    final cards = state.cards;
    if (_selectedCardId != null) return;
    if (cards.isEmpty) return;
    _selectedCardId = cards.firstWhere((c) => c.isMain, orElse: () => cards.first).id;
  }

  HomeCardItem? _selectedCard(HomeState state) {
    if (_selectedCardId == null) return null;
    for (final c in state.cards) {
      if (c.id == _selectedCardId) return c;
    }
    return null;
  }

  Color? _parseHexColor(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null;
    final normalized = v.startsWith('#') ? v.substring(1) : v;
    if (normalized.length == 6) {
      final parsed = int.tryParse('FF$normalized', radix: 16);
      return parsed == null ? null : Color(parsed);
    }
    if (normalized.length == 8) {
      final parsed = int.tryParse(normalized, radix: 16);
      return parsed == null ? null : Color(parsed);
    }
    return null;
  }

  OtpBankCardVariant _variantFor(HomeCardItem card) {
    if (card.productType == 'credit' || card.productType == 'credit_card') {
      return OtpBankCardVariant.purple;
    }
    if (card.productType == 'travel') return OtpBankCardVariant.orange;
    return OtpBankCardVariant.dark;
  }

  LinearGradient? _customGradientFor(HomeCardItem card) {
    final c1 = _parseHexColor(card.bgColor1);
    final c2 = _parseHexColor(card.bgColor2);
    if (c1 == null || c2 == null) return null;
    return LinearGradient(
      begin: const Alignment(0.22, -0.22),
      end: const Alignment(0.78, 1.22),
      colors: [c1, c2],
    );
  }

  String _last4Pan(HomeCardItem card) {
    final digits = card.maskedCardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    return last4.isEmpty ? '****' : '**** $last4';
  }

  String _titleFor(HomeCardItem card) {
    final label = (card.label ?? '').trim();
    if (label.isNotEmpty) return label;
    return card.accountTitle;
  }

  Future<void> _openCardPicker() async {
    final state = context.read<HomeBloc>().state;
    if (state.cards.isEmpty) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                const SizedBox(height: 12),
                const Text(
                  'Выберите карту',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.accounts.length,
                    itemBuilder: (context, index) {
                      final account = state.accounts[index];
                      final cards = state.cards.where((c) => c.accountId == account.id).toList();
                      if (cards.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.title,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 156,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: cards.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final card = cards[i];
                                  final isSelected = card.id == _selectedCardId;

                                  return Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(32),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(32),
                                      onTap: () => Navigator.of(context).pop(card.id),
                                      child: Stack(
                                        children: [
                                          OtpBankCard(
                                            title: card.accountTitle,
                                            amount: '${card.balance} ${card.currency}',
                                            pan: _last4Pan(card),
                                            variant: _variantFor(card),
                                            customGradient: _customGradientFor(card),
                                          ),
                                          if (isSelected)
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(32),
                                                  border: Border.all(
                                                    color: const Color(0xFFC4FF2E),
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (selected == null) return;
    setState(() => _selectedCardId = selected);
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeBloc>().state;
    final selectedCard = _selectedCard(home);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 19, 24, 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: const Color(0x7FE2E8F0),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0F172A),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC4FF2E),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: const Center(
                              child: ImageIcon(
                                AssetImage('assets/img/minlogo.png'),
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            'assets/img/otppeek.png',
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, c) {
                        final maxH = MediaQuery.of(context).size.height;
                        final targetH = (maxH * 0.36).clamp(180.0, 320.0);
                        return SizedBox(
                          height: targetH,
                          child: Center(
                            child: Image.asset(
                              'assets/img/nfc.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                    const Text(
                      'Прислоните телефон к\nтерминалу',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (selectedCard != null)
                      Center(
                        child: OtpLargeBankCard(
                          title: _titleFor(selectedCard),
                          subtitle: selectedCard.accountTitle,
                          variant: _variantFor(selectedCard),
                          pan: selectedCard.maskedCardNumber,
                          validThru: '—',
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 24),
                    Material(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(48),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(48),
                        onTap: _openCardPicker,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Выбрать другую карту',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
