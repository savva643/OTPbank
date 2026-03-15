import 'package:flutter/material.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  final List<Map<String, dynamic>> _loginHistory = [
    {
      'date': '15 марта 2026',
      'time': '21:30',
      'device': 'iPhone 14 Pro',
      'location': 'Москва, Россия',
      'ip': '192.168.1.1',
      'status': 'success',
      'browser': 'Safari 16.0',
      'isCurrent': true,
    },
    {
      'date': '15 марта 2026',
      'time': '18:45',
      'device': 'MacBook Pro',
      'location': 'Москва, Россия',
      'ip': '192.168.1.2',
      'status': 'success',
      'browser': 'Chrome 120.0',
      'isCurrent': false,
    },
    {
      'date': '14 марта 2026',
      'time': '22:15',
      'device': 'iPad Air',
      'location': 'Санкт-Петербург, Россия',
      'ip': '192.168.1.3',
      'status': 'success',
      'browser': 'Safari 16.0',
      'isCurrent': false,
    },
    {
      'date': '14 марта 2026',
      'time': '15:30',
      'device': 'Android Phone',
      'location': 'Казань, Россия',
      'ip': '192.168.1.4',
      'status': 'failed',
      'browser': 'Chrome Mobile',
      'isCurrent': false,
    },
    {
      'date': '13 марта 2026',
      'time': '09:00',
      'device': 'Windows PC',
      'location': 'Новосибирск, Россия',
      'ip': '192.168.1.5',
      'status': 'success',
      'browser': 'Edge 120.0',
      'isCurrent': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'История входов',
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
                            'Здесь отображается история всех входов в ваш аккаунт.',
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
                  
                  // Filter buttons
                  _buildFilterButtons(),
                  
                  const SizedBox(height: 24),
                  
                  // Login history list
                  _buildSection(
                    title: 'ИСТОРИЯ ВХОДОВ',
                    children: _loginHistory.map((entry) => _buildHistoryItem(entry)).toList(),
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

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(
          child: FilterChip(
            label: const Text('Все'),
            selected: true,
            onSelected: (selected) {},
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFFC4FF2E).withValues(alpha: 0.2),
            labelStyle: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
            side: const BorderSide(color: Color(0xFFC4FF2E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterChip(
            label: const Text('Успешные'),
            selected: false,
            onSelected: (selected) {},
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
            labelStyle: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterChip(
            label: const Text('Неудачные'),
            selected: false,
            onSelected: (selected) {},
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFFEF4444).withValues(alpha: 0.2),
            labelStyle: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
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

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final isSuccess = entry['status'] == 'success';
    final isCurrent = entry['isCurrent'] == true;
    
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
              onTap: () => _showEntryDetails(entry),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSuccess 
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Icon(
                            isSuccess ? Icons.check_circle : Icons.error,
                            color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry['date'],
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry['time'],
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC4FF2E),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Текущий',
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
                                entry['device'],
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      entry['location'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.computer,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      entry['browser'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                    if (!isSuccess) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Неудачная попытка входа. Неверный пароль.',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (entry != _loginHistory.last) // Don't add divider for last item
          Container(
            height: 1,
            color: const Color(0xFFF8FAFC),
          ),
      ],
    );
  }

  void _showEntryDetails(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Детали входа - ${entry['date']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Дата', '${entry['date']} в ${entry['time']}'),
            _buildDetailRow('Устройство', entry['device']),
            _buildDetailRow('Браузер', entry['browser']),
            _buildDetailRow('Местоположение', entry['location']),
            _buildDetailRow('IP-адрес', entry['ip']),
            _buildDetailRow('Статус', entry['status'] == 'success' ? 'Успешно' : 'Неудачно'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          if (!entry['isCurrent'] && entry['status'] == 'success') ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showBlockDeviceDialog(entry);
              },
              child: const Text('Заблокировать', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
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

  void _showBlockDeviceDialog(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Блокировка устройства'),
        content: Text('Заблокировать устройство ${entry['device']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${entry['device']} заблокировано')),
              );
            },
            child: const Text('Заблокировать', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
