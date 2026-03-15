import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

class OtpWebpImage extends StatefulWidget {
  const OtpWebpImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<OtpWebpImage> createState() => _OtpWebpImageState();
}

class _OtpWebpImageState extends State<OtpWebpImage> {
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(OtpWebpImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _loading = true;
      _error = false;
      _imageBytes = null;
    });

    try {
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }

      var bytes = response.data!;

      // Check if it's WebP (RIFF....WEBP signature)
      if (_isWebP(bytes)) {
        // Decode WebP using image package
        final image = img.decodeWebP(bytes);
        if (image != null) {
          // Encode to PNG for display
          bytes = Uint8List.fromList(img.encodePng(image));
        }
      }

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  bool _isWebP(Uint8List bytes) {
    if (bytes.length < 12) return false;
    // RIFF....WEBP signature
    return bytes[0] == 0x52 && // R
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x46 && // F
        bytes[8] == 0x57 && // W
        bytes[9] == 0x45 && // E
        bytes[10] == 0x42 && // B
        bytes[11] == 0x50; // P
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.placeholder ?? const ColoredBox(color: Colors.black);
    }

    if (_error || _imageBytes == null) {
      return widget.errorWidget ?? const ColoredBox(color: Colors.black);
    }

    return Image.memory(
      _imageBytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) {
        return widget.errorWidget ?? const ColoredBox(color: Colors.black);
      },
    );
  }
}
