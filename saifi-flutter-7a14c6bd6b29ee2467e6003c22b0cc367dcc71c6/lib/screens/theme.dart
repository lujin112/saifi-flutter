import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFCFDF2); // خلفية فاتحة
  static const Color backgroundDark = Color(0xFFF3F6F5); // أغمق بدرجة بسيطة
  static const Color primary = Color(0xFF80C4C0); // التركوازي الأساسي
  static const Color primaryDark = Color(0xFF5CA6A2); // تركوازي أغمق للتدرجات
  static const Color textDark = Color(0xFF1F3558);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFFB0B9C2);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
    fontFamily: 'RobotoMono', // خط يشبه الأكواد
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.6,
    fontFamily: 'RobotoMono',
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
    fontFamily: 'RobotoMono',
  );

  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    fontFamily: 'RobotoMono',
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'RobotoMono',
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: AppColors.primary,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          fontFamily: 'RobotoMono',
        ),
      ),

      textTheme: const TextTheme(
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.small,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          elevation: WidgetStateProperty.all(5),
          backgroundColor: WidgetStateProperty.all(AppColors.primary),
          shadowColor: WidgetStateProperty.all(
            AppColors.primary.withOpacity(0.4),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.white.withOpacity(0.15);
            }
            return AppColors.white.withOpacity(0.07);
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.white),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.grey,
          fontFamily: 'RobotoMono',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          fontFamily: 'RobotoMono',
        ),
      ),
    );
  }
}

/// خلفية متدرجة وناعمة مثل تطبيق Medgulf لكن باللون التركوازي
class ThemedBackground extends StatelessWidget {
  final Widget child;
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.background, AppColors.backgroundDark],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -60,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Opacity(
              opacity: 0.05,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// زر بنفس اللون الأصلي لكن بلمعة خفيفة مثل واجهات التأمين الحديثة
class ShinyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;


  const ShinyButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.95),
            AppColors.primaryDark.withOpacity(0.85),
          ],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: AppTextStyles.button),
      ),
    );
  }
}
