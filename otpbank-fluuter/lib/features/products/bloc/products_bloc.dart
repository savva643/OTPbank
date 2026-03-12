import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc() : super(const ProductsState()) {
    on<ProductsRequested>(_onRequested);
  }

  Future<void> _onRequested(ProductsRequested event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      emit(
        state.copyWith(
          status: ProductsStatus.ready,
          categories: const [
            'Путешествия',
            'Покупка авто',
            'Покупка жилья',
            'Сбережения',
            'Инвестиции',
            'Семейные финансы',
            'Подписки',
            'Ежедневные траты',
          ],
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ProductsStatus.failure));
    }
  }
}
