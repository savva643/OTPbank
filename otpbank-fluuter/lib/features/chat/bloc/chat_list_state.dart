part of 'chat_list_bloc.dart';

enum ChatListStatus { initial, loading, loaded, error }

enum ChatFilter { all, active, completed, archived }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatConversation> allChats;
  final List<ChatConversation> filteredChats;
  final ChatFilter filter;
  final String searchQuery;
  final String? errorMessage;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.allChats = const [],
    this.filteredChats = const [],
    this.filter = ChatFilter.active,
    this.searchQuery = '',
    this.errorMessage,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatConversation>? allChats,
    List<ChatConversation>? filteredChats,
    ChatFilter? filter,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      allChats: allChats ?? this.allChats,
      filteredChats: filteredChats ?? this.filteredChats,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allChats,
        filteredChats,
        filter,
        searchQuery,
        errorMessage,
      ];
}
