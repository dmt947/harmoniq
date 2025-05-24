import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${user?.email ?? 'usuario'}'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      body: const Center(child: Text('Esta es la página principal')),
    );
  }
}
