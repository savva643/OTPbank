import 'package:flutter/material.dart';

class OtpSquareActionButton extends StatelessWidget {
  const OtpSquareActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconWidget,
    this.primary = false,
    this.onTap,
    this.disabled = false,
  });

  final String label;
  final IconData icon;
  final Widget? iconWidget;
  final bool primary;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? const Color(0x19C1FF05) : const Color(0xFFF1F5F9);
    final border = primary ? const Color(0x33C1FF05) : const Color(0xFFF1F5F9);
    final labelColor = primary ? const Color(0xFF0F172A) : const Color(0xFF475569);
    final fw = primary ? FontWeight.w800 : FontWeight.w600;

    final handleTap = disabled ? null : (onTap ?? () {});

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleTap,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: handleTap,
              child: Ink(
                width: 56,
                height: 56,
                decoration: ShapeDecoration(
                  color: bg,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Center(
                  child: iconWidget ?? Icon(icon, color: const Color(0xFF0F172A), size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: fw,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
