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

  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _loading = false;
  String _message = '';

  Future<void> signIn() async {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      createUser();
    } else {
      _message = 'La contraseña debe concidir';
    }
  }

  Future<void> createUser() async {
    setState(() => _loading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrarse')),
      );
    }
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
                      //TO DO: Add background image
                      // Background of the screen
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      child: Align(alignment: Alignment.bottomCenter),
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
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Crea una cuenta nueva',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                    ),
                                    SizedBox(height: 30,),
                                    Column(
                                      children: [
                                        TextField(
                                          controller: userController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre de Usuario',
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        TextField(
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            labelText: 'Correo electrónico',
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        TextField(
                                          controller: passwordController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Contraseña',
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        TextField(
                                          controller: confirmPasswordController,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Confirmar contraseña',
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => LoginPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Ya tengo cuenta',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Blockbutton(
                                      onPressed: signIn,
                                      child: Text('Registrarme'),
                                    ),
                                    Text(
                                      _message,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium!.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
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
