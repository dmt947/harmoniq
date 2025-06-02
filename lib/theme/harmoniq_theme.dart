import 'package:flutter/material.dart';
import 'harmoniq_scheme.dart';
import 'harmoniq_colors.dart';

class HarmoniqTheme {
  HarmoniqTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: HarmoniqScheme.light,
      textTheme: HarmoniqTextTheme.lightTextTheme,
      scaffoldBackgroundColor: HarmoniqColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: HarmoniqScheme.light.primary,
        foregroundColor: HarmoniqColors.darkBodyText,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HarmoniqScheme.light.primary,
          foregroundColor: HarmoniqColors.darkBodyText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: HarmoniqTextTheme.lightTextTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HarmoniqScheme.light.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: HarmoniqTextTheme.lightTextTheme.labelMedium,
        floatingLabelStyle: HarmoniqTextTheme.lightTextTheme.labelMedium,
      ),
      iconTheme: IconThemeData(color: HarmoniqColors.lightBackground),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HarmoniqColors.onLightSurface,
        contentTextStyle: HarmoniqTextTheme.lightTextTheme.labelMedium
            ?.copyWith(color: HarmoniqColors.error),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: HarmoniqScheme.dark.primary,
        foregroundColor: HarmoniqColors.darkBodyText,
        shape: CircleBorder(),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: HarmoniqScheme.dark,
      textTheme: HarmoniqTextTheme.darkTextTheme,
      primaryColor: HarmoniqScheme.dark.primary,
      scaffoldBackgroundColor: HarmoniqColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: HarmoniqScheme.dark.primary,
        foregroundColor: HarmoniqColors.darkBodyText,
        elevation: 0,
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: HarmoniqColors.darkBackground,
        labelColor: HarmoniqColors.darkBodyText,
        unselectedLabelColor: HarmoniqColors.lightBodyText,
        indicator: BoxDecoration(
          color: HarmoniqColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(24))
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HarmoniqScheme.dark.primary,
          foregroundColor: HarmoniqColors.darkBodyText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: HarmoniqTextTheme.darkTextTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HarmoniqScheme.dark.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: HarmoniqTextTheme.darkTextTheme.labelMedium,
        floatingLabelStyle: HarmoniqTextTheme.darkTextTheme.labelMedium,
      ),
      iconTheme: IconThemeData(color: HarmoniqColors.lightBackground),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HarmoniqColors.onDarkSurface,
        contentTextStyle: HarmoniqTextTheme.darkTextTheme.labelMedium?.copyWith(
          color: HarmoniqColors.error,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: HarmoniqScheme.dark.primary,
        foregroundColor: HarmoniqColors.darkBodyText,
        shape: CircleBorder(),
      ),
    );
  }
}
