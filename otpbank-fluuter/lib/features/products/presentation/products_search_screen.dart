import 'package:flutter/material.dart';

import '../../../core/widgets/otp_search_input.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../domain/product_ui_config.dart';
import '../widgets/otp_product_tile.dart';
import 'product_details_screen.dart';

class ProductsSearchScreen extends StatefulWidget {
  const ProductsSearchScreen({super.key, required this.items});

  final List<String> items;

  @override
  State<ProductsSearchScreen> createState() => _ProductsSearchScreenState();
}

class _ProductsSearchScreenState extends State<ProductsSearchScreen> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.items
        : widget.items.where((e) => e.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OtpUniversalAppBar(
            title: 'Поиск по продуктам',
            backHasBackground: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OtpSearchInput(
              controller: _controller,
              autofocus: true,
              hintText: 'Поиск организации или услуги',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 120,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cfg = ProductUiConfig.byTitle(filtered[index]);
                return OtpProductTile(
                  product: cfg,
                  size: OtpProductTileSize.mediumWide,
                  subtitle: null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductDetailsScreen(
                          data: ProductDetailsMock.byTitle(cfg.title),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
