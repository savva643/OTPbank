import 'package:flutter/material.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Платежи')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Tile(title: 'Перевод на карту'),
          _Tile(title: 'Перевод по телефону'),
          _Tile(title: 'СБП перевод'),
          _Tile(title: 'Оплата услуг'),
          _Tile(title: 'Пополнение телефона'),
          _Tile(title: 'QR оплата'),
          _Tile(title: 'NFC оплата'),
        ],
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({required this.title});

  final String title;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.10),
        title: Text(widget.title),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
