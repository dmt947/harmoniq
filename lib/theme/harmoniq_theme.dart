import 'package:flutter/material.dart';
import 'package:harmoniq/theme/harmoniq_colors.dart';
import 'package:harmoniq/theme/harmoniq_scheme.dart';
import 'package:harmoniq/theme/harmoniq_text_theme.dart';

class HarmoniqTheme {
  HarmoniqTheme._();

  static const String _fontFamily = 'Poppins';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: HarmoniqScheme.light,
      textTheme: HarmoniqTextTheme.lightTextTheme,
      fontFamily: _fontFamily,

      scaffoldBackgroundColor: HarmoniqColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: HarmoniqScheme.light.primary,
        foregroundColor: HarmoniqScheme.light.onPrimary,
        elevation: 0,
        titleTextStyle: HarmoniqTextTheme.lightTextTheme.titleLarge?.copyWith(
          color: HarmoniqScheme.light.onPrimary,
        ),
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: HarmoniqColors.darkBackground,
        labelColor: HarmoniqScheme.light.onSurface,
        unselectedLabelColor: HarmoniqScheme.light.onSurface.withAlpha(155),
        labelPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HarmoniqScheme.light.primary,
          foregroundColor: HarmoniqScheme.light.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: HarmoniqTextTheme.lightTextTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HarmoniqScheme.light.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: HarmoniqTextTheme.lightTextTheme.bodyLarge?.copyWith(
          color: HarmoniqScheme.light.onSurface.withAlpha(180),
        ),
        floatingLabelStyle: HarmoniqTextTheme.lightTextTheme.bodyLarge
            ?.copyWith(color: HarmoniqScheme.light.primary),
        hintStyle: HarmoniqTextTheme.lightTextTheme.bodyLarge?.copyWith(
          color: HarmoniqScheme.light.onSurface.withAlpha(100),
        ),
      ),
      iconTheme: IconThemeData(color: HarmoniqScheme.light.onBackground),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HarmoniqScheme.light.onSurface,
        contentTextStyle: HarmoniqTextTheme.lightTextTheme.labelMedium
            ?.copyWith(color: HarmoniqScheme.light.onError),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: HarmoniqScheme.light.primary,
        foregroundColor: HarmoniqScheme.light.onPrimary,
        shape: const CircleBorder(),
      ),
      sliderTheme: SliderThemeData.fromPrimaryColors(
        primaryColor: HarmoniqScheme.light.primary,
        primaryColorDark: HarmoniqColors.primary,
        primaryColorLight: HarmoniqColors.primary,
        valueIndicatorTextStyle: HarmoniqTextTheme.darkTextTheme.labelMedium!,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: HarmoniqScheme.light.background,
        titleTextStyle: HarmoniqTextTheme.lightTextTheme.titleLarge?.copyWith(
          color: HarmoniqScheme.light.onBackground,
        ),
        contentTextStyle: HarmoniqTextTheme.lightTextTheme.bodyMedium?.copyWith(
          color: HarmoniqScheme.light.onBackground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: HarmoniqScheme.dark,
      textTheme: HarmoniqTextTheme.darkTextTheme,

      fontFamily: _fontFamily,

      scaffoldBackgroundColor: HarmoniqColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: HarmoniqScheme.dark.background,
        foregroundColor: HarmoniqScheme.dark.onPrimary,
        elevation: 0,
        titleTextStyle: HarmoniqTextTheme.darkTextTheme.titleLarge?.copyWith(
          color: HarmoniqScheme.dark.onPrimary,
        ),
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: HarmoniqColors.lightBackground,
        labelColor: HarmoniqScheme.dark.onSurface,
        unselectedLabelColor: HarmoniqScheme.dark.onSurface.withOpacity(0.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HarmoniqScheme.dark.primary,
          foregroundColor: HarmoniqScheme.dark.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: HarmoniqTextTheme.darkTextTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HarmoniqScheme.dark.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: HarmoniqTextTheme.darkTextTheme.bodyLarge?.copyWith(
          color: HarmoniqScheme.dark.onSurface.withOpacity(0.7),
        ),
        floatingLabelStyle: HarmoniqTextTheme.darkTextTheme.bodyLarge?.copyWith(
          color: HarmoniqScheme.dark.primary,
        ),
        hintStyle: HarmoniqTextTheme.darkTextTheme.bodyLarge?.copyWith(
          color: HarmoniqScheme.dark.onSurface.withOpacity(0.4),
        ),
      ),
      iconTheme: IconThemeData(color: HarmoniqScheme.dark.onBackground),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HarmoniqScheme.dark.onSurface,
        contentTextStyle: HarmoniqTextTheme.darkTextTheme.labelMedium?.copyWith(
          color: HarmoniqScheme.dark.onError,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: HarmoniqScheme.dark.primary,
        foregroundColor: HarmoniqScheme.dark.onPrimary,
        shape: const CircleBorder(),
      ),
      sliderTheme: SliderThemeData.fromPrimaryColors(
        primaryColor: HarmoniqScheme.dark.primary,
        primaryColorDark: HarmoniqColors.primary,
        primaryColorLight: HarmoniqColors.primary,
        valueIndicatorTextStyle: HarmoniqTextTheme.darkTextTheme.labelMedium!,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: HarmoniqScheme.dark.background,
        titleTextStyle: HarmoniqTextTheme.darkTextTheme.titleLarge?.copyWith(
          color: HarmoniqScheme.dark.onBackground,
        ),
        contentTextStyle: HarmoniqTextTheme.darkTextTheme.bodyMedium?.copyWith(
          color: HarmoniqScheme.dark.onBackground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
