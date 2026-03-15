import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  final _api = ApiClient();

  bool _loading = true;
  _PortfolioVm? _portfolio;
  List<_InstrumentVm> _instruments = const [];
  Map<String, _QuoteVm> _quotesByTicker = const {};

  Timer? _quotesTimer;
  int _portfolioRefreshTick = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _quotesTimer?.cancel();
    super.dispose();
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
      final pRes = await _api.dio.get('/investments/portfolio');
      final iRes = await _api.dio.get('/investments/instruments');

      final portfolio = _PortfolioVm.fromJson(pRes.data);
      final instruments = _parseInstruments(iRes.data);

      final tickers = instruments
          .where((e) => e.kind == 'stock' || e.kind == 'crypto' || e.kind == 'fx')
          .take(8)
          .map((e) => e.ticker)
          .toList();

      final quotes = tickers.isEmpty ? <_QuoteVm>[] : await _loadQuotes(tickers);
      final quotesByTicker = {for (final q in quotes) q.ticker: q};

      if (!mounted) return;
      setState(() {
        _portfolio = portfolio;
        _instruments = instruments;
        _quotesByTicker = quotesByTicker;
      });

      _startLiveQuotes();
    } catch (_) {
      if (!mounted) return;
      _toast('Не удалось загрузить инвестиции');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startLiveQuotes() {
    _quotesTimer?.cancel();

    _quotesTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) return;
      if (_instruments.isEmpty) return;

      try {
        final tickers = _instruments
            .where((e) => e.kind == 'stock' || e.kind == 'crypto' || e.kind == 'fx')
            .take(8)
            .map((e) => e.ticker)
            .toList();
        if (tickers.isEmpty) return;

        final quotes = await _loadQuotes(tickers);
        if (!mounted) return;

        setState(() {
          _quotesByTicker = {for (final q in quotes) q.ticker: q};
        });

        _portfolioRefreshTick++;
        if (_portfolioRefreshTick >= 5) {
          _portfolioRefreshTick = 0;
          final pRes = await _api.dio.get('/investments/portfolio');
          final p = _PortfolioVm.fromJson(pRes.data);
          if (!mounted) return;
          setState(() => _portfolio = p);
        }
      } catch (_) {
        // ignore polling errors
      }
    });
  }

  Future<List<_QuoteVm>> _loadQuotes(List<String> tickers) async {
    final res = await _api.dio.get(
      '/investments/quotes',
      queryParameters: {'tickers': tickers.join(',')},
    );

    final data = res.data;
    if (data is! Map || data['items'] is! List) return const [];
    return (data['items'] as List).whereType<Map>().map(_QuoteVm.fromJson).toList();
  }

  static List<_InstrumentVm> _parseInstruments(dynamic data) {
    if (data is! Map || data['items'] is! List) return const [];
    return (data['items'] as List)
        .whereType<Map>()
        .map(_InstrumentVm.fromJson)
        .toList();
  }

  static String _fmtMoney(String value, String currency) {
    final v = double.tryParse(value) ?? 0;
    final rub = currency.toUpperCase() == 'RUB';
    final s = v.toStringAsFixed(0);
    return rub ? '$s ₽' : '$s $currency';
  }

  @override
  Widget build(BuildContext context) {
    final p = _portfolio;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: OtpUniversalAppBar(
          title: 'Инвестиции',
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF9E6FC3),
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _PortfolioCard(portfolio: p, loading: _loading),
            const SizedBox(height: 16),
            _CategoriesGrid(loading: _loading),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Рынок',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () => _toast('Скоро'),
                  child: const Text(
                    'Все',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF9E6FC3)),
                ),
              )
            else
              for (final inst in _instruments.take(8)) ...[
                _MarketRow(inst: inst, quote: _quotesByTicker[inst.ticker]),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _PortfolioVm {
  const _PortfolioVm({
    required this.value,
    required this.currency,
    required this.dailyChange,
    required this.dailyChangePercent,
  });

  final String value;
  final String currency;
  final String dailyChange;
  final num dailyChangePercent;

  static _PortfolioVm? fromJson(dynamic data) {
    if (data is! Map) return null;
    return _PortfolioVm(
      value: data['value']?.toString() ?? '0',
      currency: data['currency']?.toString() ?? 'RUB',
      dailyChange: data['dailyChange']?.toString() ?? '0',
      dailyChangePercent: (data['dailyChangePercent'] is num) ? (data['dailyChangePercent'] as num) : 0,
    );
  }
}

class _InstrumentVm {
  const _InstrumentVm({
    required this.ticker,
    required this.name,
    required this.kind,
    required this.currency,
  });

  final String ticker;
  final String name;
  final String kind;
  final String currency;

  static _InstrumentVm fromJson(Map data) {
    return _InstrumentVm(
      ticker: data['ticker']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      kind: data['kind']?.toString() ?? '',
      currency: data['currency']?.toString() ?? '',
    );
  }
}

class _QuoteVm {
  const _QuoteVm({
    required this.ticker,
    required this.price,
    required this.currency,
    required this.change,
    required this.changePercent,
  });

  final String ticker;
  final String price;
  final String currency;
  final String change;
  final num changePercent;

  static _QuoteVm fromJson(Map data) {
    return _QuoteVm(
      ticker: data['ticker']?.toString() ?? '',
      price: data['price']?.toString() ?? '0',
      currency: data['currency']?.toString() ?? 'RUB',
      change: data['change']?.toString() ?? '0',
      changePercent: (data['changePercent'] is num) ? (data['changePercent'] as num) : 0,
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.portfolio, required this.loading});

  final _PortfolioVm? portfolio;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = portfolio;
    final value = p == null ? '0' : p.value;
    final cur = p == null ? 'RUB' : p.currency;
    final daily = p == null ? 0 : p.dailyChangePercent;

    final isUp = daily >= 0;
    final chipBg = isUp ? const Color(0x33C1FF05) : const Color(0x26EF4444);
    final chipText = isUp ? const Color(0xFF15803D) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Общий баланс',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(double.tryParse(value) ?? 0).toStringAsFixed(0)} ${cur.toUpperCase() == 'RUB' ? '₽' : cur}',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF9E6FC3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: ShapeDecoration(
                  color: chipBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
                child: Text(
                  '${isUp ? '+' : ''}${daily.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: chipText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'за сегодня',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget tile({required Color iconBg, required IconData icon, required String title, required String subtitle, required String pct, required bool up}) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: iconBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F172A), size: 18),
                ),
                Text(
                  pct,
                  style: TextStyle(
                    color: up ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (loading) {
      return Row(
        children: [
          Expanded(child: tile(iconBg: const Color(0x33C1FF05), icon: Icons.show_chart_rounded, title: 'Акции', subtitle: '—', pct: '—', up: true)),
          const SizedBox(width: 12),
          Expanded(child: tile(iconBg: const Color(0x339E6FC3), icon: Icons.auto_graph_rounded, title: 'Фонды', subtitle: '—', pct: '—', up: true)),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tile(iconBg: const Color(0x33C1FF05), icon: Icons.show_chart_rounded, title: 'Акции', subtitle: 'SIM', pct: '+2.4%', up: true)),
            const SizedBox(width: 12),
            Expanded(child: tile(iconBg: const Color(0x339E6FC3), icon: Icons.auto_graph_rounded, title: 'Фонды', subtitle: 'SIM', pct: '+0.8%', up: true)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: tile(iconBg: const Color(0xFFC8E1FC), icon: Icons.layers_rounded, title: 'ETF', subtitle: 'SIM', pct: '-0.2%', up: false)),
            const SizedBox(width: 12),
            Expanded(child: tile(iconBg: const Color(0x33FF7D32), icon: Icons.currency_bitcoin_rounded, title: 'Крипто', subtitle: 'SIM', pct: '+12.1%', up: true)),
          ],
        ),
      ],
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({required this.inst, required this.quote});

  final _InstrumentVm inst;
  final _QuoteVm? quote;

  @override
  Widget build(BuildContext context) {
    final q = quote;
    final pct = q == null ? 0 : q.changePercent;
    final up = pct >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Icon(
              inst.kind == 'crypto'
                  ? Icons.currency_bitcoin_rounded
                  : inst.kind == 'fx'
                      ? Icons.currency_exchange_rounded
                      : Icons.show_chart_rounded,
              color: const Color(0xFF0F172A),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inst.name,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  inst.ticker,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                q == null ? '—' : q.price,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                q == null ? '' : '${up ? '+' : ''}${pct.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: up ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
