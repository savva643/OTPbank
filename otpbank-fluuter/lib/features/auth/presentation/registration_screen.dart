import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/otp_primary_button.dart';
import '../bloc/auth_bloc.dart';
import 'avatar_picker_screen.dart';
import '../../shell/presentation/root_shell.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();

  String? _avatarUrl;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _genderCtrl.dispose();
    _birthDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.status != next.status,
      listener: (context, state) {
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
            appBar: AppBar(title: const Text('Регистрация')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Почти готово',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Заполни данные профиля.\nНекоторые поля можно оставить пустыми.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _AvatarPreview(avatarUrl: _avatarUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Аватар',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                avatarProviderLabel(_avatarUrl) ?? 'Не выбран',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () async {
                              final v = await Navigator.of(context).push<String>(
                                MaterialPageRoute<String>(
                                  builder: (_) => const AvatarPickerScreen(),
                                ),
                              );
                              if (v == null) return;
                              if (!context.mounted) return;
                              setState(() => _avatarUrl = v);
                            },
                            child: const Text('Выбрать'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fullNameCtrl,
                      decoration: const InputDecoration(hintText: 'ФИО *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email (необязательно)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _genderCtrl,
                      decoration: const InputDecoration(hintText: 'Пол (необязательно)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _birthDateCtrl,
                      decoration: const InputDecoration(hintText: 'Дата рождения YYYY-MM-DD (необязательно)'),
                    ),
                    const Spacer(),
                    if (state.status == AuthStatus.failure)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Не удалось завершить регистрацию.',
                          style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                        ),
                      ),
                    OtpPrimaryButton(
                      label: state.status == AuthStatus.loading ? 'Создаём...' : 'Создать аккаунт',
                      onPressed: state.status == AuthStatus.loading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                    AuthRegistrationSubmitted(
                                      fullName: _fullNameCtrl.text.trim(),
                                      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
                                      gender: _genderCtrl.text.trim().isEmpty ? null : _genderCtrl.text.trim(),
                                      birthDate: _birthDateCtrl.text.trim().isEmpty
                                          ? null
                                          : _birthDateCtrl.text.trim(),
                                      avatarUrl: _avatarUrl,
                                    ),
                                  );
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

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (avatarUrl != null && avatarUrl!.startsWith('asset:')) {
      final assetPath = avatarUrl!.substring('asset:'.length);
      child = ClipOval(
        child: Image.asset(
          assetPath,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const _AvatarFallback();
          },
        ),
      );
    } else {
      child = const _AvatarFallback();
    }

    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(child: child),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 24,
      backgroundColor: Color(0xFFF1F5F9),
      child: Icon(Icons.person_rounded, color: Color(0xFF0F172A)),
    );
  }
}
