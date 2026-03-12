import 'package:flutter/material.dart';

class OtpStoryTile extends StatefulWidget {
  const OtpStoryTile({
    super.key,
    required this.label,
    required this.borderColor,
    this.dimmed = false,
    this.onTap,
    this.imageProvider,
  });

  final String label;
  final Color borderColor;
  final bool dimmed;
  final VoidCallback? onTap;
  final ImageProvider? imageProvider;

  @override
  State<OtpStoryTile> createState() => _OtpStoryTileState();
}

class _OtpStoryTileState extends State<OtpStoryTile> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.dimmed ? 0.8 : 1,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 2, color: widget.borderColor),
            color: const Color(0xFFE2E8F0),
            image: widget.imageProvider != null
                ? DecorationImage(image: widget.imageProvider!, fit: BoxFit.cover)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (widget.imageProvider == null) Positioned.fill(child: Container(color: const Color(0xFFE2E8F0))),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.70),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
