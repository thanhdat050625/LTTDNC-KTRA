import 'package:flutter/material.dart';

/// Bảng màu chính của ứng dụng
class AppColors {
  AppColors._();

  // ==================== PRIMARY ====================
  static const Color primary = Color(0xFF2E7D32);       // Forest Green
  static const Color primaryLight = Color(0xFF4CAF50);   // Light Green
  static const Color primaryDark = Color(0xFF1B5E20);    // Dark Green
  static const Color primaryContainer = Color(0xFFE8F5E9);

  // ==================== SECONDARY ====================
  static const Color secondary = Color(0xFFFF6F00);      // Amber Orange
  static const Color secondaryLight = Color(0xFFFFB300);
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryContainer = Color(0xFFFFF3E0);

  // ==================== ACCENT ====================
  static const Color accent = Color(0xFF00ACC1);          // Cyan
  static const Color accentLight = Color(0xFF4DD0E1);

  // ==================== NEUTRAL ====================
  static const Color background = Color(0xFFF5F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F0);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ==================== TEXT ====================
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ==================== STATUS ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ==================== BORDER ====================
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFF2E7D32);

  // ==================== SHADOW ====================
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // ==================== GRADIENT ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFF9FBF9), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient revenueGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFFF6F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== DARK THEME ====================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
}
