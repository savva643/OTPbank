part of 'search_bloc.dart';

enum SearchStatus { initial, loading, ready, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.accounts = const [],
    this.cards = const [],
    this.transactions = const [],
    this.stores = const [],
  });

  final SearchStatus status;
  final String query;
  final List<Map<String, dynamic>> accounts;
  final List<Map<String, dynamic>> cards;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> stores;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Map<String, dynamic>>? accounts,
    List<Map<String, dynamic>>? cards,
    List<Map<String, dynamic>>? transactions,
    List<Map<String, dynamic>>? stores,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      accounts: accounts ?? this.accounts,
      cards: cards ?? this.cards,
      transactions: transactions ?? this.transactions,
      stores: stores ?? this.stores,
    );
  }

  @override
  List<Object?> get props => [status, query, accounts, cards, transactions, stores];
}
