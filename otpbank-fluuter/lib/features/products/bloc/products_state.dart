part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, ready, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.categories = const [],
  });

  final ProductsStatus status;
  final List<String> categories;

  ProductsState copyWith({
    ProductsStatus? status,
    List<String>? categories,
  }) {
    return ProductsState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [status, categories];
}
