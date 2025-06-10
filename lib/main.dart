import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:harmoniq/screens/auth_screen.dart';
import 'package:harmoniq/screens/splash_screen.dart';
import 'package:harmoniq/theme/harmoniq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final ValueNotifier<ThemeMode> currentThemeMode = ValueNotifier(
  ThemeMode.system,
);
final ValueNotifier<Locale?> currentLocale = ValueNotifier(null);

Future<void> main() async {
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

  @override
  void initState() {
    super.initState();
    currentThemeMode.addListener(_onThemeOrLocaleChanged);
    currentLocale.addListener(_onThemeOrLocaleChanged);
  }

  @override
  void dispose() {
    currentThemeMode.removeListener(_onThemeOrLocaleChanged);
    currentLocale.removeListener(_onThemeOrLocaleChanged);
    super.dispose();
  }

  void _onThemeOrLocaleChanged() {
    setState(() {});
  }

  void _finishInitialization() {
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmoniq',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: HarmoniqTheme.lightTheme,
      darkTheme: HarmoniqTheme.darkTheme,
      themeMode: currentThemeMode.value,
      locale: currentLocale.value,
      home:
          !_initialized
              ? SplashScreen(onInitializationDone: _finishInitialization)
              : const AuthScreen(),
    );
  }
}
