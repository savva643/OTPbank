import 'package:flutter/material.dart';

class OtpUniversalAppBar extends StatelessWidget {
  const OtpUniversalAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.backHasBackground = false,
    this.backgroundColor,
    this.textColor = const Color(0xFF0F172A),
  });

  final String title;
  final VoidCallback? onBack;
  final bool backHasBackground;
  final Color? backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: backHasBackground ? Colors.white.withOpacity(0.20) : Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
