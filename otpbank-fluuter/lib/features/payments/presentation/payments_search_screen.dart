import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_search_input.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class PaymentsSearchScreen extends StatefulWidget {
  const PaymentsSearchScreen({
    super.key,
    this.initialQuery,
  });

  static const String heroSearchTag = 'payments_search_hero';

  final String? initialQuery;

  @override
  State<PaymentsSearchScreen> createState() => _PaymentsSearchScreenState();
}

class _PaymentsSearchScreenState extends State<PaymentsSearchScreen> {
  final _api = ApiClient();
  final _controller = TextEditingController();

  Timer? _debounce;
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery?.trim() ?? '';
    _controller.addListener(_onQueryChanged);

    final q = _controller.text.trim();
    if (q.isNotEmpty) {
      _search(q);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _controller.text.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (q.isEmpty) {
        setState(() {
          _items = [];
          _error = null;
          _loading = false;
        });
        return;
      }
      _search(q);
    });
  }

  String? _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${AppConfig.baseUrl}$url';
    return '${AppConfig.baseUrl}/$url';
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.dio.get(
        '/categories/services/search',
        queryParameters: {'q': q},
      );
      final data = res.data;
      if (!mounted) return;

      if (data is Map && data['items'] is List) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(data['items'] as List);
          _loading = false;
        });
        return;
      }

      setState(() {
        _error = 'Неверный формат данных';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ошибка поиска: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const OtpUniversalAppBar(
            title: 'Поиск',
          ),
          Hero(
            tag: PaymentsSearchScreen.heroSearchTag,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: OtpSearchInput(
                  controller: _controller,
                  hintText: 'Поиск организации или услуги',
                  autofocus: true,
                  onSubmitted: (v) => _search(v.trim()),
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final q = _controller.text.trim();

    if (q.isEmpty) {
      return const Center(
        child: Text(
          'Введите запрос для поиска',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4FF2E)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Ничего не найдено',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final name = item['name']?.toString() ?? '';
        final description = item['description']?.toString();
        final imageUrl = _resolveImageUrl(item['imageUrl']?.toString());

        return InkWell(
          onTap: () {
            Navigator.of(context).pop(_controller.text.trim());
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.business_rounded,
                              color: Color(0xFF0F172A),
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.business_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description != null && description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
