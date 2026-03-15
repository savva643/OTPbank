import 'package:flutter/material.dart';

import '../domain/product_ui_config.dart';

enum OtpProductTileSize {
  large,
  mediumSquare,
  mediumWide,
  small,
}

class OtpProductTile extends StatelessWidget {
  const OtpProductTile({
    super.key,
    required this.product,
    required this.size,
    this.subtitle,
    this.smallTitle,
    this.smallSubtitle,
    this.badgeText,
    this.badgeValue,
    this.onTap,
  });

  final ProductUiConfig product;
  final OtpProductTileSize size;
  final String? subtitle;
  final Widget? smallTitle;
  final String? smallSubtitle;
  final String? badgeText;
  final String? badgeValue;
  final VoidCallback? onTap;

  double? _height() {
    return switch (size) {
      OtpProductTileSize.large => 176,
      OtpProductTileSize.mediumSquare => 160,
      OtpProductTileSize.mediumWide => 120,
      OtpProductTileSize.small => null,
    };
  }

  EdgeInsets _padding() {
    return switch (size) {
      OtpProductTileSize.large => const EdgeInsets.all(20),
      OtpProductTileSize.mediumSquare => const EdgeInsets.all(16),
      OtpProductTileSize.mediumWide => const EdgeInsets.all(14),
      OtpProductTileSize.small => const EdgeInsets.all(12),
    };
  }

  double _radius() {
    return switch (size) {
      OtpProductTileSize.large => 24,
      OtpProductTileSize.mediumSquare => 24,
      OtpProductTileSize.mediumWide => 24,
      OtpProductTileSize.small => 18,
    };
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_radius());

    final isDark = product.tileBg.computeLuminance() < 0.18;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white.withOpacity(0.80) : const Color(0xFF334155);

    final iconContainerColor = isDark ? Colors.white : product.iconBg;

    // Определяем фиксированную высоту для средних и больших плиток
    final fixedHeight = _height();

    // Для маленьких плиток высота будет определяться контентом
    final useFixedHeight = fixedHeight != null;

    Widget content;

    if (size == OtpProductTileSize.small) {
      content = Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(product.icon, size: 18, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                smallTitle ??
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                if (smallSubtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    smallSubtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    } else {
      final isMedium = size == OtpProductTileSize.mediumSquare || size == OtpProductTileSize.mediumWide;
      final subtitleMaxLines = size == OtpProductTileSize.large ? 1 : (isMedium ? 1 : 2);
      final titleMaxLines = isMedium ? 1 : 2;
      final titleFontSize = size == OtpProductTileSize.large ? 18.0 : (isMedium ? 13.0 : 14.0);
      final subtitleFontSize = isMedium ? 11.0 : 12.0;

      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconContainerColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(product.icon, color: const Color(0xFF0F172A)),
              ),
              const Spacer(),
              if (badgeText != null || badgeValue != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (badgeText != null)
                      Text(
                        badgeText!,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                          letterSpacing: 0.50,
                        ),
                      ),
                    if (badgeValue != null)
                      Text(
                        badgeValue!,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                        ),
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: isMedium ? 8 : 12),
          // Используем Flexible вместо Expanded для правильного распределения пространства
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: subtitleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subColor,
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: useFixedHeight ? fixedHeight : null,
        padding: _padding(),
        decoration: BoxDecoration(
          color: size == OtpProductTileSize.small ? const Color(0xFFF8FAFC) : product.tileBg,
          borderRadius: radius,
          border: Border.all(
            width: 1,
            color: size == OtpProductTileSize.small ? const Color(0xFFE2E8F0) : Colors.white.withOpacity(0.7),
          ),
        ),
        child: content,
      ),
    );
  }
}