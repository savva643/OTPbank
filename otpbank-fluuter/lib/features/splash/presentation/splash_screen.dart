import 'package:flutter/material.dart';

import '../../../core/theme/otp_colors.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../auth/presentation/phone_auth_screen.dart';
import '../../shell/presentation/root_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });

    Future<void>.delayed(const Duration(milliseconds: 1050), () async {
      if (!mounted) return;

      final token = await AuthTokenStorage().getAccessToken();
      if (!mounted) return;

      final next = token != null ? const RootShell() : const PhoneAuthScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (context, animation, secondaryAnimation) => next,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        )
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtpColors.primaryLime,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 380),
            child: AnimatedScale(
              scale: _visible ? 1 : 0.92,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOut,
              child: Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/img/logo.png',
                  width: 184,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
