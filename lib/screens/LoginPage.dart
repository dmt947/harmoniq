import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harmoniq/screens/SignupPage.dart';
import 'package:harmoniq/widgets/BlockButton.dart';

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
            'Ya existe una cuenta con otro método',
          'invalid-credential' => 'Credencial inválida, intenta de nuevo',
          _ => 'Error al iniciar sesión',
        };
        _showError(msg);
      } else {
        _showError('Ocurrió un error inesperado: $e');
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
          'user-not-found' => 'Usuario no encontrado',
          'wrong-password' => 'Contraseña incorrecta, intenta de nuevo',
          'invalid-email' => 'Correo inválido',
          'missing-fields' => 'Debes proporcionar un correo y contraseña',
          _ => 'Error al iniciar sesión: ${e.code}',
        };
        _showError(msg);
      } else {
        _showError('Ocurrió un error inesperado: $e');
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
        _buildTextField(emailController, 'Correo electronico', keyboard: TextInputType.emailAddress),
        const SizedBox(height: 20),
        _buildTextField(passwordController, 'Contraseña', obscure: true),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupPage()),
            );
          },
          child: Text(
            'No tengo cuenta',
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
          child: const Text('Iniciar sesión'),
        ),
        const SizedBox(height: 20),
        Blockbutton(
          onPressed: signInWithGoogle,
          child: const Text('Iniciar sesión con Google'),
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
                      color: Theme.of(context).appBarTheme.backgroundColor,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 200),
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
                                    Text(
                                      'Harmoniq',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.displayMedium,
                                    ),
                                    const SizedBox(height: 40),
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
