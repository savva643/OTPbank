import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../core/network/api_client.dart';
import 'sbp_payment_screen.dart';

class SbpTransferScreen extends StatefulWidget {
  const SbpTransferScreen({super.key, this.initialQuery});

  static const heroSearchTag = 'sbp_search_field';

  final String? initialQuery;

  @override
  State<SbpTransferScreen> createState() => _SbpTransferScreenState();
}

class _SbpTransferScreenState extends State<SbpTransferScreen> {
  late final TextEditingController _controller;
  Future<List<Contact>>? _contactsFuture;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _contactsFuture = _loadContacts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Contact>> _loadContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) return const [];
    return FlutterContacts.getContacts(withProperties: true, withThumbnail: true);
  }

  Future<String?> _searchUserByPhone(String digits) async {
    try {
      final res = await _api.dio.get('/users/search', queryParameters: {'phone': digits});
      final data = res.data;
      if (data is Map && data['firstName'] != null) {
        final parts = [
          if (data['lastName']?.isNotEmpty == true) data['lastName'],
          if (data['firstName']?.isNotEmpty == true) data['firstName'],
          if (data['middleName']?.isNotEmpty == true) data['middleName'],
        ];
        return parts.whereType<String>().join(' ');
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.of(context).pop(),
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Hero(
                tag: SbpTransferScreen.heroSearchTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(width: 1, color: const Color(0xFFE5E7EB)),
                    ),
                    height: 44,
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: 'Имя, телефон или банк',
                        hintStyle: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.person_rounded, size: 18, color: Color(0xFF6B7280)),
                        prefixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 44),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(48)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(48)),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(48)),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: _contactsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final contacts = snapshot.data ?? const [];
                  final rawQuery = _controller.text.trim();
                  final q = rawQuery.toLowerCase();
                  final qDigits = _onlyDigits(rawQuery);
                  final isDigitsQuery = rawQuery.isNotEmpty && qDigits.isNotEmpty && qDigits.length >= (rawQuery.length * 0.6);

                  final filtered = q.isEmpty
                      ? contacts
                      : contacts.where((c) {
                          final name = c.displayName.toLowerCase();
                          final phonesDigits = c.phones.map((p) => _onlyDigits(p.number)).join(' ');

                          if (isDigitsQuery) {
                            return phonesDigits.contains(qDigits);
                          }

                          return name.contains(q) || phonesDigits.contains(qDigits);
                        }).toList();

                  final showManualNumberTile = isDigitsQuery && qDigits.length >= 7;

                  return FutureBuilder<String?>(
                    future: showManualNumberTile ? _searchUserByPhone(qDigits) : Future.value(null),
                    builder: (context, nameSnapshot) {
                      final internalName = nameSnapshot.data;

                      final manualTileCount = showManualNumberTile ? 1 : 0;
                      final totalCount = manualTileCount + filtered.length;

                      if (totalCount == 0) {
                        return const Center(
                          child: Text(
                            'Контакты не найдены',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: totalCount,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF9FAFB)),
                        itemBuilder: (context, index) {
                          if (showManualNumberTile && index == 0) {
                            final displayNumber = _formatAsPhone(qDigits);
                            final name = internalName;
                            final initials = name == null ? '?' : _initials(name);

                            return InkWell(
                              onTap: () async {
                                final ok = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute<bool>(
                                    builder: (_) => SbpPaymentScreen(
                                      recipientName: name,
                                      recipientPhoneDigits: qDigits,
                                      isInternalRecipient: name != null,
                                    ),
                                  ),
                                );

                                if (!context.mounted) return;
                                if (ok == true) Navigator.of(context).pop<String>(displayNumber);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    name == null
                                        ? const _IconAvatar(icon: Icons.person_rounded)
                                        : _Avatar(initials: initials, bytes: null),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name ?? displayNumber,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF111827),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              height: 1.50,
                                            ),
                                          ),
                                          if (name != null)
                                            Text(
                                              displayNumber,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.43,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final c = filtered[index - manualTileCount];
                          final phone = c.phones.isEmpty ? null : c.phones.first.number;
                          final phoneDigits = phone == null ? null : _onlyDigits(phone);
                          final initials = _initials(c.displayName);

                          return InkWell(
                            onTap: phoneDigits == null || phoneDigits.isEmpty
                                ? null
                                : () async {
                                    final internalName = await _searchUserByPhone(phoneDigits);
                                    final ok = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute<bool>(
                                        builder: (_) => SbpPaymentScreen(
                                          recipientName: internalName ?? c.displayName,
                                          recipientPhoneDigits: phoneDigits,
                                          isInternalRecipient: internalName != null,
                                        ),
                                      ),
                                    );

                                    if (!context.mounted) return;
                                    if (ok == true) Navigator.of(context).pop<String>(_formatAsPhone(phoneDigits));
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  _Avatar(initials: initials, bytes: c.thumbnail),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF111827),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            height: 1.50,
                                          ),
                                        ),
                                        if (phone != null)
                                          Text(
                                            phone,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final a = parts[0].isEmpty ? '' : parts[0][0];
    final b = parts.length < 2 || parts[1].isEmpty ? '' : parts[1][0];
    return (a + b).toUpperCase();
  }

  String _onlyDigits(String s) {
    return s.replaceAll(RegExp(r'[^0-9]'), '');
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

  @override
  Widget build(BuildContext context) {
    final balanceStr = account['balance']?.toString() ?? '0';
    final balance = double.tryParse(balanceStr) ?? 0;
    final formattedBalance = balance.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    final accountNumber = account['account_number'] as String? ?? '****';
    final shortNumber = accountNumber.length >= 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber;
    final title = account['title'] as String? ?? 'Счёт';

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
              '$title · $shortNumber',
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

class _IconAvatar extends StatelessWidget {
  const _IconAvatar({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Icon(icon, color: const Color(0xFF4B5563)),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.bytes});

  final String initials;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(9999),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            )
          : Image.memory(bytes!, fit: BoxFit.cover),
    );
  }
}
