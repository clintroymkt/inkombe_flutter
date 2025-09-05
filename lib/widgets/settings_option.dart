import 'package:flutter/material.dart';

class SettingOptions extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onTapCallback;
  final Widget? dialog;
  final Widget? screen;
  final Color backgroundColor;
  final Color textColor;
  final double verticalPadding;

  const SettingOptions({
    super.key,
    required this.text,
    this.onPressed,
    this.onTapCallback,
    this.dialog,
    this.screen,
    this.backgroundColor = const Color(0xFF064151),
    this.textColor = const Color(0xFF064151),
    this.verticalPadding = 20.0,
  }) : assert(
  (onPressed != null) ^
  (onTapCallback != null) ^
  (dialog != null) ^
  (screen != null),
  'Provide only one action type: onPressed, onTapCallback, dialog, or screen.',
  );

  @override
  State<SettingOptions> createState() => _SettingOptionsState();
}

class _SettingOptionsState extends State<SettingOptions> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _textColorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.textColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _textColorAnimation = ColorTween(
      begin: widget.textColor,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap(BuildContext context) async {
    // Animate forward (pulse effect)
    await _controller.forward();

    // Execute the action
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else if (widget.onTapCallback != null) {
      widget.onTapCallback!();
    } else if (widget.dialog != null) {
      showDialog(
        context: context,
        builder: (context) => widget.dialog!,
      );
    } else if (widget.screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => widget.screen!),
      );
    }

    // Animate back to original state
    _controller.reverse();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _handleTap(context),
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            padding: EdgeInsets.all(widget.verticalPadding),
            decoration: BoxDecoration(
              color: _backgroundColorAnimation.value,
              border: Border.all(color: widget.backgroundColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(
                    color: _textColorAnimation.value,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.chevron_right_outlined,
                  color: _textColorAnimation.value,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}