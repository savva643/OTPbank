import 'package:flutter/material.dart';

enum OtpRoundActionStyle {
  primary,
  secondary,
  purple,
}

class OtpRoundActionButton extends StatefulWidget {
  const OtpRoundActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.style = OtpRoundActionStyle.secondary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final OtpRoundActionStyle style;

  @override
  State<OtpRoundActionButton> createState() => _OtpRoundActionButtonState();
}

class _OtpRoundActionButtonState extends State<OtpRoundActionButton> {
  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (widget.style) {
      OtpRoundActionStyle.primary => (const Color(0xFFC4FF2E), const Color(0xFF0F172A)),
      OtpRoundActionStyle.purple => (const Color(0xFF9E6FC3), Colors.white),
      OtpRoundActionStyle.secondary => (const Color(0xFFF1F5F9), const Color(0xFF0F172A)),
    };

    return InkWell(
      onTap: widget.onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkResponse(
              onTap: widget.onTap,
              containedInkWell: true,
              customBorder: const CircleBorder(),
              radius: 30,
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  boxShadow: widget.style == OtpRoundActionStyle.primary
                      ? const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Icon(widget.icon, size: 22, color: fg),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}
