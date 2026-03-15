import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initializing = true;
  bool _flashOn = false;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.dispose();
      _controller = null;
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializing = true;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _controller = null;
          _initializing = false;
        });
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      _controller?.dispose();
      _controller = controller;

      final flashMode = _flashOn ? FlashMode.torch : FlashMode.off;
      try {
        await _controller?.setFlashMode(flashMode);
      } catch (_) {
        // ignore
      }

      if (!mounted) return;
      setState(() {
        _initializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _controller = null;
        _initializing = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    setState(() {
      _flashOn = !_flashOn;
    });

    if (controller == null) return;

    try {
      await controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (x == null) return;
      setState(() {
        _pickedImage = x;
      });
    } catch (_) {
      // ignore
    }
  }

  void _clearPickedImage() {
    if (_pickedImage == null) return;
    setState(() {
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: _CameraOrImageLayer(
              controller: _controller,
              initializing: _initializing,
              pickedImage: _pickedImage,
            ),
          ),
          const Positioned.fill(child: _ScanOverlay()),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Material(
                      color: Colors.black.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9999),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Оплата по QR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.56,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: _BottomControls(
                    flashOn: _flashOn,
                    onFlashTap: _toggleFlash,
                    onGalleryTap: _pickFromGallery,
                    showingImage: _pickedImage != null,
                    onClearImage: _clearPickedImage,
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

class _CameraOrImageLayer extends StatelessWidget {
  const _CameraOrImageLayer({
    required this.controller,
    required this.initializing,
    required this.pickedImage,
  });

  final CameraController? controller;
  final bool initializing;
  final XFile? pickedImage;

  @override
  Widget build(BuildContext context) {
    if (pickedImage != null) {
      return Image.file(
        File(pickedImage!.path),
        fit: BoxFit.cover,
      );
    }

    if (initializing) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC4FF2E)),
        ),
      );
    }

    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: Text(
          'Камера недоступна',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller!.value.previewSize?.height ?? 1,
        height: controller!.value.previewSize?.width ?? 1,
        child: CameraPreview(controller!),
      ),
    );
  }
}

class _ScanOverlay extends StatefulWidget {
  const _ScanOverlay();

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final side = min(256.0, c.maxWidth - 48);
        final top = (c.maxHeight - side) / 2;
        final left = (c.maxWidth - side) / 2;

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.20),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: side,
              height: side,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(width: 2, color: const Color(0x4CC4FF2E)),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(color: Colors.transparent),
                      ),
                      _Corner(left: 0, top: 0, right: null, bottom: null),
                      _Corner(left: null, top: 0, right: 0, bottom: null),
                      _Corner(left: 0, top: null, right: null, bottom: 0),
                      _Corner(left: null, top: null, right: 0, bottom: 0),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final y = (_controller.value) * (side - 32) + 16;
                          return Positioned(
                            left: 18,
                            top: y,
                            child: Container(
                              width: side - 36,
                              height: 2,
                              decoration: const BoxDecoration(
                                color: Color(0xCCC4FF2E),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFC4FF2E),
                                    blurRadius: 15,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: top + side + 48,
              child: const Center(
                child: Text(
                  'Наведите камеру на QR-код для\nоплаты',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final isLeft = left != null;
    final isTop = top != null;

    final radius = Radius.circular(24);

    return Positioned(
      left: left ?? (right != null ? null : 0),
      top: top ?? (bottom != null ? null : 0),
      right: right,
      bottom: bottom,
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 5, color: Color(0xFFC4FF2E)),
            borderRadius: BorderRadius.only(
              topLeft: isLeft && isTop ? radius : Radius.zero,
              topRight: !isLeft && isTop ? radius : Radius.zero,
              bottomLeft: isLeft && !isTop ? radius : Radius.zero,
              bottomRight: !isLeft && !isTop ? radius : Radius.zero,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.flashOn,
    required this.onFlashTap,
    required this.onGalleryTap,
    required this.showingImage,
    required this.onClearImage,
  });

  final bool flashOn;
  final VoidCallback onFlashTap;
  final VoidCallback onGalleryTap;
  final bool showingImage;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = min(320.0, c.maxWidth);
        return Container(
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            color: Colors.black.withValues(alpha: 0.30),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: Colors.white.withValues(alpha: 0.10)),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ControlButton(
                  label: 'ВСПЫШКА',
                  icon: flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  onTap: onFlashTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ControlButton(
                  label: showingImage ? 'УБРАТЬ' : 'ГАЛЕРЕЯ',
                  icon: showingImage ? Icons.close_rounded : Icons.photo_library_outlined,
                  onTap: showingImage ? onClearImage : onGalleryTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 0.50,
            ),
          ),
        ],
      ),
    );
  }
}
