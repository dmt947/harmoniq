import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harmoniq/screens/signup_page.dart';
import 'package:harmoniq/widgets/block_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Reusable method to display errors
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Encapsulates setState on async operations
  Future<void> _setLoadingWhile(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    await _setLoadingWhile(() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // First signs in
      final userCredential = await _auth.signInWithCredential(credential);

      // Then updates username
      final displayName = googleUser.displayName;
      await userCredential.user?.updateDisplayName(displayName);

      await userCredential.user?.reload();
    }).catchError((e) {
      if (e is FirebaseAuthException) {
        final msg = switch (e.code) {
          'account-exists-with-different-credential' =>
            AppLocalizations.of(context)!.accountExistsWithDifferentCredential,
          'invalid-credential' =>
            AppLocalizations.of(context)!.invalidCredential,
          _ => AppLocalizations.of(context)!.unknownSignInError,
        };
        _showError(msg);
      } else {
        _showError(AppLocalizations.of(context)!.unknownGenericError);
      }
    });
  }

  Future<void> signInWithCredentials() async {
    FocusScope.of(context).unfocus();
    await _setLoadingWhile(() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(code: 'missing-fields');
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    }).catchError((e) {
      if (e is FirebaseAuthException) {
        final msg = switch (e.code) {
          'user-not-found' => AppLocalizations.of(context)!.userNotFound,
          'wrong-password' => AppLocalizations.of(context)!.wrongPassword,
          'invalid-email' => AppLocalizations.of(context)!.invalidEmail,
          'missing-fields' => AppLocalizations.of(context)!.authMissingFields,
          _ => AppLocalizations.of(context)!.unknownSignInError,
        };
        _showError(msg);
      } else {
        _showError(AppLocalizations.of(context)!.unknownGenericError);
      }
    });
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          emailController,
          AppLocalizations.of(context)!.emailPlaceholder,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          passwordController,
          AppLocalizations.of(context)!.passwordPlaceholder,
          obscure: true,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupPage()),
            );
          },
          child: Text(
            AppLocalizations.of(context)!.noAccount,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Blockbutton(
          onPressed: signInWithCredentials,
          child: Text(AppLocalizations.of(context)!.loginButton),
        ),
        const SizedBox(height: 20),
        Blockbutton(
          onPressed: signInWithGoogle,
          child: Text(AppLocalizations.of(context)!.loginWithGoogleButton),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/login_background.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/main_logo.png', fit: BoxFit.contain,),
                                    SizedBox(height: 40),
                                    _buildFormFields(context),
                                    const SizedBox(height: 30),
                                    _buildButtons(),
                                    const SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
