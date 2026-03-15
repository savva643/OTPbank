import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/otp_webp_image.dart';
import '../../shell/presentation/root_shell.dart';

class StoryListItem {
  const StoryListItem({required this.id, required this.title, this.miniImageUrl});

  final String id;
  final String title;
  final String? miniImageUrl;
}

class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  final List<StoryListItem> items;
  final int initialIndex;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  final _apiClient = ApiClient();
  late final PageController _pageController;

  late AnimationController _progress;
  int _index = 0;
  bool _isPaused = false;
  Timer? _debounce;

  static const _storyDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _index);
    _progress = AnimationController(vsync: this, duration: _storyDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _next();
        }
      });
    _progress.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _progress.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _pause() {
    if (_isPaused) return;
    setState(() => _isPaused = true);
    _progress.stop();
  }

  void _resume() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    _progress.forward();
  }

  void _prev() {
    if (_index <= 0) {
      Navigator.of(context).pop();
      return;
    }
    _goTo(_index - 1);
  }

  void _next() {
    if (_index >= widget.items.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _goTo(_index + 1);
  }

  void _goTo(int newIndex) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      _progress.reset();
      _progress.forward();
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      setState(() => _index = newIndex);
    });
  }

  Future<Map<String, dynamic>> _loadDetail(String storyId) async {
    final res = await _apiClient.dio.get('/stories/$storyId');
    final data = res.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  void _handleCta(String? action, String? payload) {
    final a = (action ?? '').trim();
    if (a.isEmpty || a == 'close') {
      Navigator.of(context).pop();
      return;
    }
    if (a == 'open_showcase') {
      RootShell.maybeOf(context)?.setIndex(4);
      Navigator.of(context).pop();
      return;
    }
    if (a == 'open_tab') {
      final idx = int.tryParse((payload ?? '').trim());
      if (idx != null) RootShell.maybeOf(context)?.setIndex(idx);
      Navigator.of(context).pop();
      return;
    }
    if (a == 'open_product') {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/product/$payload');
      return;
    }
    if (a == 'card_issue') {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/product/$payload');
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _progressBars() {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return Row(
          children: [
            for (int i = 0; i < widget.items.length; i++)
              Expanded(
                child: Container(
                  height: 2.5,
                  margin: EdgeInsets.only(right: i == widget.items.length - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: i < _index
                            ? 1
                            : (i > _index ? 0 : _progress.value.clamp(0, 1)),
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                _progress.reset();
                if (!_isPaused) _progress.forward();
              },
              itemBuilder: (context, i) {
                final item = widget.items[i];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPressStart: (_) => _pause(),
                  onLongPressEnd: (_) => _resume(),
                  onTapUp: (d) {
                    final w = MediaQuery.of(context).size.width;
                    if (d.localPosition.dx < w * 0.33) {
                      _prev();
                    } else {
                      _next();
                    }
                  },
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _loadDetail(item.id),
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? const <String, dynamic>{};
                      final title = (data['title'] ?? item.title).toString().trim();
                      final storyText = (data['storyText'] ?? data['story_text'] ?? '').toString().trim();
                      final mediaUrl = (data['mediaUrl'] ?? data['media_url'])?.toString();
                      final mediaType = (data['mediaType'] ?? data['media_type'])?.toString();
                      final ctaLabelRaw = (data['ctaLabel'] ?? data['cta_label'])?.toString().trim();
                      final ctaAction = (data['ctaAction'] ?? data['cta_action'])?.toString();
                      final ctaPayload = (data['ctaPayload'] ?? data['cta_payload'])?.toString();

                      String ctaLabel() {
                        final raw = (ctaLabelRaw ?? '').trim();
                        final broken = raw.isEmpty || raw.contains('?');
                        final a = (ctaAction ?? '').trim();
                        final isAsciiOnly = raw.isNotEmpty && RegExp(r'^[\x00-\x7F]+$').hasMatch(raw);
                        if (!broken && !isAsciiOnly) return raw;

                        if (a == 'open_showcase') return 'Открыть витрину';
                        if (a == 'open_product') return 'Оформить';
                        if (a == 'card_issue') return 'Оформить карту';
                        if (a == 'close') {
                          if (title.toLowerCase().contains('новое')) return 'Ок';
                          if (title.toLowerCase().contains('сваровски')) return 'Круто!';
                          return 'Понятно';
                        }

                        return 'Далее';
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (mediaUrl != null) ...[
                            if (mediaType == 'gif')
                              Positioned.fill(
                                child: Image.network(
                                  mediaUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
                                ),
                              )
                            else if (mediaType == 'photo')
                              Positioned.fill(
                                child: Image.network(
                                  mediaUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
                                ),
                              )
                            else if (mediaType == 'webp')
                              Positioned.fill(
                                child: OtpWebpImage(
                                  imageUrl: mediaUrl,
                                  fit: BoxFit.cover,
                                  placeholder: const ColoredBox(color: Colors.black),
                                  errorWidget: const ColoredBox(color: Colors.black),
                                ),
                              ),
                          ]
                          else
                            const ColoredBox(color: Colors.black),

                          Positioned(
                            left: 16,
                            right: 16,
                            top: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _progressBars(),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.92),
                                    Colors.black.withOpacity(0.55),
                                    Colors.black.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              child: SafeArea(
                                top: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (title.isNotEmpty)
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                    if (storyText.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        storyText,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.92),
                                          fontSize: 14,
                                          height: 1.35,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        onPressed: () => _handleCta(ctaAction, ctaPayload),
                                        child: Text(
                                          ctaLabel(),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Color(0x22000000),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
