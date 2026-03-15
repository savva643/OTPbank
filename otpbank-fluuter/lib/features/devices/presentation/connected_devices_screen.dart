import 'package:flutter/material.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  final List<Map<String, dynamic>> _devices = [
    {
      'name': 'iPhone 14 Pro',
      'type': 'Смартфон',
      'lastActive': 'Сейчас',
      'location': 'Москва, Россия',
      'isCurrent': true,
      'icon': Icons.smartphone,
    },
    {
      'name': 'MacBook Pro',
      'type': 'Ноутбук',
      'lastActive': '2 часа назад',
      'location': 'Москва, Россия',
      'isCurrent': false,
      'icon': Icons.laptop,
    },
    {
      'name': 'iPad Air',
      'type': 'Планшет',
      'lastActive': '1 день назад',
      'location': 'Санкт-Петербург, Россия',
      'isCurrent': false,
      'icon': Icons.tablet,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Подключенные устройства',
            onBack: () => Navigator.of(context).maybePop(),
            backHasBackground: true,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // Info section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4FF2E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC4FF2E).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC4FF2E),
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: const Icon(Icons.info_outline, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Здесь отображаются все устройства, вошедшие в ваш аккаунт.',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Devices list
                  _buildSection(
                    title: 'АКТИВНЫЕ УСТРОЙСТВА',
                    children: _devices.map((device) => _buildDeviceItem(device)).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Security actions
                  _buildSection(
                    title: 'БЕЗОПАСНОСТЬ',
                    children: [
                      _buildActionItem(
                        icon: Icons.logout,
                        title: 'Выйти со всех устройств',
                        subtitle: 'Завершить сеанс на всех устройствах кроме текущего',
                        onTap: () => _showLogoutAllDialog(),
                        color: const Color(0xFFFF7D32),
                      ),
                      _buildActionItem(
                        icon: Icons.block,
                        title: 'Заблокировать неизвестные устройства',
                        subtitle: 'Заблокировать устройства, которые вы не узнаете',
                        onTap: () => _showBlockDevicesDialog(),
                        color: const Color(0xFFEF4444),
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

  Widget _buildDeviceItem(Map<String, dynamic> device) {
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
              onTap: () => _showDeviceDetails(device),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: device['isCurrent'] 
                          ? const Color(0xFFC4FF2E).withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Icon(
                        device['icon'],
                        color: device['isCurrent'] 
                          ? const Color(0xFFC4FF2E)
                          : const Color(0xFF64748B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                device['name'],
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (device['isCurrent']) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC4FF2E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Текущее',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            device['type'],
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                device['lastActive'],
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                device['location'],
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!device['isCurrent']) ...[
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                        onSelected: (value) {
                          if (value == 'logout') {
                            _showLogoutDeviceDialog(device);
                          } else if (value == 'block') {
                            _showBlockDeviceDialog(device);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 16),
                                SizedBox(width: 8),
                                Text('Выйти'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                Icon(Icons.block, size: 16, color: Color(0xFFEF4444)),
                                SizedBox(width: 8),
                                Text('Заблокировать', style: TextStyle(color: Color(0xFFEF4444))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else
                      const Icon(Icons.check_circle, color: Color(0xFFC4FF2E)),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (device != _devices.last) // Don't add divider for last item
          Container(
            height: 1,
            color: const Color(0xFFF8FAFC),
          ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color color,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  void _showDeviceDetails(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Тип', device['type']),
            _buildDetailRow('Последний вход', device['lastActive']),
            _buildDetailRow('Местоположение', device['location']),
            _buildDetailRow('IP-адрес', '192.168.1.1'),
            _buildDetailRow('Браузер', 'Safari 16.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDeviceDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из устройства'),
        content: Text('Вы уверены, что хотите выйти из ${device['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Выход из ${device['name']} выполнен')),
              );
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showBlockDeviceDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Блокировка устройства'),
        content: Text('Вы уверены, что хотите заблокировать ${device['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${device['name']} заблокировано')),
              );
            },
            child: const Text('Заблокировать', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showLogoutAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход со всех устройств'),
        content: const Text('Вы уверены, что хотите выйти со всех устройств кроме текущего?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выход со всех устройств выполнен')),
              );
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _showBlockDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Блокировка устройств'),
        content: const Text('Все неизвестные устройства будут заблокированы. Продолжить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Неизвестные устройства заблокированы')),
              );
            },
            child: const Text('Заблокировать', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
