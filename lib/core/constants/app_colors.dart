import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette (Verve Emerald & Violet)
  static const Color primary = Color(0xFF10B981); // Vibrant Emerald
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);

  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color accent = Color(0xFF8B5CF6); // Violet

  // OLED Dark Theme Palette
  static const Color oledBackground = Color(0xFF000000); // True Black
  static const Color oledSurface = Color(0xFF0D0D10);
  static const Color oledCard = Color(0xFF16161B);
  static const Color oledCardBorder = Color(0xFF23232A);
  static const Color oledTextPrimary = Color(0xFFF3F4F6);
  static const Color oledTextSecondary = Color(0xFF9CA3AF);
  static const Color oledTextMuted = Color(0xFF6B7280);

  // Clean Light Theme Palette
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Note & Folder Tag Palettes
  static const List<Color> noteColors = [
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Coral Red
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
    Color(0xFF64748B), // Slate
  ];

  static Color fromHex(String? hexString, {Color defaultColor = primary}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
