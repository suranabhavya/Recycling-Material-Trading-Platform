import 'package:flutter/material.dart';

class AppColors {
  // static const Color primary = Color(0xFF2E7D32);
  // static const Color primaryLight = Color(0xFF66BB6A);
  // static const Color primaryDark = Color(0xFF1B5E20);
  // static const Color darkGreen = Color(0xFF1B5E20);
  static const Color primary = Color(0xFF134417);
  static const Color primaryLight = Color(0xFF1B5E20);
  static const Color primaryDark = Color(0xFF0C2A0E);
  static const Color darkGreen = Color(0xFF0C2A0E);
  
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF42A5F5);
  
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentOrange = Color(0xFFFF9800);
  
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF134417), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    // colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF66BB6A)],
    colors: [Color(0xFF0C2A0E), Color(0xFF134417), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
