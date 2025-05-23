import 'package:flutter/material.dart';
import 'package:harmoniq/theme/harmoniq_theme.dart';

void main(){
    runApp(Harmoniq());
  }

class Harmoniq extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
          title: 'Harmoniq',
          darkTheme: HarmoniqTheme.darkTheme,
          theme: HarmoniqTheme.lightTheme,
          themeMode: ThemeMode.system,
          home: Scaffold()
        );
      }
  }

