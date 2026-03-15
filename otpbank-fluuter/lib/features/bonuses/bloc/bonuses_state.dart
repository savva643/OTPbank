part of 'bonuses_bloc.dart';

enum BonusesStatus { initial, loading, ready, failure }

class BonusesState extends Equatable {
  const BonusesState({
    this.status = BonusesStatus.initial,
    this.stores = const [],
    this.balance,
    this.transactions = const [],
  });

  final BonusesStatus status;
  final List<Map<String, dynamic>> stores;
  final Map<String, dynamic>? balance;
  final List<Map<String, dynamic>> transactions;

  BonusesState copyWith({
    BonusesStatus? status,
    List<Map<String, dynamic>>? stores,
    Map<String, dynamic>? balance,
    List<Map<String, dynamic>>? transactions,
  }) {
    return BonusesState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [status, stores, balance, transactions];
}
