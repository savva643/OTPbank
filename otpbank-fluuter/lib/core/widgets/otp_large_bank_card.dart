import 'package:flutter/material.dart';

import 'otp_bank_card.dart';

class OtpLargeBankCard extends StatelessWidget {
  const OtpLargeBankCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.variant,
    required this.pan,
    required this.validThru,
  });

  final String title;
  final String subtitle;
  final OtpBankCardVariant variant;
  final String pan;
  final String validThru;

  Gradient get _gradient {
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

  List<String> _panParts(String pan) {
    final digits = pan.replaceAll(' ', '');
    if (digits.length >= 4) return ['****', '****', '****', digits.substring(digits.length - 4)];
    return ['****', '****', '****', pan];
  }

  @override
  Widget build(BuildContext context) {
    final parts = _panParts(pan);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 50,
              offset: Offset(0, 25),
              spreadRadius: -12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _gradient),
                ),
              ),
              if (variant == OtpBankCardVariant.dark)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
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
              Padding(
                padding: const EdgeInsets.all(24),
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
                                  title.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.33,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 48,
                                height: 32,
                                decoration: ShapeDecoration(
                                  color: const Color(0x33C1FF05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.contactless_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          'assets/img/logo.png',
                          width: 100,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        for (int i = 0; i < parts.length; i++) ...[
                          Text(
                            parts[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              letterSpacing: 4,
                            ),
                          ),
                          if (i != parts.length - 1) const SizedBox(width: 10),
                        ]
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.60,
                              child: Text(
                                'VALID THRU',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              validThru,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Image.asset(
                          'assets/img/Mir-logo.png',
                          width: 77,
                          height: 23,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
