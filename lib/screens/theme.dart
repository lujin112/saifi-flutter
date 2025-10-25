import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFCFDF2); // الخلفية الفاتحة
  static const Color primary = Color(0xFF80C4C0);    // اللون الأساسي (تركواز هادي)
  static const Color textDark = Color(0xFF1F3558);   // النصوص الداكنة
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.6,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Poppins', // تأكد تضيف Poppins في pubspec.yaml
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          fontFamily: 'Poppins',
        ),
      ),

      textTheme: const TextTheme(
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.small,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
