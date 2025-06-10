import 'package:flutter/material.dart';
import 'package:harmoniq/theme/harmoniq_colors.dart';

class HarmoniqScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: HarmoniqColors.primary,
    onPrimary: Colors.white,
    secondary: HarmoniqColors.lightAccent,
    onSecondary: Colors.white,
    surface: HarmoniqColors.lightSurface,
    onSurface: Colors.black87,
    error: HarmoniqColors.error,
    onError: Colors.white,
    background: HarmoniqColors.lightBackground,
    onBackground: Colors.black87,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: HarmoniqColors.primary,
    onPrimary: Colors.white,
    secondary: HarmoniqColors.darkAccent,
    onSecondary: Colors.white,
    surface: HarmoniqColors.darkSurface,
    onSurface: Colors.white,
    error: HarmoniqColors.error,
    onError: Colors.white,
    background: HarmoniqColors.darkBackground,
    onBackground: Colors.white,
  );
}
