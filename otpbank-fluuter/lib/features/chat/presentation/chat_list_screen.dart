import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/otp_search_input.dart';
import '../../../features/chat/bloc/chat_list_bloc.dart';
import '../../../features/chat/bloc/chat_bloc.dart';
import '../../../features/chat/presentation/widgets/chat_list_item.dart';
import '../../../features/chat/presentation/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatListBloc _bloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = ChatListBloc();
    _bloc.add(const ChatListStarted());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _bloc.add(ChatListSearchChanged(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Dark header with title and search
            _buildHeader(),

            // Filter tabs
            _buildFilterTabs(),

            _buildHeaderDivider(),

            // Chat list
            Expanded(
              child: BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, state) {
                  if (state.status == ChatListStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4FF2E)),
                      ),
                    );
                  }

                  if (state.status == ChatListStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'Ошибка загрузки',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _bloc.add(const ChatListRefreshed());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC4FF2E),
                              foregroundColor: const Color(0xFF0F172A),
                            ),
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.filteredChats.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _bloc.add(const ChatListRefreshed());
                    },
                    color: const Color(0xFFC4FF2E),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = state.filteredChats[index];
                        return ChatListItem(
                          chat: chat,
                          isHighlighted: index == 1, // First non-support chat highlighted
                          onTap: () => _openChat(context, chat),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Чаты',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.20,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // New chat button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4FF2E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF0F172A),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OtpSearchInput(
                controller: _searchController,
                hintText: 'Поиск по чатам и сообщениям...',
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'АКТИВНЫЕ',
                  isActive: state.filter == ChatFilter.active,
                  onTap: () => _bloc.add(const ChatListFilterChanged(ChatFilter.active)),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'ЗАВЕРШЕННЫЕ',
                  isActive: state.filter == ChatFilter.completed,
                  onTap: () => _bloc.add(const ChatListFilterChanged(ChatFilter.completed)),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'АРХИВ',
                  isActive: state.filter == ChatFilter.archived,
                  onTap: () => _bloc.add(const ChatListFilterChanged(ChatFilter.archived)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFC4FF2E)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.33,
            letterSpacing: 0.60,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: const Color(0xFF94A3B8).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет чатов',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Начните новый диалог',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, ChatConversation chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatBloc(),
          child: ChatScreen(
            chatId: chat.id,
            chatName: chat.name,
            isSupport: chat.isSupport,
          ),
        ),
      ),
    );
  }
}
