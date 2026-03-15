import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

/// Модель чата для списка
class ChatConversation extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? tag;
  final String? tagColor;
  final bool isSupport;
  final ChatStatus status;

  const ChatConversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.tag,
    this.tagColor,
    this.isSupport = false,
    this.status = ChatStatus.active,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isOnline,
        tag,
        tagColor,
        isSupport,
        status,
      ];

  ChatConversation copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    String? tag,
    String? tagColor,
    bool? isSupport,
    ChatStatus? status,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      tag: tag ?? this.tag,
      tagColor: tagColor ?? this.tagColor,
      isSupport: isSupport ?? this.isSupport,
      status: status ?? this.status,
    );
  }
}

enum ChatStatus { active, completed, archived }

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc() : super(const ChatListState()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListFilterChanged>(_onFilterChanged);
    on<ChatListSearchChanged>(_onSearchChanged);
    on<ChatListRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(ChatListStarted event, Emitter<ChatListState> emit) async {
    emit(state.copyWith(status: ChatListStatus.loading));
    await _loadChats(emit);
  }

  Future<void> _onFilterChanged(ChatListFilterChanged event, Emitter<ChatListState> emit) async {
    emit(state.copyWith(filter: event.filter));
    await _applyFilters(emit);
  }

  Future<void> _onSearchChanged(ChatListSearchChanged event, Emitter<ChatListState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    await _applyFilters(emit);
  }

  Future<void> _onRefreshed(ChatListRefreshed event, Emitter<ChatListState> emit) async {
    await _loadChats(emit);
  }

  Future<void> _loadChats(Emitter<ChatListState> emit) async {
    try {
      // Имитация загрузки из БД
      await Future.delayed(const Duration(milliseconds: 500));
      
      final chats = _getMockChats();
      
      emit(state.copyWith(
        status: ChatListStatus.loaded,
        allChats: chats,
        filteredChats: chats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _applyFilters(Emitter<ChatListState> emit) async {
    var filtered = state.allChats;

    // Фильтр по статусу
    if (state.filter != ChatFilter.all) {
      switch (state.filter) {
        case ChatFilter.active:
          filtered = filtered.where((c) => c.status == ChatStatus.active).toList();
          break;
        case ChatFilter.completed:
          filtered = filtered.where((c) => c.status == ChatStatus.completed).toList();
          break;
        case ChatFilter.archived:
          filtered = filtered.where((c) => c.status == ChatStatus.archived).toList();
          break;
        default:
          break;
      }
    }

    // Поиск
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.lastMessage.toLowerCase().contains(query);
      }).toList();
    }

    // Сортировка: поддержка всегда сверху, потом по времени
    filtered.sort((a, b) {
      if (a.isSupport && !b.isSupport) return -1;
      if (!a.isSupport && b.isSupport) return 1;
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });

    emit(state.copyWith(filteredChats: filtered));
  }

  List<ChatConversation> _getMockChats() {
    final now = DateTime.now();
    return [
      ChatConversation(
        id: 'support',
        name: 'Служба поддержки',
        avatarUrl: null,
        lastMessage: 'Здравствуйте! Чем можем помочь?',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 0,
        isOnline: true,
        isSupport: true,
        status: ChatStatus.active,
      ),
      ChatConversation(
        id: '1',
        name: 'Александр Козлов',
        avatarUrl: 'https://i.pravatar.cc/150?u=1',
        lastMessage: 'Здравствуйте! Проверил ваш последний платеж...',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 1,
        isOnline: true,
        tag: 'СРОЧНО',
        tagColor: '0xFF1E293B',
        status: ChatStatus.active,
      ),
      ChatConversation(
        id: '2',
        name: 'Анна Соколова',
        avatarUrl: 'https://i.pravatar.cc/150?u=2',
        lastMessage: 'Ваша заявка на потребительский кредит одобрена',
        lastMessageTime: now.subtract(const Duration(hours: 5)),
        unreadCount: 0,
        isOnline: false,
        status: ChatStatus.active,
      ),
      ChatConversation(
        id: '3',
        name: 'Бот-помощник',
        avatarUrl: null,
        lastMessage: 'Сессия завершена пользователем',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
        tag: 'РЕШЕНО',
        tagColor: '0xFFE2E8F0',
        status: ChatStatus.completed,
      ),
      ChatConversation(
        id: '4',
        name: 'Персональные предложения',
        avatarUrl: null,
        lastMessage: 'Специально для вас мы подготовили кредитное предложение',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
        status: ChatStatus.active,
      ),
    ];
  }
}
