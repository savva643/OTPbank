import 'dart:async';

import 'package:flutter/material.dart';

class OtpOfferItem {
  const OtpOfferItem({
    required this.kicker,
    required this.kickerColor,
    required this.title,
    required this.description,
    required this.cardBg,
    required this.cardBorder,
    required this.ctaLabel,
    required this.ctaBg,
    this.watermarkIcon,
    this.onTap,
  });

  final String kicker;
  final Color kickerColor;
  final String title;
  final String description;
  final Color cardBg;
  final Color cardBorder;
  final String ctaLabel;
  final Color ctaBg;
  final IconData? watermarkIcon;
  final VoidCallback? onTap;
}

class OtpOffersCarousel extends StatefulWidget {
  const OtpOffersCarousel({
    super.key,
    required this.items,
    this.autoScroll = true,
    this.interval = const Duration(seconds: 4),
  });

  final List<OtpOfferItem> items;
  final bool autoScroll;
  final Duration interval;

  @override
  State<OtpOffersCarousel> createState() => _OtpOffersCarouselState();
}

class _OtpOffersCarouselState extends State<OtpOffersCarousel> {
  late final PageController _controller;
  Timer? _timer;

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);

    if (widget.autoScroll && widget.items.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        if (!mounted) return;
        if (!_controller.hasClients) return;
        _controller.nextPage(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final itemsLength = widget.items.length;
    final pageCount = itemsLength > 1 ? itemsLength + 1 : itemsLength;

    return SizedBox(
      height: 184,
      child: PageView.builder(
        padEnds: false,
        clipBehavior: Clip.none,
        controller: _controller,
        onPageChanged: (i) {
          if (itemsLength <= 1) return;

          setState(() => _pageIndex = i);
          if (i == itemsLength) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (!_controller.hasClients) return;
              _controller.jumpToPage(0);
            });
          }
        },
        itemCount: pageCount,
        itemBuilder: (context, index) {
          final effectiveIndex = itemsLength > 1 && index == itemsLength ? 0 : index;
          final item = widget.items[effectiveIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _OfferCard(item: item),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatefulWidget {
  const _OfferCard({required this.item});

  final OtpOfferItem item;

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: item.cardBg,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: item.cardBorder),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (item.watermarkIcon != null)
              Positioned(
                right: 2,
                top: 18,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.12,
                    child: Icon(
                      item.watermarkIcon,
                      size: 116,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: -10,
              top: 30,
              child: Opacity(
                opacity: 0.40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.kicker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.kickerColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                      letterSpacing: 0.50,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.63,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: ShapeDecoration(
                      color: item.ctaBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      shadows: [
                        BoxShadow(
                          color: item.ctaBg.withOpacity(0.30),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: item.ctaBg.withOpacity(0.30),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: Text(
                      item.ctaLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
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
}
