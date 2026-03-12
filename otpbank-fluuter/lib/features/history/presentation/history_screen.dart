import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TxTile(title: 'Coffee Shop', subtitle: 'Еда', amount: '-250 ₽'),
          _TxTile(title: 'Salary', subtitle: 'Доход', amount: '+120 000 ₽'),
        ],
      ),
    );
  }
}

class _TxTile extends StatefulWidget {
  const _TxTile({required this.title, required this.subtitle, required this.amount});

  final String title;
  final String subtitle;
  final String amount;

  @override
  State<_TxTile> createState() => _TxTileState();
}

class _TxTileState extends State<_TxTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Theme.of(context).colorScheme.surface,
        title: Text(widget.title),
        subtitle: Text(widget.subtitle),
        trailing: Text(widget.amount, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
