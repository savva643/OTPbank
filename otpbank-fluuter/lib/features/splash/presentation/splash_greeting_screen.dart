import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/greeting_cache_storage.dart';
import '../../../core/theme/otp_colors.dart';
import '../../home/bloc/home_bloc.dart';
import '../../shell/presentation/root_shell.dart';

class SplashGreetingScreen extends StatefulWidget {
  const SplashGreetingScreen({super.key});

  @override
  State<SplashGreetingScreen> createState() => _SplashGreetingScreenState();
}

class _SplashGreetingScreenState extends State<SplashGreetingScreen> with SingleTickerProviderStateMixin {
  String? _gifAsset;
  bool _visible = false;

  String? _cachedUserName;
  String? _cachedAvatarUrl;

  static const _gifCandidates = <String>[
    'assets/gifs/night.gif',
    'assets/gifs/night2.gif',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final cached = await GreetingCacheStorage().getCached();
        if (!mounted) return;
        setState(() {
          _cachedUserName = cached.userName;
          _cachedAvatarUrl = cached.avatarUrl;
        });
      } catch (_) {
        // ignore
      }

      await _pickRandomGif();
      if (!mounted) return;
      setState(() => _visible = true);

      await Future<void>.delayed(const Duration(milliseconds: 2600));
      if (!mounted) return;

      setState(() => _visible = false);
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const RootShell(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return 'Доброе утро';
    if (hour >= 12 && hour < 18) return 'Добрый день';
    if (hour >= 18 && hour < 23) return 'Добрый вечер';
    return 'Доброй ночи';
  }

  Future<void> _pickRandomGif() async {
    try {
      final rnd = Random();
      _gifAsset = _gifCandidates[rnd.nextInt(_gifCandidates.length)];
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeBloc>().state;
    final resolvedUserName = ((homeState.userName ?? _cachedUserName) ?? '').trim();
    final greeting = _greeting(DateTime.now());

    final resolvedAvatarUrl = ((homeState.avatarUrl ?? _cachedAvatarUrl) ?? '').trim();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: _gifAsset == null
                ? Container(color: const Color(0xFF0F172A))
                : Image.asset(
                    _gifAsset!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: _visible ? Offset.zero : const Offset(0, -0.06),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOut,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'splash_avatar',
                          child: _AvatarCircle(avatarUrl: resolvedAvatarUrl),
                        ),
                        const SizedBox(width: 12),
                        Hero(
                          tag: 'splash_title',
                          flightShuttleBuilder:
                              (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                            final child = flightDirection == HeroFlightDirection.pop
                                ? fromHeroContext.widget
                                : toHeroContext.widget;
                            return FadeTransition(
                              opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
                              child: ScaleTransition(
                                scale: animation.drive(
                                  Tween<double>(begin: 0.98, end: 1.0)
                                      .chain(CurveTween(curve: Curves.easeOut)),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: _GreetingTitle(
                            greeting: greeting,
                            userName: resolvedUserName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatar;
    final url = avatarUrl.trim();
    if (url.isNotEmpty) {
      if (url.startsWith('asset:')) {
        final assetPath = url.substring('asset:'.length);
        if (assetPath.isNotEmpty) {
          avatar = AssetImage(assetPath);
        }
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        avatar = NetworkImage(url);
      }
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: OtpColors.primaryLime.withValues(alpha: 0.90), width: 2),
      ),
      child: ClipOval(
        child: avatar == null
            ? const Icon(Icons.person_rounded, color: Colors.white, size: 30)
            : Image(image: avatar, fit: BoxFit.cover),
      ),
    );
  }
}

class _GreetingTitle extends StatelessWidget {
  const _GreetingTitle({required this.greeting, required this.userName});

  final String greeting;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final name = userName.isEmpty ? 'Пользователь' : userName;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1.10,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
