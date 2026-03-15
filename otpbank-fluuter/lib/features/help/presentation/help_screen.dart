import 'package:flutter/material.dart';
import '../../../core/widgets/otp_universal_app_bar.dart';
import '../../../core/widgets/otp_search_input.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allArticles = [
    {
      'title': 'Как перевести деньги?',
      'category': 'Переводы',
      'content': 'Для перевода денег откройте раздел "Переводы" и выберите получателя...',
      'icon': Icons.send,
      'isPopular': true,
    },
    {
      'title': 'Как заблокировать карту?',
      'category': 'Безопасность',
      'content': 'Для блокировки карты зайдите в настройки безопасности...',
      'icon': Icons.block,
      'isPopular': true,
    },
    {
      'title': 'Как изменить PIN-код?',
      'category': 'Безопасность',
      'content': 'Изменить PIN-код можно в банкомате или в приложении...',
      'icon': Icons.lock,
      'isPopular': false,
    },
    {
      'title': 'Как заказать новую карту?',
      'category': 'Карты',
      'content': 'Заказать новую карту можно в разделе "Карты"...',
      'icon': Icons.credit_card,
      'isPopular': true,
    },
    {
      'title': 'Как пополнить счет?',
      'category': 'Пополнение',
      'content': 'Пополнить счет можно через банкомат, перевод или терминал...',
      'icon': Icons.add_circle,
      'isPopular': false,
    },
    {
      'title': 'Как посмотреть выписку?',
      'category': 'История',
      'content': 'Выписку можно посмотреть в разделе "История операций"...',
      'icon': Icons.receipt,
      'isPopular': false,
    },
    {
      'title': 'Как настроить уведомления?',
      'category': 'Настройки',
      'content': 'Настройки уведомлений находятся в профиле...',
      'icon': Icons.notifications,
      'isPopular': false,
    },
    {
      'title': 'Как связаться с поддержкой?',
      'category': 'Поддержка',
      'content': 'Связаться с поддержкой можно через чат или по телефону...',
      'icon': Icons.support_agent,
      'isPopular': true,
    },
  ];

  List<Map<String, dynamic>> _filteredArticles = [];
  String _selectedCategory = 'Все';

  @override
  void initState() {
    super.initState();
    _filteredArticles = List.from(_allArticles);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = List.from(_allArticles);
      } else {
        _filteredArticles = _allArticles.where((article) {
          final title = article['title'].toString().toLowerCase();
          final content = article['content'].toString().toLowerCase();
          final category = article['category'].toString().toLowerCase();
          return title.contains(query) || content.contains(query) || category.contains(query);
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Все') {
        _filteredArticles = List.from(_allArticles);
      } else {
        _filteredArticles = _allArticles.where((article) => article['category'] == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          OtpUniversalAppBar(
            title: 'Помощь',
            onBack: () => Navigator.of(context).maybePop(),
            backHasBackground: true,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // Search field
                  OtpSearchInput(
                    controller: _searchController,
                    hintText: 'Поиск по статьям помощи...',
                    onChanged: (_) => _onSearchChanged(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categories
                  _buildCategories(),
                  
                  const SizedBox(height: 24),
                  
                  // Popular articles
                  if (_selectedCategory == 'Все' && _searchController.text.isEmpty) ...[
                    _buildSection(
                      title: 'ПОПУЛЯРНЫЕ СТАТЬИ',
                      children: _allArticles
                          .where((article) => article['isPopular'] == true)
                          .map((article) => _buildArticleItem(article))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // All articles
                  _buildSection(
                    title: _searchController.text.isNotEmpty ? 'РЕЗУЛЬТАТЫ ПОИСКА' : 'ВСЕ СТАТЬИ',
                    children: _filteredArticles.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'Ничего не найдено'
                                        : 'Статьи не найдены',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Попробуйте изменить поисковый запрос',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ]
                        : _filteredArticles.map((article) => _buildArticleItem(article)).toList(),
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Все', 'Переводы', 'Безопасность', 'Карты', 'Пополнение', 'История', 'Настройки', 'Поддержка'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _filterByCategory(category);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFC4FF2E).withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFFC4FF2E) : const Color(0xFFF1F5F9),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildArticleItem(Map<String, dynamic> article) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showArticleDetails(article),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Icon(
                        article['icon'],
                        color: const Color(0xFF64748B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['title'],
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article['category'],
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article['content'],
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (article['isPopular']) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Популярное',
                          style: TextStyle(
                            color: Color(0xFFFF7D32),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (article != _filteredArticles.last) // Don't add divider for last item
          Container(
            height: 1,
            color: const Color(0xFFF8FAFC),
          ),
      ],
    );
  }

  void _showArticleDetails(Map<String, dynamic> article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(48),
              ),
              child: Icon(
                article['icon'],
                color: const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(article['title'])),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC4FF2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article['category'],
                  style: const TextStyle(
                    color: Color(0xFFC4FF2E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                article['content'],
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Это подробная инструкция по данному вопросу. Здесь может быть больше информации, шаги, скриншоты и т.д.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          if (article['category'] == 'Поддержка') ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to chat
              },
              child: const Text('Написать в чат'),
            ),
          ],
        ],
      ),
    );
  }
}
