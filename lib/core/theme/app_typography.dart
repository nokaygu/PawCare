import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Nunito Sans';

  static TextTheme buildTextTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 44 / 36,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: onSurface,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 34 / 26,
        color: onSurface,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 26 / 19,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurfaceVariant,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 14 / 11,
        color: onSurface,
        letterSpacing: 0.3,
      ),
    );
  }

  static TextStyle toExtraBold(TextStyle base, {Color? color}) {
    return base.copyWith(fontWeight: FontWeight.w800, color: color);
  }

  static TextStyle toBold(TextStyle base, {Color? color}) {
    return base.copyWith(fontWeight: FontWeight.w700, color: color);
  }

  static TextStyle toSemiBold(TextStyle base, {Color? color}) {
    return base.copyWith(fontWeight: FontWeight.w600, color: color);
  }

  static TextStyle toMedium(TextStyle base, {Color? color}) {
    return base.copyWith(fontWeight: FontWeight.w500, color: color);
  }

  static TextStyle toMicroTag(
    TextStyle base, {
    Color? color,
    bool bold = true,
  }) {
    return base.copyWith(
      fontSize: 10,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );
  }
}
