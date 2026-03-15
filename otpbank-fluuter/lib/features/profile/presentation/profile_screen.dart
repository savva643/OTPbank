import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../home/bloc/home_bloc.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../auth/presentation/avatar_picker_screen.dart';
import '../../security/presentation/security_settings_screen.dart';
import '../../devices/presentation/connected_devices_screen.dart';
import '../../login_history/presentation/login_history_screen.dart';
import '../../help/presentation/help_screen.dart';
import '../../chat/presentation/chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiClient();
  bool _loading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  ImageProvider? _getAvatarImageProvider() {
    final avatarUrl = _userData?['avatarUrl'];
    if (avatarUrl == null || avatarUrl.trim().isEmpty) return null;

    if (avatarUrl.startsWith('asset:')) {
      final assetPath = avatarUrl.substring('asset:'.length);
      if (assetPath.trim().isEmpty) return null;
      return AssetImage(assetPath);
    }

    if (avatarUrl.startsWith('file:')) {
      final path = avatarUrl.substring('file:'.length);
      if (path.trim().isEmpty) return null;
      // TODO: Add dart:io import if needed
      return null; // FileImage(File(path));
    }

    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return NetworkImage(avatarUrl);
    }

    return null;
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    try {
      final response = await _api.dio.get('/user/profile');
      _userData = response.data;
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateAvatar() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AvatarPickerScreen()),
    );
    
    if (result != null && result.isNotEmpty) {
      try {
        await _api.dio.put('/user/avatar', data: {'avatarUrl': result});
        await _loadUserData(); // Reload user data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Аватар обновлен')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при обновлении аватара')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _api.dio.post('/auth/logout');
      if (mounted) {
        // Clear stored tokens and navigate to login
        // TODO: Implement proper navigation to login screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выход выполнен')),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при выходе')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Профиль',
            onBack: () => Navigator.of(context).maybePop(),
            backHasBackground: true,
            actions: [
              SizedBox(
                width: 40,
                height: 40,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Profile content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // Avatar and name
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFC4FF2E), width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 25,
                                  offset: const Offset(0, 20),
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _getAvatarImageProvider(),
                              child: _getAvatarImageProvider() == null 
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person, size: 40, color: Color(0xFF64748B)),
                                  )
                                : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _updateAvatar,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC4FF2E),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userData?['name'] ?? _userData?['fullName'] ?? 'Алексей С.',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // User data section
                  _buildSection(
                    title: 'ВАШИ ДАННЫЕ',
                    children: [
                      _buildDataItem(
                        icon: Icons.phone_outlined,
                        label: 'ТЕЛЕФОН',
                        value: _userData?['phone'] ?? '+7 (900) 123-45-67',
                      ),
                      _buildDataItem(
                        icon: Icons.email_outlined,
                        label: 'ПОЧТА',
                        value: _userData?['email'] ?? 'alexey.s@example.com',
                      ),
                      _buildDataItem(
                        icon: Icons.location_on_outlined,
                        label: 'АДРЕС',
                        value: _userData?['address'] ?? 'г. Москва, ул. Ленина, д. 1',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Security section
                  _buildSection(
                    title: 'БЕЗОПАСНОСТЬ',
                    children: [
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Настройки безопасности',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.devices_outlined,
                        title: 'Подключенные устройства',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ConnectedDevicesScreen()),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.history_outlined,
                        title: 'История входов',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginHistoryScreen()),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support section
                  _buildSection(
                    title: 'ПОДДЕРЖКА И ПОМОЩЬ',
                    children: [
                      _buildMenuItem(
                        icon: Icons.support_agent_outlined,
                        title: 'Поддержка',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChatScreen()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_outlined,
                        title: 'Помощь',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HelpScreen()),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _logout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7D32).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: const Icon(Icons.logout_outlined, color: Color(0xFFFF7D32)),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Выйти',
                                style: TextStyle(
                                  color: Color(0xFFFF7D32),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Padding(
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
                      label,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (label != 'АДРЕС')
          Container(
            height: 1,
            color: const Color(0xFFF8FAFC),
          ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? iconColor,
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
                        color: iconColor ?? const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Icon(icon, color: iconColor ?? const Color(0xFF64748B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
}
