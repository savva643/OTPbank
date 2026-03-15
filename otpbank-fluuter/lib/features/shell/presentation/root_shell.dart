import 'package:flutter/material.dart';

import '../../chat/presentation/chat_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../payments/presentation/payments_screen.dart';
import '../../products/presentation/products_screen.dart';
import '../../business/presentation/business_screen.dart';
import '../../../core/theme/otp_colors.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  static RootShellState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<RootShellState>();
  }

  @override
  State<RootShell> createState() => RootShellState();
}

class RootShellState extends State<RootShell> {
  int _index = 0;

  void setIndex(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  late final List<Widget> _pages = const [
    HomeScreen(),
    PaymentsScreen(),
    HistoryScreen(),
    ChatListScreen(),
    ProductsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: OtpColors.purpleAccent,
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: setIndex,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/img/minlogo.png')),
            label: 'Главная',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payments_rounded), label: 'Платежи'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Чат'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Продукты'),
        ],
      ),
    );
  }
}
