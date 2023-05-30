import 'package:assistant_tfg/themes/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../repository/auth_repository.dart';

class LoginRegister extends StatelessWidget {
  final TextEditingController emailController;
  final Future<bool> emailExists;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  LoginRegister({
    Key? key,
    required this.emailController,
    required this.emailExists,
  })  : passwordController = TextEditingController(),
        confirmPasswordController = TextEditingController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    void validatePassword() {
      final String password = passwordController.text;
      final String confirmPassword = confirmPasswordController.text;
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Las contraseñas deben coincidir.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Lógica para manejar el botón presionado
      }
    }

    return FutureBuilder<bool>(
      future: emailExists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bool emailExists = snapshot.data ?? false;
        final title = emailExists ? 'Inicia sesión' : 'Regístrate';
        final buttonText = emailExists ? 'Iniciar sesión' : 'Continuar';
        final passwordField = emailExists ? 'Contraseña' : 'Contraseña*';
        final confirmPasswordField =
            emailExists ? null : 'Confirmar contraseña*';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
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
                    if (!emailExists) ...[
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: passwordField,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: confirmPasswordField,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: passwordField,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!emailExists) {
                            validatePassword;
                            final BuildContext currentContext = context;
                            final authRepo =
                                Provider.of<AuthenticationRepository>(
                                    currentContext,
                                    listen: false);
                            authRepo.registerWithEmail(
                                emailController.text, passwordController.text);
                            Navigator.pushReplacement(
                              currentContext,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                            );
                          } else {
                            final BuildContext currentContext = context;
                            final authRepo =
                                Provider.of<AuthenticationRepository>(
                                    currentContext,
                                    listen: false);
                            authRepo.loginWithEmailAndPassword(
                                emailController.text, passwordController.text);
                            Navigator.pushReplacement(
                              currentContext,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(buttonText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
