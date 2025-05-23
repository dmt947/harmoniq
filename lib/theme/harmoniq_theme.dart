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
        elevation: 0
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HarmoniqScheme.light.secondary,
          foregroundColor: HarmoniqColors.darkBodyText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: HarmoniqTextTheme.lightTextTheme.labelLarge
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HarmoniqScheme.light.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: HarmoniqTextTheme.lightTextTheme.labelSmall,
        floatingLabelStyle: HarmoniqTextTheme.lightTextTheme.labelSmall
      ),
      iconTheme: IconThemeData(
        color: HarmoniqScheme.light.secondary,        
      )
    );
  }

  static ThemeData get darkTheme {
        return ThemeData(
      useMaterial3: true,
      colorScheme: HarmoniqScheme.dark,
      textTheme: HarmoniqTextTheme.darkTextTheme,
      scaffoldBackgroundColor: HarmoniqColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: HarmoniqScheme.dark.primary,
        foregroundColor: HarmoniqColors.darkBodyText,
        elevation: 0
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HarmoniqScheme.dark.secondary,
          foregroundColor: HarmoniqColors.darkBodyText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: HarmoniqTextTheme.darkTextTheme.labelLarge
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HarmoniqScheme.dark.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: HarmoniqTextTheme.darkTextTheme.labelSmall,
        floatingLabelStyle: HarmoniqTextTheme.darkTextTheme.labelSmall
      ),
      iconTheme: IconThemeData(
        color: HarmoniqScheme.dark.secondary,        
      )
    );
  }
}
