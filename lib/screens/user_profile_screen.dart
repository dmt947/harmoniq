import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profileScreenTitle),
        ),
        body: Center(
          child: Text(AppLocalizations.of(context)!.usernamePlaceholder),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileScreenTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child:
                    user.photoURL == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
              ),
              const SizedBox(height: 20),
              Text(
                user.displayName ??
                    AppLocalizations.of(context)!.usernamePlaceholder,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                user.email ?? AppLocalizations.of(context)!.emailPlaceholder,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 150),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.logoutButton),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Goes back to HomePage, wich is managed by AuthScreen
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
