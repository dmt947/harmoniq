import 'package:flutter/material.dart';
import 'package:harmoniq/screens/AuthScreen.dart';
import 'package:harmoniq/screens/SplashScreen.dart';
import 'package:harmoniq/theme/harmoniq_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Harmoniq());
}

class Harmoniq extends StatefulWidget {
  const Harmoniq({super.key});

  @override
  State<StatefulWidget> createState() => _HarmoniqState();
}

class _HarmoniqState extends State<Harmoniq> {
  bool _initialized = false;

  void _finishInitialization() {
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmoniq',
      darkTheme: HarmoniqTheme.darkTheme,
      theme: HarmoniqTheme.lightTheme,
      themeMode: ThemeMode.system,
      home:
          !_initialized
              ? SplashScreen(onInitializationDone: _finishInitialization)
              : AuthScreen(),
    );
  }
}
