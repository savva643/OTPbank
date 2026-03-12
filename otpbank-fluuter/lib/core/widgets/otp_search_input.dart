import 'package:flutter/material.dart';

class OtpSearchInput extends StatefulWidget {
  const OtpSearchInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<OtpSearchInput> createState() => _OtpSearchInputState();
}

class _OtpSearchInputState extends State<OtpSearchInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    const bg = Color(0xFFF1F5F9);
    final borderRadius = BorderRadius.circular(29);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => _focusNode.requestFocus(),
          child: Ink(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: bg,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: isFocused ? const Color(0xFF9E6FC3) : Colors.transparent,
                ),
                borderRadius: borderRadius,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 13,
                    left: 44,
                    right: 16,
                    bottom: 14,
                  ),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    autofocus: widget.autofocus,
                    onChanged: widget.onChanged,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
