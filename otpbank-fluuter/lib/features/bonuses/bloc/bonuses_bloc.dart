import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';

part 'bonuses_event.dart';
part 'bonuses_state.dart';

class BonusesBloc extends Bloc<BonusesEvent, BonusesState> {
  final ApiClient _api;

  BonusesBloc() : _api = ApiClient(), super(const BonusesState()) {
    on<BonusesRequested>(_onRequested);
  }

  Future<void> _onRequested(
    BonusesRequested event,
    Emitter<BonusesState> emit,
  ) async {
    emit(state.copyWith(status: BonusesStatus.loading));

    try {
      final results = await Future.wait([
        _api.dio.get('/bonuses/stores'),
        _api.dio.get('/bonuses/balance'),
        _api.dio.get('/bonuses/transactions'),
      ]);

      final storesRes = results[0];
      final balanceRes = results[1];
      final transactionsRes = results[2];

      final storesData = storesRes.data;
      final balanceData = balanceRes.data;
      final transactionsData = transactionsRes.data;

      final stores = storesData is Map && storesData['items'] is List
          ? List<Map<String, dynamic>>.from(storesData['items'])
          : <Map<String, dynamic>>[];

      final balance = balanceData is Map<String, dynamic> ? balanceData : null;

      final transactions = transactionsData is Map && transactionsData['items'] is List
          ? List<Map<String, dynamic>>.from(transactionsData['items'])
          : <Map<String, dynamic>>[];

      emit(state.copyWith(
        status: BonusesStatus.ready,
        stores: stores,
        balance: balance,
        transactions: transactions,
      ));
    } catch (_) {
      emit(state.copyWith(status: BonusesStatus.failure));
    }
  }
}
