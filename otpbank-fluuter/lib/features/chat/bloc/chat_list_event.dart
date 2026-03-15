part of 'chat_list_bloc.dart';

sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

final class ChatListStarted extends ChatListEvent {
  const ChatListStarted();
}

final class ChatListFilterChanged extends ChatListEvent {
  final ChatFilter filter;
  const ChatListFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class ChatListSearchChanged extends ChatListEvent {
  final String query;
  const ChatListSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class ChatListRefreshed extends ChatListEvent {
  const ChatListRefreshed();
}
