import 'package:flutter/material.dart';

class ProductUiConfig {
  const ProductUiConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.tileBg,
    required this.iconBg,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color tileBg;
  final Color iconBg;

  static const _fallback = ProductUiConfig(
    id: 'generic',
    title: 'Продукт',
    icon: Icons.widgets_rounded,
    gradientColors: [Color(0xFFC8E1FC), Color(0xFFF1F5F9)],
    tileBg: Color(0xFFF1F5F9),
    iconBg: Color(0xFFFFFFFF),
  );

  static const travel = ProductUiConfig(
    id: 'travel',
    title: 'Путешествия',
    icon: Icons.flight_takeoff_rounded,
    gradientColors: [
      Color(0xFFC4FF2E),
      Color(0xFFA8E600),
      Color(0xFFC8E1FC),
    ],
    tileBg: Color(0x66C8E1FC),
    iconBg: Color(0xFFFFFFFF),
  );

  static const mortgage = ProductUiConfig(
    id: 'mortgage',
    title: 'Ипотека',
    icon: Icons.home_rounded,
    gradientColors: [
      Color(0xFFC8E1FC),
      Color(0xFFF1F5F9),
      Color(0xFFFFFFFF),
    ],
    tileBg: Color(0xFFF1F5F9),
    iconBg: Color(0xFFFFFFFF),
  );

  static const autoLoan = ProductUiConfig(
    id: 'auto_loan',
    title: 'Автокредит',
    icon: Icons.directions_car_rounded,
    gradientColors: [
      Color(0xFFFFEDD5),
      Color(0xFFFFF7ED),
      Color(0xFFFFFFFF),
    ],
    tileBg: Color(0xFFFFEDD5),
    iconBg: Color(0xFFFFFFFF),
  );

  static const savings = ProductUiConfig(
    id: 'savings',
    title: 'Накопления',
    icon: Icons.savings_rounded,
    gradientColors: [
      Color(0xFFC4FF2E),
      Color(0xFFF1F5F9),
      Color(0xFFFFFFFF),
    ],
    tileBg: Color(0x1AC4FF2E),
    iconBg: Color(0xFFFFFFFF),
  );

  static const insurance = ProductUiConfig(
    id: 'insurance',
    title: 'Страхование',
    icon: Icons.health_and_safety_rounded,
    gradientColors: [
      Color(0xFFDBEAFE),
      Color(0xFFF1F5F9),
      Color(0xFFFFFFFF),
    ],
    tileBg: Color(0xFFDBEAFE),
    iconBg: Color(0xFFFFFFFF),
  );

  static const investments = ProductUiConfig(
    id: 'investments',
    title: 'Инвестиции',
    icon: Icons.trending_up_rounded,
    gradientColors: [
      Color(0xFFF3E8FF),
      Color(0xFFF8FAFC),
      Color(0xFFFFFFFF),
    ],
    tileBg: Color(0xFFF3E8FF),
    iconBg: Color(0xFFFFFFFF),
  );

  static const cashLoan = ProductUiConfig(
    id: 'cash_loan',
    title: 'Кредит наличными',
    icon: Icons.account_balance_wallet_rounded,
    gradientColors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
    tileBg: Color(0xFF0F172A),
    iconBg: Color(0xFFFFFFFF),
  );

  static const List<ProductUiConfig> all = [
    travel,
    mortgage,
    autoLoan,
    savings,
    insurance,
    investments,
    cashLoan,
  ];

  static ProductUiConfig byTitle(String title) {
    final t = title.trim().toLowerCase();
    for (final c in all) {
      if (c.title.toLowerCase() == t) return c;
    }

    if (t.contains('путеше')) return travel;
    if (t.contains('ипот')) return mortgage;
    if (t.contains('авто')) return autoLoan;
    if (t.contains('накоп')) return savings;
    if (t.contains('страх')) return insurance;
    if (t.contains('инвест')) return investments;
    if (t.contains('налич')) return cashLoan;

    return _fallback.copyWith(title: title);
  }

  ProductUiConfig copyWith({
    String? id,
    String? title,
    IconData? icon,
    List<Color>? gradientColors,
    Color? tileBg,
    Color? iconBg,
  }) {
    return ProductUiConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      gradientColors: gradientColors ?? this.gradientColors,
      tileBg: tileBg ?? this.tileBg,
      iconBg: iconBg ?? this.iconBg,
    );
  }
}
