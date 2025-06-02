import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoniq/screens/home_page.dart';
import 'package:harmoniq/screens/login_page.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //Circular Indicator
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // Logged In
          return const HomePage();
        } else {
          // Not Logged In
          return const LoginPage();
        }
      },
    );
  }
}
