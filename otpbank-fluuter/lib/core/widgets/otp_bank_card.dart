import 'package:flutter/material.dart';

enum OtpBankCardVariant {
  dark,
  purple,
  orange,
}

class OtpBankCard extends StatefulWidget {
  const OtpBankCard({
    super.key,
    required this.title,
    required this.amount,
    required this.pan,
    this.variant = OtpBankCardVariant.dark,
    this.customGradient,
    this.onTap,
  });

  final String title;
  final String amount;
  final String pan;
  final OtpBankCardVariant variant;
  final Gradient? customGradient;
  final VoidCallback? onTap;

  Gradient get gradient {
    if (customGradient != null) return customGradient!;
    return switch (variant) {
      OtpBankCardVariant.dark => const LinearGradient(
          begin: Alignment(0.22, -0.22),
          end: Alignment(0.78, 1.22),
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      OtpBankCardVariant.purple => const LinearGradient(
          begin: Alignment(0.22, -0.22),
          end: Alignment(0.78, 1.22),
          colors: [Color(0xFF9E6FC3), Color(0xFF4F46E5)],
        ),
      OtpBankCardVariant.orange => const LinearGradient(
          begin: Alignment(0.22, -0.22),
          end: Alignment(0.78, 1.22),
          colors: [Color(0xFFFF7D32), Color(0xFF9E6FC3)],
        ),
    };
  }

  @override
  State<OtpBankCard> createState() => _OtpBankCardState();
}

class _OtpBankCardState extends State<OtpBankCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 228,
        height: 140,
        decoration: ShapeDecoration(
          gradient: widget.gradient,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 10,
              offset: Offset(0, 8),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 25,
              offset: Offset(0, 20),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (widget.variant == OtpBankCardVariant.dark)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(1.0, -1.0),
                          radius: 1.35,
                          colors: [
                            Color(0x55C4FF2E),
                            Color(0x1AC4FF2E),
                            Color(0x00000000),
                          ],
                          stops: [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.70,
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.33,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.amount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC4FF2E),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Center(
                          child: ImageIcon(
                            AssetImage('assets/img/minlogo.png'),
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        widget.pan,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          letterSpacing: 1.40,
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/img/Mir-logo.png',
                        width: 77,
                        height: 23,
                        fit: BoxFit.contain,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
