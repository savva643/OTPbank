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
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const VerifyCodeScreen()),
          );
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: OtpColors.primaryLime,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Icon(Icons.lock_rounded, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Вход',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Введите номер телефона —\nмы отправим код подтверждения',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+7 999 000-00-00',
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
