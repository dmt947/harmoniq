import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:harmoniq/screens/auth_screen.dart';
import 'package:harmoniq/screens/splash_screen.dart';
import 'package:harmoniq/theme/harmoniq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate, // El delegado generado
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
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
