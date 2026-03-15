part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, ready, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.categories = const [],
    this.catalog = const [],
    this.searchItems = const [],
    this.showcaseOffers = const [],
    this.recommended = const [],
    this.bottomProducts = const [],
  });

  final ProductsStatus status;
  final List<String> categories;
  final List<ProductCatalogCategory> catalog;
  final List<ProductSearchItem> searchItems;
  final List<ProductShowcaseOffer> showcaseOffers;
  final List<RecommendedProduct> recommended;
  final List<RecommendedProduct> bottomProducts;

  ProductsState copyWith({
    ProductsStatus? status,
    List<String>? categories,
    List<ProductCatalogCategory>? catalog,
    List<ProductSearchItem>? searchItems,
    List<ProductShowcaseOffer>? showcaseOffers,
    List<RecommendedProduct>? recommended,
    List<RecommendedProduct>? bottomProducts,
  }) {
    return ProductsState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      catalog: catalog ?? this.catalog,
      searchItems: searchItems ?? this.searchItems,
      showcaseOffers: showcaseOffers ?? this.showcaseOffers,
      recommended: recommended ?? this.recommended,
      bottomProducts: bottomProducts ?? this.bottomProducts,
    );
  }

  @override
  List<Object?> get props => [status, categories, catalog, searchItems, showcaseOffers, recommended, bottomProducts];
}
