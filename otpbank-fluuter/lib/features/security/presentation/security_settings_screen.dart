import 'package:flutter/material.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _smsNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Безопасность',
            onBack: () => Navigator.of(context).maybePop(),
            backHasBackground: true,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // Authentication section
                  _buildSection(
                    title: 'АУТЕНТИФИКАЦИЯ',
                    children: [
                      _buildSwitchItem(
                        icon: Icons.fingerprint,
                        title: 'Биометрия',
                        subtitle: 'Использовать отпечаток пальца или Face ID',
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                        },
                      ),
                      _buildSwitchItem(
                        icon: Icons.security,
                        title: 'Двухфакторная аутентификация',
                        subtitle: 'Дополнительный код при входе',
                        value: _twoFactorEnabled,
                        onChanged: (value) {
                          setState(() {
                            _twoFactorEnabled = value;
                          });
                          if (value) {
                            _showTwoFactorDialog();
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notifications section
                  _buildSection(
                    title: 'УВЕДОМЛЕНИЯ О БЕЗОПАСНОСТИ',
                    children: [
                      _buildSwitchItem(
                        icon: Icons.sms,
                        title: 'SMS-уведомления',
                        subtitle: 'Получать SMS о подозрительной активности',
                        value: _smsNotifications,
                        onChanged: (value) {
                          setState(() {
                            _smsNotifications = value;
                          });
                        },
                      ),
                      _buildSwitchItem(
                        icon: Icons.email,
                        title: 'Email-уведомления',
                        subtitle: 'Получать письма о безопасности',
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Password section
                  _buildSection(
                    title: 'ПАРОЛЬ',
                    children: [
                      _buildMenuItem(
                        icon: Icons.lock,
                        title: 'Изменить пароль',
                        subtitle: 'Установить новый пароль',
                        onTap: () {
                          _showChangePasswordDialog();
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Advanced section
                  _buildSection(
                    title: 'ДОПОЛНИТЕЛЬНО',
                    children: [
                      _buildMenuItem(
                        icon: Icons.timer,
                        title: 'Автовыход',
                        subtitle: 'Через 5 минут бездействия',
                        onTap: () {
                          _showAutoLogoutDialog();
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.phone_android,
                        title: 'Доверенные устройства',
                        subtitle: 'Управление устройствами',
                        onTap: () {
                          _showTrustedDevicesDialog();
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Icon(icon, color: const Color(0xFF64748B), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFFC4FF2E),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 1,
          color: const Color(0xFFF8FAFC),
        ),
      ],
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Двухфакторная аутентификация'),
        content: const Text(
          'Двухфакторная аутентификация повышает безопасность вашего аккаунта. '
          'При каждом входе потребуется вводить код из SMS или приложения-аутентификатора.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _twoFactorEnabled = false;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Настроить'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменение пароля'),
        content: const Text('Функция изменения пароля будет доступна в следующем обновлении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAutoLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Автовыход'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите время автовыхода:'),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('1 минута'),
              value: '1',
              groupValue: '5',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('5 минут'),
              value: '5',
              groupValue: '5',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('15 минут'),
              value: '15',
              groupValue: '5',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Никогда'),
              value: 'never',
              groupValue: '5',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showTrustedDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Доверенные устройства'),
        content: const Text('Управление доверенными устройствами будет доступно в следующем обновлении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
