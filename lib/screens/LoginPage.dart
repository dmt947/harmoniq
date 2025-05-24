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

  bool _loading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Methods
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled operation
        setState(() => _loading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String msg = switch (e.code) {
        'account-exists-with-different-credential' =>
          'Ya existe una cuenta con otro metodo',
        'invalid-credential' => 'Credencial Invalida, intenta de nuevo',
        _ => 'Eror al iniciar sesion: ${e.message}',
      };

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrio un error inesperado: $e')),
      );
      print(e);
    }
  }

  // Sign in with password and email
  Future<void> signInWithCredentials() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String msg = switch (e.code) {
        'user-not-found' => 'Usuario no encontrado',
        'wrong-password' => 'Contraseña incorrecta, intenta de nuevo',
        'invalid-email' => 'Correo invalido',
        _ => 'Error al iniciar sesion: ${e.message}',
      };

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrio un error inesperado: $e')),
      );
      print(e);
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
                                    Text(
                                      'Harmoniq',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.displayMedium,
                                    ),
                                    SizedBox(height: 40),
                                    Column(
                                      children: [
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
                                        SizedBox(height: 10),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => SignupPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'No tengo cuenta',
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
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Blockbutton(
                                          onPressed: signInWithCredentials,
                                          child: Text('Iniciar Sesion'),
                                        ),
                                        SizedBox(height: 20),
                                        Blockbutton(
                                          onPressed: signInWithGoogle,
                                          child: Text(
                                            // TODO: Change Google Button to the one in the requirements
                                            'Iniciar Sesion con Google',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 50),
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
