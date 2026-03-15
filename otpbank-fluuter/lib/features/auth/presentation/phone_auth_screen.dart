import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/otp_colors.dart';
import '../../../core/widgets/otp_primary_button.dart';
import '../bloc/auth_bloc.dart';
import 'verify_code_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneCtrl = TextEditingController(text: '+7');

  PageRoute<void> _fadeSlideRoute(Widget child) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: fade.drive(slide), child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status == AuthStatus.codeRequested) {
          Navigator.of(context).push(_fadeSlideRoute(const VerifyCodeScreen()));
        }
      },
      child: Builder(
        builder: (context) {
          final state = context.watch<AuthBloc>().state;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [ 
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'assets/img/logo.png',
                            height: 44,
                            color: Colors.black,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Вход',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Введите номер телефона — мы отправим код подтверждения',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: '+7 999 000-00-00',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (state.status == AuthStatus.failure)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Не удалось отправить код. Проверь номер и попробуй ещё раз.',
                          style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                        ),
                      ),
                    OtpPrimaryButton(
                      label: state.status == AuthStatus.loading ? 'Отправляем...' : 'Получить код',
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () {
                              final phone = _phoneCtrl.text.trim();
                              context.read<AuthBloc>().add(AuthPhoneSubmitted(phone));
                            },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Нажимая «Получить код», вы соглашаетесь с условиями сервиса.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
