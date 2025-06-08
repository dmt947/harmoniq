//ola

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:harmoniq/firebase_options.dart';
import 'package:harmoniq/services/audio_service.dart';

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

  Future<void> _initSplash() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _audioService.init();
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
