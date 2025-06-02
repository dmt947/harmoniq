import 'package:flutter/material.dart';
import 'harmoniq_colors.dart';
import 'harmoniq_text_styles.dart';

class HarmoniqScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: HarmoniqColors.primary,
    onPrimary: HarmoniqColors.onPrimary,
    secondary: HarmoniqColors.accent,
    onSecondary: HarmoniqColors.onAccent,
    surface: HarmoniqColors.lightSurface,
    onSurface: HarmoniqColors.onLightSurface,
    error: HarmoniqColors.error,
    onError: HarmoniqColors.onError,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: HarmoniqColors.primary,
    onPrimary: HarmoniqColors.onPrimary,
    secondary: HarmoniqColors.accent,
    onSecondary: HarmoniqColors.onAccent,
    surface: HarmoniqColors.darkSurface,
    onSurface: HarmoniqColors.onDarkSurface,
    error: HarmoniqColors.error,
    onError: HarmoniqColors.onError,
  );
}

class HarmoniqTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayMedium: TextStyles.display.copyWith(color: HarmoniqColors.primary),
    headlineMedium: TextStyles.headline.copyWith(
      color: HarmoniqColors.lightBodyText,
    ),
    headlineSmall: TextStyles.smallHeadline.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    titleLarge: TextStyles.titleLarge.copyWith(color: HarmoniqColors.primary),
    titleMedium: TextStyles.title.copyWith(color: HarmoniqColors.primary),
    bodyLarge: TextStyles.largeBody.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    bodyMedium: TextStyles.body.copyWith(color: HarmoniqColors.lightBodyText),
    bodySmall: TextStyles.smallBody.copyWith(
      color: HarmoniqColors.lightBodyText,
    ),
    labelLarge: TextStyles.largeLabel.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    labelMedium: TextStyles.mediumLabel.copyWith(
      color: HarmoniqColors.lightHiddenText,
    ),
    labelSmall: TextStyles.smallLabel.copyWith(color: Colors.white),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayMedium: TextStyles.display.copyWith(color: HarmoniqColors.primary),
    headlineMedium: TextStyles.headline.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    headlineSmall: TextStyles.smallHeadline.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    titleLarge: TextStyles.titleLarge.copyWith(color: HarmoniqColors.primary),
    titleMedium: TextStyles.title.copyWith(color: HarmoniqColors.primary),
    bodyLarge: TextStyles.largeBody.copyWith(
      color: HarmoniqColors.darkPrimaryText,    
    ),
    bodyMedium: TextStyles.body.copyWith(color: HarmoniqColors.darkBodyText),
    bodySmall: TextStyles.smallBody.copyWith(
      color: HarmoniqColors.darkBodyText,
    ),
    labelLarge: TextStyles.largeLabel.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    labelMedium: TextStyles.mediumLabel.copyWith(
      color: HarmoniqColors.darkPrimaryText,
    ),
    labelSmall: TextStyles.smallLabel.copyWith(color: Colors.white),
  );
}
