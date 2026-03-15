import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiClient _api;

  SearchBloc() : _api = ApiClient(), super(const SearchState()) {
    on<SearchRequested>(_onSearch);
    on<SearchCleared>(_onClear);
  }

  Future<void> _onSearch(
    SearchRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading, query: event.query));

    try {
      // Search accounts
      final accountsRes = await _api.dio.get('/accounts');
      final accountsData = accountsRes.data;
      List<Map<String, dynamic>> accounts = [];
      if (accountsData is Map && accountsData['items'] is List) {
        final allAccounts = List<Map<String, dynamic>>.from(accountsData['items']);
        accounts = allAccounts.where((a) {
          final title = a['title']?.toString().toLowerCase() ?? '';
          return title.contains(event.query.toLowerCase());
        }).toList();
      }

      // Search cards
      final cardsRes = await _api.dio.get('/cards');
      final cardsData = cardsRes.data;
      List<Map<String, dynamic>> cards = [];
      if (cardsData is Map && cardsData['items'] is List) {
        final allCards = List<Map<String, dynamic>>.from(cardsData['items']);
        cards = allCards.where((c) {
          final title = c['accountTitle']?.toString().toLowerCase() ?? '';
          final number = c['maskedCardNumber']?.toString() ?? '';
          return title.contains(event.query.toLowerCase()) || number.contains(event.query);
        }).toList();
      }

      // Search transactions
      final txRes = await _api.dio.get('/transactions', queryParameters: {'limit': 50});
      final txData = txRes.data;
      List<Map<String, dynamic>> transactions = [];
      if (txData is Map && txData['items'] is List) {
        final allTx = List<Map<String, dynamic>>.from(txData['items']);
        transactions = allTx.where((t) {
          final merchant = t['merchantName']?.toString().toLowerCase() ?? '';
          final category = t['category']?.toString().toLowerCase() ?? '';
          return merchant.contains(event.query.toLowerCase()) || category.contains(event.query.toLowerCase());
        }).toList();
      }

      // Search stores
      final storesRes = await _api.dio.get('/bonuses/stores');
      final storesData = storesRes.data;
      List<Map<String, dynamic>> stores = [];
      if (storesData is Map && storesData['items'] is List) {
        final allStores = List<Map<String, dynamic>>.from(storesData['items']);
        stores = allStores.where((s) {
          final name = s['name']?.toString().toLowerCase() ?? '';
          return name.contains(event.query.toLowerCase());
        }).toList();
      }

      emit(state.copyWith(
        status: SearchStatus.ready,
        accounts: accounts,
        cards: cards,
        transactions: transactions,
        stores: stores,
      ));
    } catch (_) {
      emit(state.copyWith(status: SearchStatus.failure));
    }
  }

  void _onClear(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }
}
