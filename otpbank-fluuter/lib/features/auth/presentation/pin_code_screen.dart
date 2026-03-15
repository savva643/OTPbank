import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../../core/storage/pin_code_storage.dart';
import '../../../core/theme/otp_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../splash/presentation/splash_screen.dart';

enum PinCodeMode {
  create,
  confirm,
  enter,
}

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({
    super.key,
    required this.mode,
    this.firstPin,
    this.onSuccess,
  });

  final PinCodeMode mode;
  final String? firstPin;
  final VoidCallback? onSuccess;

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  static const _pinLength = 4;

  final _entered = <int>[];
  bool _error = false;
  bool _busy = false;

  String get _title {
    switch (widget.mode) {
      case PinCodeMode.create:
        return 'Создайте PIN-код';
      case PinCodeMode.confirm:
        return 'Повторите PIN-код';
      case PinCodeMode.enter:
        return 'Введите PIN-код';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case PinCodeMode.create:
        return '4 цифры для быстрого входа';
      case PinCodeMode.confirm:
        return 'Введите PIN ещё раз';
      case PinCodeMode.enter:
        return 'Для входа в приложение';
    }
  }

  Future<void> _handleComplete() async {
    if (_busy) return;
    final pin = _entered.join();

    setState(() {
      _busy = true;
      _error = false;
    });

    try {
      if (widget.mode == PinCodeMode.create) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 260),
            reverseTransitionDuration: const Duration(milliseconds: 260),
            pageBuilder: (_, a, __) => FadeTransition(
              opacity: a,
              child: PinCodeScreen(mode: PinCodeMode.confirm, firstPin: pin, onSuccess: widget.onSuccess),
            ),
          ),
        );
        return;
      }

      if (widget.mode == PinCodeMode.confirm) {
        final first = widget.firstPin ?? '';
        if (first != pin) {
          setState(() {
            _error = true;
            _entered.clear();
          });
          return;
        }

        await PinCodeStorage().setPin(pin);
        widget.onSuccess?.call();
        return;
      }

      if (widget.mode == PinCodeMode.enter) {
        final stored = await PinCodeStorage().getPin();
        if (stored == null || stored != pin) {
          setState(() {
            _error = true;
            _entered.clear();
          });
          return;
        }

        widget.onSuccess?.call();
        return;
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
    }
  }

  void _addDigit(int d) {
    if (_busy) return;
    if (_entered.length >= _pinLength) return;
    setState(() {
      _error = false;
      _entered.add(d);
    });
    if (_entered.length == _pinLength) {
      _handleComplete();
    }
  }

  void _backspace() {
    if (_busy) return;
    if (_entered.isEmpty) return;
    setState(() {
      _error = false;
      _entered.removeLast();
    });
  }

  Future<void> _logout() async {
    if (_busy) return;
    await AuthTokenStorage().clear();
    await PinCodeStorage().clear();
    if (!mounted) return;

    context.read<AuthBloc>().add(const AuthLoggedOut());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnter = widget.mode == PinCodeMode.enter;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/img/logo.png',
                  height: 44,
                  color: Colors.black,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              _PinDots(count: _pinLength, filled: _entered.length, error: _error),
              const SizedBox(height: 14),
              AnimatedOpacity(
                opacity: _error ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Text(
                  'Неверный PIN-код',
                  style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final spacing = 12.0;
                    final rows = 4;
                    const bottomGap = 12.0;
                    const bottomButtonHeight = 44.0;

                    final availableForKeypad =
                        (c.maxHeight - bottomGap - bottomButtonHeight).clamp(0.0, double.infinity);
                    final keyHeight =
                        ((availableForKeypad - spacing * (rows - 1)) / rows).clamp(40.0, 68.0);
                    return Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _NumericKeypad(
                              onDigit: _addDigit,
                              onBackspace: _backspace,
                              enabled: !_busy,
                              keyHeight: keyHeight,
                              spacing: spacing,
                            ),
                          ),
                        ),
                        const SizedBox(height: bottomGap),
                        SizedBox(
                          height: bottomButtonHeight,
                          child: isEnter
                              ? TextButton(
                                  onPressed: _logout,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF7D32),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  child: const Text('Выйти'),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.count,
    required this.filled,
    required this.error,
  });

  final int count;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? (error ? const Color(0xFFDC2626) : const Color(0xFF0F172A)) : const Color(0xFFE2E8F0),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: (error ? const Color(0xFFDC2626) : OtpColors.primaryLime).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      spreadRadius: -6,
                    ),
                  ]
                : const [],
          ),
        );
      }),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.enabled,
    required this.keyHeight,
    required this.spacing,
  });

  final void Function(int digit) onDigit;
  final VoidCallback onBackspace;
  final bool enabled;
  final double keyHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    Widget key({int? digit, IconData? icon, VoidCallback? onTap}) {
      final child = digit != null
          ? Text(
              digit.toString(),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            )
          : Icon(icon, color: const Color(0xFF0F172A));

      return Expanded(
        child: Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: keyHeight,
              child: Center(child: child),
            ),
          ),
        ),
      );
    }

    Widget row(List<Widget> children) {
      return Row(
        children: [
          children[0],
          SizedBox(width: spacing),
          children[1],
          SizedBox(width: spacing),
          children[2],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          key(digit: 1, onTap: () => onDigit(1)),
          key(digit: 2, onTap: () => onDigit(2)),
          key(digit: 3, onTap: () => onDigit(3)),
        ]),
        SizedBox(height: spacing),
        row([
          key(digit: 4, onTap: () => onDigit(4)),
          key(digit: 5, onTap: () => onDigit(5)),
          key(digit: 6, onTap: () => onDigit(6)),
        ]),
        SizedBox(height: spacing),
        row([
          key(digit: 7, onTap: () => onDigit(7)),
          key(digit: 8, onTap: () => onDigit(8)),
          key(digit: 9, onTap: () => onDigit(9)),
        ]),
        SizedBox(height: spacing),
        row([
          const Expanded(child: SizedBox.shrink()),
          key(digit: 0, onTap: () => onDigit(0)),
          key(icon: Icons.backspace_outlined, onTap: onBackspace),
        ]),
      ],
    );
  }
}
