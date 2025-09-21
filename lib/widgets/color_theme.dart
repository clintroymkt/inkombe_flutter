import 'package:flutter/material.dart';

class ColourTheme {
  // Primary style (your original)
  static (Color, Color) primary() {
    return (const Color(0xFF064151), Colors.white);
  }

  // Secondary style
  static (Color, Color) secondary() {
    return (Colors.grey[300]!, Colors.black87);
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
  static (Color, Color) success() {
    return (Colors.green[700]!, Colors.white);
  }
}