import 'package:flutter/material.dart';
import 'dart:io';

class OtpAvatarButton extends StatelessWidget {
  const OtpAvatarButton({
    super.key,
    required this.onTap,
    this.imageUrl,
    this.initials,
    this.radius = 18,
  });

  final VoidCallback onTap;
  final String? imageUrl;
  final String? initials;
  final double radius;

  ImageProvider? _imageProvider() {
    final v = imageUrl;
    if (v == null || v.trim().isEmpty) return null;

    if (v.startsWith('asset:')) {
      final assetPath = v.substring('asset:'.length);
      if (assetPath.trim().isEmpty) return null;
      return AssetImage(assetPath);
    }

    if (v.startsWith('file:')) {
      final path = v.substring('file:'.length);
      if (path.trim().isEmpty) return null;
      return FileImage(File(path));
    }

    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _imageProvider();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
        backgroundImage: provider,
        child: provider == null
            ? Text(
                (initials ?? 'U').toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              )
            : null,
      ),
    );
  }
}
