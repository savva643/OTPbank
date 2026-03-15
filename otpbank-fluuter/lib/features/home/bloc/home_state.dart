part of 'home_bloc.dart';

enum HomeStatus { initial, loading, ready, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.userName,
    this.avatarUrl,
    this.accounts = const [],
    this.cards = const [],
    this.stories = const [],
    this.properties = const [],
    this.vehicles = const [],
    this.cashbackBalance,
    this.bonusPoints,
    this.recommendedTitle,
  });

  final HomeStatus status;
  final String? userName;
  final String? avatarUrl;
  final List<HomeAccountItem> accounts;
  final List<HomeCardItem> cards;
  final List<HomeStoryItem> stories;
  final List<HomePropertyItem> properties;
  final List<HomeVehicleItem> vehicles;
  final String? cashbackBalance;
  final int? bonusPoints;
  final String? recommendedTitle;

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    String? avatarUrl,
    List<HomeAccountItem>? accounts,
    List<HomeCardItem>? cards,
    List<HomeStoryItem>? stories,
    List<HomePropertyItem>? properties,
    List<HomeVehicleItem>? vehicles,
    String? cashbackBalance,
    int? bonusPoints,
    String? recommendedTitle,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accounts: accounts ?? this.accounts,
      cards: cards ?? this.cards,
      stories: stories ?? this.stories,
      properties: properties ?? this.properties,
      vehicles: vehicles ?? this.vehicles,
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      recommendedTitle: recommendedTitle ?? this.recommendedTitle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        userName,
        avatarUrl,
        accounts,
        cards,
        stories,
        properties,
        vehicles,
        cashbackBalance,
        bonusPoints,
        recommendedTitle,
      ];
}
