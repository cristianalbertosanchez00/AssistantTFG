import 'package:assistant_tfg/themes/theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../repository/auth_repository.dart';
import 'login_register.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tu asistente personal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Introduce tu email',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final String email = emailController.text;
                      if (EmailValidator.validate(email)) {
                        final BuildContext currentContext = context;
                        final authRepo = Provider.of<AuthenticationRepository>(
                          currentContext,
                          listen: false,
                        );
                        final Future<bool> emailExists =
                            authRepo.emailExists(email);
                        Navigator.push(
                          currentContext,
                          MaterialPageRoute(
                            builder: (context) => LoginRegister(
                              emailController: emailController,
                              emailExists: emailExists,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Introduce un email válido',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTwo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Continuar'),
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Añade un espacio antes del 'o'
                // Texto 'o' con líneas a los lados
                const Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: Colors.white)),
                    Text(
                      '    O    ',
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(child: Divider(color: Colors.white)),
                  ],
                ),
                const SizedBox(
                    height: 30), // Añade espacio entre el 'o' y los botones
                // Botón para iniciar sesión con Google
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final BuildContext currentContext = context;
                      final authRepo = Provider.of<AuthenticationRepository>(
                          currentContext,
                          listen: false);
                      authRepo
                          .signInWithGoogle()
                          .then((UserCredential userCredential) {
                        if (userCredential.user != null) {
                          // El usuario ha iniciado sesión correctamente
                          // Navegar a la pantalla principal
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(
                                builder: (context) => const MainScreen()),
                          );
                        }
                      });
                      // Aquí puedes añadir la lógica para iniciar sesión con Google
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // color del botón
                      foregroundColor: Colors.black, // color del texto
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // bordes redondeados
                        side: const BorderSide(
                            color: Colors.grey, width: 1), // borde
                      ),
                    ),
                    icon: Image.asset('assets/images/google_logo.png',
                        height: 40), // Logo de Google
                    label: const Text('Continuar con Google'),
                  ),
                ),
                const SizedBox(height: 15), // Añade espacio entre los botones
                // Botón para iniciar sesión con Facebook
              ],
            ),
          ),
        ),
      ),
    );
  }
}
