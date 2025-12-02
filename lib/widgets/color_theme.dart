import 'package:flutter/material.dart';

class ThemeColors {
  // Primary style (your original)
  static Color primary() {
    return const Color(0xFF064151);
  }

  // Secondary style
  static Color secondary() {
    return const Color(0xFF4CAF50);
  }

  // Danger style
  static (Color, Color) danger() {
    return (Colors.red[700]!, Colors.white);
  }

  // Warning style
  static (Color, Color) warning() {
    return (Colors.greenAccent[700]!, Colors.white);
  }

  // Success style
  static Color success() {
    return const Color(0xFF4CAF50);
  }
}