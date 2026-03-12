part of 'home_bloc.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userName,
    this.avatarUrl,
    this.cashbackBalance,
    this.bonusPoints,
    this.recommendedTitle,
  });

  final HomeStatus status;
  final String? userName;
  final String? avatarUrl;
  final String? cashbackBalance;
  final int? bonusPoints;
  final String? recommendedTitle;

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    String? avatarUrl,
    String? cashbackBalance,
    int? bonusPoints,
    String? recommendedTitle,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      recommendedTitle: recommendedTitle ?? this.recommendedTitle,
    );
  }

  @override
  List<Object?> get props => [status, userName, avatarUrl, cashbackBalance, bonusPoints, recommendedTitle];
}
