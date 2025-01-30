import 'package:flutter/material.dart';


class PlaceholderWidget extends StatelessWidget {
  final IconData icon; // Icon to display
  final String text; // Text to display

  const PlaceholderWidget({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, // Use the provided icon
            size: 50, // Icon size
            color: Colors.grey, // Icon color
          ),
          SizedBox(height: 16), // Spacing between icon and text
          Text(
            text, // Use the provided text
            style: TextStyle(

              color: Colors.grey, // Text color
              fontSize: 18, // Text size
            ),
          ),
        ],
      ),
    );
  }
}