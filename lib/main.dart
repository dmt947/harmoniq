import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harmoniq/theme/harmoniq_theme.dart';
import 'package:harmoniq/screens/AuthScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: AuthScreen(),
    );
  }
}
