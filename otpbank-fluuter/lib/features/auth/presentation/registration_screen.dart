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
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  final _birthDateCtrl = TextEditingController();

  String? _avatarUrl;

  String? _validateFullName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Укажи ФИО';
    final parts = value.split(RegExp(r'\s+')).where((p) => p.trim().isNotEmpty).toList();
    if (parts.length < 2) return 'Укажи фамилию и имя';
    if (value.length < 4) return 'Слишком короткое ФИО';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return null;
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
    if (!ok) return 'Неверный email';
    return null;
  }

  String? _formatBirthDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateCtrl.text = _formatBirthDate(picked) ?? '';
    });
  }

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
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
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
            _fadeSlideRoute(const RootShell()),
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
              child: Form(
                key: _formKey,
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
                      TextFormField(
                        controller: _fullNameCtrl,
                        validator: _validateFullName,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: 'ФИО *'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailCtrl,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: 'Email (необязательно)'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Мужской')),
                          DropdownMenuItem(value: 'female', child: Text('Женский')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                        decoration: const InputDecoration(hintText: 'Пол (необязательно)'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _birthDateCtrl,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        decoration: const InputDecoration(
                          hintText: 'Дата рождения (необязательно)',
                        ),
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
                                final ok = _formKey.currentState?.validate() ?? false;
                                if (!ok) return;

                                context.read<AuthBloc>().add(
                                      AuthRegistrationSubmitted(
                                        fullName: _fullNameCtrl.text.trim(),
                                        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
                                        gender: _gender,
                                        birthDate: _birthDate == null ? null : _formatBirthDate(_birthDate!),
                                        avatarUrl: _avatarUrl,
                                      ),
                                    );
                              },
                      ),
                    ],
                  ),
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
