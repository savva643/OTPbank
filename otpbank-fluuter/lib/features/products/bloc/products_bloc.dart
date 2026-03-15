import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductShowcaseOffer extends Equatable {
  const ProductShowcaseOffer({
    required this.id,
    required this.productId,
    required this.kicker,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.borderColor,
    required this.ctaLabel,
    required this.ctaColor,
    required this.productName,
    required this.categoryName,
  });

  final String id;
  final String productId;
  final String kicker;
  final String title;
  final String description;
  final String? bgColor;
  final String? borderColor;
  final String ctaLabel;
  final String? ctaColor;
  final String productName;
  final String? categoryName;

  @override
  List<Object?> get props => [
        id,
        productId,
        kicker,
        title,
        description,
        bgColor,
        borderColor,
        ctaLabel,
        ctaColor,
        productName,
        categoryName,
      ];
}

class RecommendedProduct extends Equatable {
  const RecommendedProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryName,
  });

  final String? id;
  final String title;
  final String? description;
  final String? categoryName;

  @override
  List<Object?> get props => [id, title, description, categoryName];
}

class ProductSearchItem extends Equatable {
  const ProductSearchItem({
    required this.id,
    required this.title,
    required this.categoryName,
  });

  final String id;
  final String title;
  final String? categoryName;

  @override
  List<Object?> get props => [id, title, categoryName];
}

class ProductCatalogProduct extends Equatable {
  const ProductCatalogProduct({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String? description;

  @override
  List<Object?> get props => [id, title, description];
}

class ProductCatalogCategory extends Equatable {
  const ProductCatalogCategory({
    required this.id,
    required this.name,
    required this.products,
  });

  final String id;
  final String name;
  final List<ProductCatalogProduct> products;

  @override
  List<Object?> get props => [id, name, products];
}

int? _parseHexColorToInt(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty) return null;
  final normalized = v.startsWith('#') ? v.substring(1) : v;
  if (normalized.length == 6) {
    return int.tryParse('FF$normalized', radix: 16);
  }
  if (normalized.length == 8) {
    return int.tryParse(normalized, radix: 16);
  }
  return null;
}

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(const ProductsState()) {
    on<ProductsRequested>(_onRequested);
  }

  final ApiClient _apiClient;

  Future<void> _onRequested(ProductsRequested event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final listRes = await _apiClient.dio.get('/products');
      final showcaseRes = await _apiClient.dio.get('/products/showcase');
      final recRes = await _apiClient.dio.get('/products/recommended');

      final categories = <String>[];
      final catalog = <ProductCatalogCategory>[];
      final searchItems = <ProductSearchItem>[];
      final listData = listRes.data;
      if (listData is Map && listData['items'] is List) {
        for (final c in (listData['items'] as List)) {
          if (c is! Map) continue;

          final id = c['id']?.toString();
          final name = c['name']?.toString();
          if (id == null || name == null || name.trim().isEmpty) continue;
          categories.add(name.trim());

          final products = <ProductCatalogProduct>[];
          final offers = c['offers'];
          if (offers is List) {
            for (final p in offers) {
              if (p is! Map) continue;
              final pid = p['id']?.toString();
              final pName = p['name']?.toString();
              if (pid == null || pName == null || pName.trim().isEmpty) continue;
              final title = pName.trim();
              final desc = p['description']?.toString();
              products.add(ProductCatalogProduct(id: pid, title: title, description: desc));
              searchItems.add(ProductSearchItem(id: pid, title: title, categoryName: name.trim()));
            }
          }

          catalog.add(ProductCatalogCategory(id: id, name: name.trim(), products: products));
        }
      }

      final showcaseOffers = <ProductShowcaseOffer>[];
      final bottomProducts = <RecommendedProduct>[];
      final showcaseData = showcaseRes.data;
      if (showcaseData is Map && showcaseData['items'] is List) {
        for (final item in (showcaseData['items'] as List)) {
          if (item is! Map) continue;
          final product = item['product'];
          final productName = product is Map ? product['name']?.toString() : null;
          final categoryName = (product is Map && product['category'] is Map)
              ? (product['category'] as Map)['name']?.toString()
              : null;

          final id = item['id']?.toString();
          final productId = item['productId']?.toString();
          final kicker = item['kicker']?.toString();
          final title = item['title']?.toString();
          final description = item['description']?.toString();
          final ctaLabel = item['ctaLabel']?.toString();

          if (id == null || productId == null || kicker == null || title == null || description == null) {
            continue;
          }

          showcaseOffers.add(
            ProductShowcaseOffer(
              id: id,
              productId: productId,
              kicker: kicker,
              title: title,
              description: description,
              bgColor: item['bgColor']?.toString(),
              borderColor: item['borderColor']?.toString(),
              ctaLabel: (ctaLabel == null || ctaLabel.trim().isEmpty) ? 'Подробнее' : ctaLabel,
              ctaColor: item['ctaColor']?.toString(),
              productName: (productName == null || productName.trim().isEmpty) ? title : productName,
              categoryName: categoryName,
            ),
          );

          if (bottomProducts.length < 4) {
            bottomProducts.add(
              RecommendedProduct(
                id: product is Map ? product['id']?.toString() : null,
                title: (productName == null || productName.trim().isEmpty) ? title : productName,
                description: (product is Map) ? product['description']?.toString() : null,
                categoryName: categoryName,
              ),
            );
          }
        }
      }

      final recommended = <RecommendedProduct>[];
      final recData = recRes.data;
      if (recData is Map) {
        final categoryName = (recData['category'] is Map) ? (recData['category'] as Map)['name']?.toString() : null;
        final title = recData['title']?.toString() ?? 'Рекомендация';
        recommended.add(
          RecommendedProduct(
            id: recData['id']?.toString(),
            title: title,
            description: recData['description']?.toString(),
            categoryName: categoryName,
          ),
        );
      }

      emit(
        state.copyWith(
          status: ProductsStatus.ready,
          categories: categories,
          catalog: catalog,
          searchItems: searchItems,
          showcaseOffers: showcaseOffers,
          recommended: recommended,
          bottomProducts: bottomProducts,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ProductsStatus.failure));
    }
  }
}
