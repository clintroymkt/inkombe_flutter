import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // Mandatory properties
  final IconData icon;
  final String text;

  // Action properties
  final VoidCallback? onPressed;
  final VoidCallback? onTapCallback;
  final Widget? dialog;
  final Widget? screen;

  // Style properties (with defaults)
  final Color backgroundColor;
  final Color textColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.onTapCallback,
    this.dialog,
    this.screen,
    this.backgroundColor = const Color(0xFF064151), // Your default color
    this.textColor = Colors.white,
    this.horizontalPadding = 25.0,
    this.verticalPadding = 20.0,
    this.borderRadius = 12.0,
  }) : assert(
  (onPressed != null) ^
  (onTapCallback != null) ^
  (dialog != null) ^
  (screen != null),
  'Provide only one action type: onPressed, onTapCallback, dialog, or screen.',
  );

  void _handleTap(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else if (onTapCallback != null) {
      onTapCallback!();
    } else if (dialog != null) {
      showDialog(
        context: context,
        builder: (context) => dialog!,
      );
    } else if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: Container(
          padding: EdgeInsets.all(verticalPadding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
