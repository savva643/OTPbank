import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_bank_card.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../accounts/presentation/card_details_screen.dart';
import '../../investments/presentation/investments_screen.dart';
import '../../goals/presentation/piggy_bank_screen.dart';
import '../domain/product_ui_config.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, this.productId, required this.titleFallback});

  final String? productId;
  final String titleFallback;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _api = ApiClient();
  bool _loading = false;
  ProductDetailsData? _data;
  List<_ProductWidgetData> _widgets = const [];

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _handleCta(_ProductWidgetData widget) async {
    var action = (widget.ctaAction ?? '').trim().toLowerCase();
    final payload = (widget.ctaPayload ?? '').trim();
    if (action.isEmpty) return;

    if (action == 'open') action = 'open_screen';

    if (action == 'show_toast') {
      final msg = payload.isNotEmpty ? payload : ((widget.subtitle ?? '').trim().isNotEmpty ? widget.subtitle!.trim() : 'Готово');
      _toast(msg);
      return;
    }

    if (action == 'open_screen') {
      final code = payload.toLowerCase();
      if (code == 'investments' || code == 'invest') {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const InvestmentsScreen()));
        return;
      }
      if (code == 'piggy_bank' || code == 'piggy' || code == 'invest_piggy') {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PiggyBankScreen()));
        return;
      }

      _toast('Раздел в разработке');
      return;
    }

    if (action == 'card_issue') {
      final productType = payload.isNotEmpty ? payload : 'travel';
      await _openCardIssueSheet(productType: productType, label: widget.title);
      return;
    }

    _toast('Действие не поддерживается');
  }

  Future<void> _openCardIssueSheet({required String productType, String? label}) async {
    final result = await showModalBottomSheet<_IssuedCardNavData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _CardIssueSheet(
          productType: productType,
          label: label,
        );
      },
    );

    if (result == null) return;
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CardDetailsScreen(
          args: CardDetailsArgs(
            cardId: result.cardId,
            cardTitle: result.cardTitle,
            cardTypeName: result.cardTypeName, // added cardTypeName parameter
            accountTitle: result.accountTitle,
            balance: result.balance,
            pan: result.pan,
            validThru: null,
            variant: result.variant,
          ),
        ),
      ),
    );
  }

  static IconData _iconByCode(String? code) {
    switch ((code ?? '').trim().toLowerCase()) {
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'home':
        return Icons.home_work_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'percent':
        return Icons.percent_rounded;
      case 'coins':
        return Icons.paid_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'users':
        return Icons.groups_rounded;
      case 'check':
        return Icons.check_circle_rounded;
      case 'timer':
        return Icons.timer_rounded;
      case 'shield':
        return Icons.health_and_safety_rounded;
      case 'sparkles':
        return Icons.auto_awesome_rounded;
      case 'bolt':
        return Icons.flash_on_rounded;
      case 'lounge':
        return Icons.airline_seat_recline_extra_rounded;
    }
    return Icons.widgets_rounded;
  }

  Future<void> _load() async {
    final id = widget.productId;
    if (id == null || id.trim().isEmpty) {
      setState(() => _data = ProductDetailsMock.byTitle(widget.titleFallback));
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/products/$id');
      final raw = res.data;
      if (!mounted) return;

      if (raw is! Map) {
        setState(() => _data = ProductDetailsMock.byTitle(widget.titleFallback));
        return;
      }

      final name = raw['name']?.toString().trim();
      final title = (name == null || name.isEmpty) ? widget.titleFallback : name;
      final desc = raw['description']?.toString().trim();
      final cfg = ProductUiConfig.byTitle(title);

      final items = <ProductActionCardData>[];
      final features = raw['features'];
      if (features is List) {
        for (final f in features) {
          if (f is! Map) continue;
          final ft = f['title']?.toString().trim();
          if (ft == null || ft.isEmpty) continue;
          items.add(
            ProductActionCardData(
              icon: _iconByCode(f['icon']?.toString()),
              iconBg: const Color(0xFFF1F5F9),
              title: ft,
              subtitle: (f['description']?.toString().trim().isNotEmpty == true)
                  ? (f['description']?.toString() ?? '')
                  : ' ',
              ctaLabel: 'Подробнее',
              onTap: null,
            ),
          );
        }
      }

      final offerItems = <ProductActionCardData>[];
      final offers = raw['offers'];
      if (offers is List) {
        for (final o in offers) {
          if (o is! Map) continue;
          final ot = o['title']?.toString().trim();
          if (ot == null || ot.isEmpty) continue;
          final cta = o['ctaLabel']?.toString().trim();
          offerItems.add(
            ProductActionCardData(
              icon: cfg.icon,
              iconBg: cfg.tileBg,
              title: ot,
              subtitle: (o['description']?.toString().trim().isNotEmpty == true)
                  ? (o['description']?.toString() ?? '')
                  : ' ',
              ctaLabel: (cta == null || cta.isEmpty) ? 'Открыть' : cta,
              onTap: null,
            ),
          );
        }
      }

      final sections = <ProductDetailsSectionData>[];
      if (items.isNotEmpty) {
        sections.add(ProductDetailsSectionData(title: 'ВОЗМОЖНОСТИ', items: items));
      }
      if (offerItems.isNotEmpty) {
        sections.add(ProductDetailsSectionData(title: 'ПРЕДЛОЖЕНИЯ', items: offerItems));
      }
      if (sections.isEmpty) {
        sections.addAll(ProductDetailsMock.byTitle(title).sections);
      }

      final widgets = <_ProductWidgetData>[];
      final widgetsRaw = raw['widgets'];
      if (widgetsRaw is List) {
        for (final w in widgetsRaw) {
          if (w is! Map) continue;
          final type = w['type']?.toString().trim().toLowerCase();
          if (type == null || type.isEmpty) continue;
          widgets.add(
            _ProductWidgetData(
              type: type,
              title: w['title']?.toString(),
              subtitle: w['subtitle']?.toString(),
              icon: w['icon']?.toString(),
              bgColor: w['bgColor']?.toString(),
              borderColor: w['borderColor']?.toString(),
              ctaLabel: w['ctaLabel']?.toString(),
              ctaAction: w['ctaAction']?.toString(),
              ctaPayload: w['ctaPayload']?.toString(),
              payload: w['payload'],
            ),
          );
        }
      }

      final banner = widgets.where((e) => e.type == 'banner').toList();
      final bannerWidget = banner.isEmpty ? null : banner.first;
      final heroTitle = (bannerWidget?.title?.trim().isNotEmpty == true) ? bannerWidget!.title!.trim() : title;
      final heroSubtitle = (bannerWidget?.subtitle?.trim().isNotEmpty == true)
          ? bannerWidget!.subtitle!.trim()
          : ((desc == null || desc.isEmpty) ? 'Описание продукта' : desc);

      final gradientColors = _gradientFromBanner(bannerWidget) ?? cfg.gradientColors;

      setState(
        () {
          _widgets = widgets;
          _data = ProductDetailsData(
          title: title,
          heroTitle: heroTitle,
          heroSubtitle: heroSubtitle,
          gradientColors: gradientColors,
          headerCard: null,
          headerIcon: (bannerWidget?.icon?.trim().isNotEmpty == true) ? _iconByCode(bannerWidget!.icon) : cfg.icon,
          sections: sections,
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _widgets = const [];
        _data = ProductDetailsMock.byTitle(widget.titleFallback);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static List<Color>? _gradientFromBanner(_ProductWidgetData? banner) {
    if (banner == null) return null;
    final payload = banner.payload;
    if (payload is! Map) return null;
    final g = payload['gradient'];
    if (g is! List) return null;
    final colors = <Color>[];
    for (final item in g) {
      final c = _parseHexColor(item?.toString());
      if (c != null) colors.add(c);
    }
    return colors.isEmpty ? null : colors;
  }

  static Color? _parseHexColor(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null;
    final normalized = v.startsWith('#') ? v.substring(1) : v;
    if (normalized.length == 6) {
      final i = int.tryParse('FF$normalized', radix: 16);
      return i == null ? null : Color(i);
    }
    if (normalized.length == 8) {
      final i = int.tryParse(normalized, radix: 16);
      return i == null ? null : Color(i);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9E6FC3)),
        ),
      );
    }

    final headerLuminance = data.gradientColors.isEmpty
        ? 1.0
        : data.gradientColors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) /
            data.gradientColors.length;
    final isDarkHeader = headerLuminance < 0.42;
    final headerTitleColor = isDarkHeader ? Colors.white : const Color(0xFF0F172A);
    final headerSubColor = isDarkHeader ? Colors.white.withOpacity(0.86) : const Color(0xCC1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _HeaderBackground(gradientColors: data.gradientColors),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              OtpUniversalAppBar(
                title: data.title,
                backHasBackground: true,
                backgroundColor: Colors.transparent,
                textColor: headerTitleColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.headerIcon != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(24, 18),
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.12,
                              child: Icon(
                                data.headerIcon,
                                size: 128,
                                color: isDarkHeader ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.heroTitle,
                            style: TextStyle(
                              color: headerTitleColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.heroSubtitle,
                      style: TextStyle(
                        color: headerSubColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (data.headerCard != null) _HeaderActionCard(data: data.headerCard!),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Material(
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: const Color(0x1A000000),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 128),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final w in _widgets) ...[
                            _ProductWidgetBlock(widget: w, onCtaTap: () => _handleCta(w)),
                            const SizedBox(height: 16),
                          ],
                          for (final section in data.sections) ...[
                            _SectionTitle(title: section.title),
                            const SizedBox(height: 16),
                            for (final item in section.items) ...[
                              _InfoCtaCard(item: item),
                              const SizedBox(height: 16),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductWidgetData {
  const _ProductWidgetData({
    required this.type,
    this.title,
    this.subtitle,
    this.icon,
    this.bgColor,
    this.borderColor,
    this.ctaLabel,
    this.ctaAction,
    this.ctaPayload,
    this.payload,
  });

  final String type;
  final String? title;
  final String? subtitle;
  final String? icon;
  final String? bgColor;
  final String? borderColor;
  final String? ctaLabel;
  final String? ctaAction;
  final String? ctaPayload;
  final dynamic payload;
}

class _ProductWidgetBlock extends StatelessWidget {
  const _ProductWidgetBlock({required this.widget, required this.onCtaTap});

  final _ProductWidgetData widget;
  final VoidCallback onCtaTap;

  static Color? _hex(String? raw) => _ProductDetailsScreenState._parseHexColor(raw);

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case 'card':
        return _WidgetCard(widget: widget, onCtaTap: onCtaTap);
      case 'banner':
        return _WidgetBanner(widget: widget, onCtaTap: onCtaTap);
      case 'faq':
        return _WidgetFaq(widget: widget);
      case 'stepper':
        return _WidgetStepper(widget: widget, onCtaTap: onCtaTap);
    }
    return const SizedBox.shrink();
  }
}

class _WidgetBanner extends StatelessWidget {
  const _WidgetBanner({required this.widget, required this.onCtaTap});

  final _ProductWidgetData widget;
  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    final bg = _ProductDetailsScreenState._parseHexColor(widget.bgColor) ?? const Color(0xFFF1F5F9);
    final border = _ProductDetailsScreenState._parseHexColor(widget.borderColor) ?? Colors.white;
    final title = (widget.title ?? '').trim();
    final subtitle = (widget.subtitle ?? '').trim();
    final cta = (widget.ctaLabel ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: bg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: border.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          if (cta.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PillButton(label: cta, onTap: onCtaTap),
          ],
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({required this.widget, required this.onCtaTap});

  final _ProductWidgetData widget;
  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    final title = (widget.title ?? '').trim();
    if (title.isEmpty) return const SizedBox.shrink();

    final subtitle = (widget.subtitle ?? ' ').toString();
    final cta = (widget.ctaLabel ?? 'Открыть').trim();

    return _InfoCtaCard(
      item: ProductActionCardData(
        icon: _ProductDetailsScreenState._iconByCode(widget.icon),
        iconBg: const Color(0xFFF1F5F9),
        title: title,
        subtitle: subtitle,
        ctaLabel: cta,
        onTap: onCtaTap,
      ),
    );
  }
}

class _WidgetFaq extends StatelessWidget {
  const _WidgetFaq({required this.widget});

  final _ProductWidgetData widget;

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;
    final itemsRaw = payload is Map ? payload['items'] : null;
    if (itemsRaw is! List || itemsRaw.isEmpty) return const SizedBox.shrink();

    final title = (widget.title ?? 'FAQ').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < itemsRaw.length; i++) ...[
                _FaqTile(item: itemsRaw[i]),
                if (i != itemsRaw.length - 1)
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final q = item is Map ? item['q']?.toString().trim() : null;
    final a = item is Map ? item['a']?.toString().trim() : null;
    if (q == null || q.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Text(
        q,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
      children: [
        if (a != null && a.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              a,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}

class _WidgetStepper extends StatelessWidget {
  const _WidgetStepper({required this.widget, required this.onCtaTap});

  final _ProductWidgetData widget;
  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;
    final stepsRaw = payload is Map ? payload['steps'] : null;
    if (stepsRaw is! List || stepsRaw.isEmpty) return const SizedBox.shrink();

    final title = (widget.title ?? 'Как подключить').trim();
    final cta = (widget.ctaLabel ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Container(
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
            children: [
              for (int i = 0; i < stepsRaw.length; i++) ...[
                _StepRow(index: i + 1, text: stepsRaw[i]?.toString() ?? ''),
                if (i != stepsRaw.length - 1) const SizedBox(height: 10),
              ],
              if (cta.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PillButton(label: cta, onTap: onCtaTap),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _IssuedCardNavData {
  const _IssuedCardNavData({
    required this.cardId,
    required this.cardTitle,
    required this.cardTypeName,
    required this.accountTitle,
    required this.balance,
    required this.pan,
    required this.variant,
  });

  final String cardId;
  final String cardTitle;
  final String cardTypeName;
  final String accountTitle;
  final String balance;
  final String pan;
  final OtpBankCardVariant variant;
}

class _AccountPickItem {
  const _AccountPickItem({
    required this.id,
    required this.title,
    required this.balance,
    required this.currency,
  });

  final String id;
  final String title;
  final String balance;
  final String currency;
}

class _CardIssueSheet extends StatefulWidget {
  const _CardIssueSheet({required this.productType, this.label});

  final String productType;
  final String? label;

  @override
  State<_CardIssueSheet> createState() => _CardIssueSheetState();
}

class _CardIssueSheetState extends State<_CardIssueSheet> {
  final _api = ApiClient();
  bool _loading = true;
  bool _submitting = false;
  String? _selectedAccountId;
  List<_AccountPickItem> _accounts = const [];

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
      final res = await _api.dio.get('/accounts');
      final data = res.data;
      final items = <_AccountPickItem>[];
      if (data is Map && data['items'] is List) {
        for (final a in (data['items'] as List)) {
          if (a is! Map) continue;
          final id = a['id']?.toString();
          final title = a['title']?.toString();
          final bal = a['balance']?.toString();
          final cur = a['currency']?.toString();
          if (id == null || title == null || bal == null || cur == null) continue;
          items.add(_AccountPickItem(id: id, title: title, balance: bal, currency: cur));
        }
      }

      if (!mounted) return;
      setState(() {
        _accounts = items;
        _selectedAccountId = items.isNotEmpty ? items.first.id : null;
      });
    } catch (_) {
      if (!mounted) return;
      _toast('Не удалось загрузить счета');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static OtpBankCardVariant _variantForProductType(String t) {
    final v = t.trim().toLowerCase();
    if (v == 'travel') return OtpBankCardVariant.orange;
    if (v == 'credit' || v == 'credit_card') return OtpBankCardVariant.purple;
    return OtpBankCardVariant.dark;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final accountId = (_selectedAccountId ?? '').trim();
    if (accountId.isEmpty) {
      _toast('Выбери счёт');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.dio.post(
        '/cards/issue',
        data: {
          'accountId': accountId,
          'productType': widget.productType,
          'label': widget.label,
        },
      );

      final cardsRes = await _api.dio.get('/cards');
      final cardsData = cardsRes.data;
      if (cardsData is! Map || cardsData['items'] is! List) {
        if (!mounted) return;
        _toast('Карта выпущена');
        Navigator.of(context).pop();
        return;
      }

      Map? newest;
      for (final c in (cardsData['items'] as List)) {
        if (c is! Map) continue;
        if (c['accountId']?.toString() == accountId && c['productType']?.toString() == widget.productType) {
          newest = c;
          break;
        }
      }
      newest ??= (cardsData['items'] as List).isNotEmpty && (cardsData['items'] as List).first is Map
          ? (cardsData['items'] as List).first as Map
          : null;

      if (newest == null) {
        if (!mounted) return;
        _toast('Карта выпущена');
        Navigator.of(context).pop();
        return;
      }

      final cardId = newest['id']?.toString();
      final accTitle = newest['accountTitle']?.toString();
      final bal = newest['balance']?.toString();
      final cur = newest['currency']?.toString();
      final masked = newest['maskedCardNumber']?.toString();
      if (cardId == null || accTitle == null || bal == null || cur == null || masked == null) {
        if (!mounted) return;
        _toast('Карта выпущена');
        Navigator.of(context).pop();
        return;
      }

      final digits = masked.replaceAll(RegExp(r'[^0-9]'), '');
      final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
      final pan = last4.isEmpty ? '****' : '**** $last4';
      final title = (widget.label ?? 'Карта').trim().isNotEmpty ? (widget.label ?? 'Карта')! : 'Карта';

      final cardTypeName = newest['cardTypeName']?.toString() ?? newest['card_type_name']?.toString() ?? title;

      if (!mounted) return;
      Navigator.of(context).pop(
        _IssuedCardNavData(
          cardId: cardId,
          cardTitle: title,
          cardTypeName: cardTypeName,
          accountTitle: accTitle,
          balance: '$bal $cur',
          pan: pan,
          variant: _variantForProductType(widget.productType),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _toast('Не удалось выпустить карту');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Оформление карты',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
              IconButton(
                onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Выбери счёт, к которому выпустить карту.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: CircularProgressIndicator(color: Color(0xFF9E6FC3)),
              ),
            )
          else if (_accounts.isEmpty)
            const Text('Нет доступных счетов', style: TextStyle(color: Color(0xFF0F172A)))
          else
            Container(
              decoration: ShapeDecoration(
                color: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _accounts.length; i++) ...[
                    RadioListTile<String>(
                      value: _accounts[i].id,
                      groupValue: _selectedAccountId,
                      onChanged: _submitting
                          ? null
                          : (v) {
                              setState(() => _selectedAccountId = v);
                            },
                      title: Text(
                        _accounts[i].title,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${_accounts[i].balance} ${_accounts[i].currency}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      activeColor: const Color(0xFF9E6FC3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    if (i != _accounts.length - 1)
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_loading || _submitting || _accounts.isEmpty) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC1FF05),
                foregroundColor: const Color(0xFF0F172A),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _submitting ? 'Оформляем...' : 'Оформить',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.gradientColors});

  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.36, -0.11),
          end: const Alignment(0.64, 1.11),
          colors: gradientColors,
        ),
      ),
      child: Opacity(
        opacity: 0.20,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.0, 0.0),
              radius: 1.51,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0),
                Colors.white.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.4,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _HeaderActionCard extends StatelessWidget {
  const _HeaderActionCard({required this.data});

  final ProductHeaderCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.50)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(6),
            decoration: ShapeDecoration(
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Icon(data.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.kicker,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
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

class _InfoCtaCard extends StatelessWidget {
  const _InfoCtaCard({required this.item});

  final ProductActionCardData item;

  @override
  Widget build(BuildContext context) {
    final ctaOnTap = item.onTap ??
        (item.ctaLabel == 'Открыть копилку'
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PiggyBankScreen(),
                  ),
                );
              }
            : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: ShapeDecoration(
                  color: item.iconBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(item.icon, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
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
          const SizedBox(height: 16),
          _PillButton(label: item.ctaLabel, onTap: ctaOnTap),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9999),
        child: InkWell(
          borderRadius: BorderRadius.circular(9999),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsData {
  const ProductDetailsData({
    required this.title,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.gradientColors,
    required this.sections,
    this.headerCard,
    this.headerIcon,
  });

  final String title;
  final String heroTitle;
  final String heroSubtitle;
  final List<Color> gradientColors;
  final ProductHeaderCardData? headerCard;
  final IconData? headerIcon;
  final List<ProductDetailsSectionData> sections;
}

class ProductHeaderCardData {
  const ProductHeaderCardData({
    required this.kicker,
    required this.title,
    required this.icon,
  });

  final String kicker;
  final String title;
  final IconData icon;
}

class ProductDetailsSectionData {
  const ProductDetailsSectionData({required this.title, required this.items});

  final String title;
  final List<ProductActionCardData> items;
}

class ProductActionCardData {
  const ProductActionCardData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onTap;
}

class ProductDetailsMock {
  static ProductDetailsData byTitle(String title) {
    final cfg = ProductUiConfig.byTitle(title);
    if (title.toLowerCase() == 'путешествия') {
      return const ProductDetailsData(
        title: 'Путешествия',
        heroTitle: 'Ваш мир,\nоткрыт.',
        heroSubtitle: 'Умные инструменты для роуминга',
        gradientColors: [
          Color(0xFFC4FF2E),
          Color(0xFFA8E600),
          Color(0xFFC8E1FC),
        ],
        headerIcon: Icons.flight_takeoff_rounded,
        headerCard: ProductHeaderCardData(
          kicker: 'СПЛАНИРУЙТЕ ПОЕЗДКУ',
          title: 'Куда вы отправляетесь?',
          icon: Icons.near_me_rounded,
        ),
        sections: [
          ProductDetailsSectionData(
            title: 'ПЕРЕД ПОЕЗДКОЙ',
            items: [
              ProductActionCardData(
                icon: Icons.savings_rounded,
                iconBg: Color(0x26FF7D32),
                title: 'Копилка на отпуск',
                subtitle: 'Автоматические накопления на\nнаправление вашей мечты.',
                ctaLabel: 'Начать копить',
              ),
              ProductActionCardData(
                icon: Icons.currency_exchange_rounded,
                iconBg: Color(0x33C4FF2E),
                title: 'Обмен валюты',
                subtitle: 'Мгновенная конвертация для\nболее чем 80 валют.',
                ctaLabel: 'Обменять',
              ),
              ProductActionCardData(
                icon: Icons.health_and_safety_rounded,
                iconBg: Color(0x269E6FC3),
                title: 'Страхование',
                subtitle: 'Умное покрытие здоровья и\nбагажа.',
                ctaLabel: 'Оформить страховку',
              ),
              ProductActionCardData(
                icon: Icons.receipt_long_rounded,
                iconBg: Color(0xFFF1F5F9),
                title: 'Траты в поездке',
                subtitle: 'Контроль бюджета с\nуведомлениями в реальном\nвремени.',
                ctaLabel: 'Открыть трекер',
              ),
            ],
          ),
        ],
      );
    }

    if (title.toLowerCase() == 'инвесткопилка') {
      return ProductDetailsData(
        title: 'Инвесткопилка',
        heroTitle: 'Инвесткопилка',
        heroSubtitle: 'Округляйте покупки и копите незаметно.',
        gradientColors: cfg.gradientColors,
        headerCard: const ProductHeaderCardData(
          kicker: 'СБЕРЕЖЕНИЯ + ИНВЕСТИЦИИ',
          title: 'Автопополнение и прогнозы рынка',
          icon: Icons.auto_graph_rounded,
        ),
        headerIcon: cfg.icon,
        sections: [
          ProductDetailsSectionData(
            title: 'ВОЗМОЖНОСТИ',
            items: [
              ProductActionCardData(
                icon: Icons.savings_rounded,
                iconBg: const Color(0x19C1FF05),
                title: 'Копилка',
                subtitle: 'Создавайте цели, выбирайте иконку\nи пополняйте в 1 тап.',
                ctaLabel: 'Открыть копилку',
                onTap: null,
              ),
            ],
          ),
        ],
      );
    }

    return ProductDetailsData(
      title: cfg.title,
      heroTitle: cfg.title,
      heroSubtitle: 'Описание продукта',
      gradientColors: cfg.gradientColors,
      headerCard: null,
      headerIcon: cfg.icon,
      sections: const [
        ProductDetailsSectionData(
          title: 'ВОЗМОЖНОСТИ',
          items: [
            ProductActionCardData(
              icon: Icons.widgets_rounded,
              iconBg: Color(0xFFF1F5F9),
              title: 'Функция',
              subtitle: 'Описание функции продукта',
              ctaLabel: 'Открыть',
            ),
          ],
        ),
      ],
    );
  }
}
