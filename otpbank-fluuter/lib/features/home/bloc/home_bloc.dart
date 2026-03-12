import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeRequested>(_onHomeRequested);
  }

  Future<void> _onHomeRequested(HomeRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      emit(
        state.copyWith(
          status: HomeStatus.ready,
          userName: 'Пользователь',
          avatarUrl: null,
          cashbackBalance: '0',
          bonusPoints: 0,
          recommendedTitle: 'Дебетовая карта для путешествий',
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}
