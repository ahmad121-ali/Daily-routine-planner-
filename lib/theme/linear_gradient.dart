import 'package:flutter/material.dart';

class AppColors {
  // 1. Define Base Colors
  static const Color backgroundTop = Color(0xFF1D1B4B);    // Deep Indigo
  static const Color backgroundMiddle = Color(0xFF0A0E21); // Midnight Black
  static const Color backgroundBottom = Color(0xFF2D0A31); // Deep Plum

  static const Color accentLavender = Color(0xFFB599FF);
  static const Color accentPurple = Color(0xFF9D39F5);
  static const Color accentPink = Color(0xFFE56EF0);
  static const Color cardFill = Color(0x08FFFFFF);
  static const Color cardBorder = Color(0x1AFFFFFF);

  // 2. Updated Gradient to match the Login Screen exactly
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundTop,
      backgroundMiddle,
      backgroundBottom
    ],
    stops: [0.0, 0.5, 1.0], // Ensures the middle color stays in the center
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [accentPurple, accentPink],
  );

  static const LinearGradient socialButtonGradient = LinearGradient(
    colors: [Color(0xFF1A1F36), Color(0xFF0A0E21)],
  );
}
