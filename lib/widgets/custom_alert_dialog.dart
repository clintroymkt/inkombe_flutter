import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String content;
  final String acceptText;
  final String rejectText;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const CustomAlertDialog({
    super.key,
    this.icon,
    required this.title,
    required this.content,
    required this.acceptText,
    required this.rejectText,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: [
        TextButton(
          onPressed: widget.onReject,
          child: Text(widget.rejectText),
        ),
        TextButton(
          onPressed: widget.onAccept,
          child: Text(widget.acceptText),
        ),
      ],
    );
  }
}

