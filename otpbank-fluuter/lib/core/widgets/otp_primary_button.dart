import 'package:flutter/material.dart';

import '../theme/otp_colors.dart';

class OtpPrimaryButton extends StatefulWidget {
  const OtpPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  @override
  State<OtpPrimaryButton> createState() => _OtpPrimaryButtonState();
}

class _OtpPrimaryButtonState extends State<OtpPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: OtpColors.primaryLime,
        foregroundColor: const Color(0xFF0F172A),
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: widget.onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon),
            const SizedBox(width: 7),
          ],
          Text(
            widget.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
