import 'package:flutter/material.dart';

/// Saytdagi CSS o'zgaruvchilaridan (oklch) hex'ga o'girilgan ranglar.
/// Manba: bright-recollections.lovable.app -> :root
abstract final class AppColors {
  /// --background: oklch(96.8% .002 247)
  static const Color background = Color(0xFFF3F4F6);

  /// --foreground: oklch(19% .01 260)
  static const Color foreground = Color(0xFF111418);

  /// --primary: oklch(56% .221 27.5)
  static const Color primary = Color(0xFFD8141B);

  /// --primary-foreground
  static const Color primaryForeground = Color(0xFFFCFCFC);

  /// --secondary / --muted / --accent
  static const Color secondary = Color(0xFFEEF0F3);

  /// --secondary-foreground
  static const Color secondaryForeground = Color(0xFF1F2227);

  /// --muted-foreground: oklch(60% .015 258)
  static const Color mutedForeground = Color(0xFF7B8189);

  /// --card
  static const Color card = Color(0xFFFFFFFF);

  /// --border / --input
  static const Color border = Color(0xFFE6E8EB);

  /// --destructive
  static const Color destructive = Color(0xFFE7000B);

  /// KONKURS banneri va Garaj kartasining qora foni.
  static const Color dark = Color(0xFF1A1D21);

  /// To'g'ri javob ekranidagi yashil.
  static const Color success = Color(0xFF15A05A);
  static const Color successSoft = Color(0xFFD8F3E3);
}
