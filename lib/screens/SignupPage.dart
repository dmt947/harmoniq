import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoniq/screens/LoginPage.dart';
import 'package:harmoniq/widgets/BlockButton.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _userController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _showError('Completa todos los campos');
      return;
    }

    if (password != confirmPassword) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    await _setLoadingWhile(() async {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(username);

      // Auto Sign In
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Returns to AuthScreen
      Navigator.pop(context);
      
    }).catchError((e) {
      if (e is FirebaseAuthException) {
        String msg = switch (e.code) {
          'email-already-in-use' => 'El correo ya ha sido registrado',
          'weak-password' => 'La contraseña debe tener más de 6 caracteres',
          _ => 'Error al registrar: ${e.message}',
        };
        _showError(msg);
      } else {
        _showError('Ocurrio un error inesperado: $e');
      }
    });
  }

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
        _buildTextField(_userController, 'Nombre de Usuario'),
        const SizedBox(height: 20),
        _buildTextField(
          _emailController,
          'Correo electrónico',
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(_passwordController, 'Contraseña', obscure: true),
        const SizedBox(height: 20),
        _buildTextField(
          _confirmPasswordController,
          'Confirmar contraseña',
          obscure: true,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: Text(
            'Ya tengo cuenta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Blockbutton(onPressed: _signUp, child: const Text('Registrarme'));
    //TODO: Add Google Button
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Crea una cuenta nueva',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 30),
                                  _buildFormFields(context),
                                  const SizedBox(height: 30),
                                  _buildButtons(),
                                ],
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
