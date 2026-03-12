import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/otp_primary_button.dart';
import '../bloc/auth_bloc.dart';
import 'registration_screen.dart';
import '../../shell/presentation/root_shell.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status == AuthStatus.needsRegistration) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const RegistrationScreen()),
          );
        }

        if (state.status == AuthStatus.authorized) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const RootShell()),
            (_) => false,
          );
        }
      },
      child: Builder(
        builder: (context) {
          final state = context.watch<AuthBloc>().state;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Подтверждение'),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Код отправлен на номер\n${state.phone ?? ''}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Не сообщайте код никому — даже сотрудникам банка.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Код из SMS',
                      ),
                    ),
                    const Spacer(),
                    if (state.status == AuthStatus.failure)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Неверный код или код истёк.',
                          style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                        ),
                      ),
                    OtpPrimaryButton(
                      label: state.status == AuthStatus.loading ? 'Проверяем...' : 'Продолжить',
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(AuthCodeSubmitted(_codeCtrl.text.trim()));
                            },
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
