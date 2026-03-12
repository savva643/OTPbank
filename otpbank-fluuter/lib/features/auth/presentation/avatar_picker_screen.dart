import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPickerScreen extends StatelessWidget {
  const AvatarPickerScreen({super.key});

  static const List<String> predefined = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Аватар')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите аватар',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: predefined.length + 1,
                itemBuilder: (context, index) {
                  if (index == predefined.length) {
                    return _PickFromGalleryTile(
                      onTap: () async {
                        try {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(source: ImageSource.gallery);
                          if (file == null) return;
                          if (!context.mounted) return;
                          Navigator.of(context).pop('file:${file.path}');
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Не удалось открыть галерею')),
                          );
                        }
                      },
                    );
                  }

                  final assetPath = predefined[index];
                  return _AvatarTile(
                    image: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.person_rounded, color: Color(0xFF0F172A), size: 28),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop('asset:$assetPath');
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Если картинок ещё нет — просто добавь файлы avatar1.png..avatar4.png в assets/avatars/.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.image, required this.onTap});

  final Widget image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: image,
        ),
      ),
    );
  }
}

class _PickFromGalleryTile extends StatelessWidget {
  const _PickFromGalleryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_library_rounded, color: Color(0xFF0F172A)),
              SizedBox(height: 6),
              Text(
                'Галерея',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? avatarProviderLabel(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return null;
  if (avatarUrl.startsWith('asset:')) return 'Выбран из набора';
  if (avatarUrl.startsWith('file:')) return 'Выбран из галереи';
  return 'URL';
}
