import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import 'home_tab_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeRequested());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;

    return Scaffold(
      body: Stack(
        children: [
          const HomeTabContent(),
          if (state.status == HomeStatus.loading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.white.withOpacity(0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
