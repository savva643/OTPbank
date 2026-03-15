part of 'bonuses_bloc.dart';

sealed class BonusesEvent extends Equatable {
  const BonusesEvent();

  @override
  List<Object?> get props => [];
}

final class BonusesRequested extends BonusesEvent {
  const BonusesRequested();
}
