import 'package:flutter/material.dart';
import 'package:harmoniq/theme/harmoniq_colors.dart';
import 'package:harmoniq/theme/harmoniq_text_styles.dart';

class HarmoniqTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayMedium: HarmoniqTextStyles.display.copyWith(
      color: HarmoniqColors.primary,
    ),
    headlineMedium: HarmoniqTextStyles.headline,
    headlineSmall: HarmoniqTextStyles.smallHeadline,
    titleLarge: HarmoniqTextStyles.titleLarge.copyWith(
      color: HarmoniqColors.primary,
    ),
    titleMedium: HarmoniqTextStyles.title.copyWith(
      color: HarmoniqColors.primary,
    ),
    bodyLarge: HarmoniqTextStyles.largeBody,
    bodyMedium: HarmoniqTextStyles.body,
    bodySmall: HarmoniqTextStyles.smallBody,
    labelLarge: HarmoniqTextStyles.largeLabel,
    labelMedium: HarmoniqTextStyles.mediumLabel,
    labelSmall: HarmoniqTextStyles.smallLabel.copyWith(color: Colors.white),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayMedium: HarmoniqTextStyles.display.copyWith(
      color: HarmoniqColors.primary,
    ),
    headlineMedium: HarmoniqTextStyles.headline,
    headlineSmall: HarmoniqTextStyles.smallHeadline,
    titleLarge: HarmoniqTextStyles.titleLarge.copyWith(
      color: HarmoniqColors.primary,
    ),
    titleMedium: HarmoniqTextStyles.title.copyWith(
      color: HarmoniqColors.primary,
    ),
    bodyLarge: HarmoniqTextStyles.largeBody,
    bodyMedium: HarmoniqTextStyles.body,
    bodySmall: HarmoniqTextStyles.smallBody,
    labelLarge: HarmoniqTextStyles.largeLabel,
    labelMedium: HarmoniqTextStyles.mediumLabel,
    labelSmall: HarmoniqTextStyles.smallLabel.copyWith(color: Colors.white),
  );
}
