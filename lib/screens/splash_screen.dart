import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:harmoniq/firebase_options.dart';
import 'package:harmoniq/main.dart';
import 'package:harmoniq/services/audio_service.dart';
import 'package:harmoniq/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationDone;

  const SplashScreen({required this.onInitializationDone, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _audioService = AudioService();
  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeString = prefs.getString(AppConstants.themeModeKey);
    if (themeModeString != null) {
      currentThemeMode.value = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    final localeString = prefs.getString(AppConstants.localeKey);
    if (localeString != null && localeString.isNotEmpty) {
      currentLocale.value = Locale(localeString);
    } else {
      currentLocale.value = null;
    }
  }

  Future<void> _initSplash() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _audioService.init();
    await _loadPreferences();
    await Future.wait([
      Future.delayed(Duration(milliseconds: 500)),
      FirebaseAuth.instance.authStateChanges().first,
    ]);

    widget.onInitializationDone();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
