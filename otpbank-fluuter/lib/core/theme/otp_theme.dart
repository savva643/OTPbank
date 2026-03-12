import 'package:flutter/material.dart';

import 'otp_colors.dart';

class OtpTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OtpColors.primaryLime,
      brightness: Brightness.light,
      primary: OtpColors.primaryLime,
    ).copyWith(
      secondary: OtpColors.purpleAccent,
      tertiary: OtpColors.orangeAccent,
      surface: OtpColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: OtpColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: OtpColors.background,
        foregroundColor: OtpColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerColor: OtpColors.divider,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: OtpColors.textPrimary,
        unselectedItemColor: OtpColors.textSecondary,
        backgroundColor: OtpColors.background,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OtpColors.lightBlue.withValues(alpha: 0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
