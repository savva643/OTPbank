import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/otp_primary_button.dart';
import '../../../core/storage/pin_code_storage.dart';
import '../bloc/auth_bloc.dart';
import 'registration_screen.dart';
import 'pin_code_screen.dart';
import '../../splash/presentation/splash_greeting_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeCtrl = TextEditingController();

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
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
        if (state.status == AuthStatus.needsRegistration) {
          Navigator.of(context).pushReplacement(_fadeSlideRoute(const RegistrationScreen()));
        }

        if (state.status == AuthStatus.authorized) {
          Future<void>(() async {
            final nav = Navigator.of(context);
            final storedPin = await PinCodeStorage().getPin();
            if (!mounted) return;

            final mode = storedPin == null ? PinCodeMode.create : PinCodeMode.enter;
            Navigator.of(context).pushAndRemoveUntil(
              _fadeSlideRoute(
                PinCodeScreen(
                  mode: mode,
                  onSuccess: () {
                    nav.pushReplacement(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 320),
                        reverseTransitionDuration: const Duration(milliseconds: 320),
                        pageBuilder: (_, a, __) => FadeTransition(
                          opacity: a,
                          child: const SplashGreetingScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              (_) => false,
            );
          });
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
