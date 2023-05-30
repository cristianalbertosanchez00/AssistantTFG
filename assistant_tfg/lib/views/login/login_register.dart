import 'package:assistant_tfg/themes/theme.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

//import '../../main.dart';
//import '../../repository/auth_repository.dart';

class LoginRegister extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  LoginRegister({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth *
                    0.05), // Espacio lateral basado en el ancho del dispositivo
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Image.asset(
                  'assets/images/logo.png', // Reemplaza 'assets/images/logo.png' por la ruta de tu logo
                  height: 150,
                ),
                const SizedBox(
                    height: 20), // Añade espacio entre el logo y el subtítulo
                // Subtitulo
                const Text(
                  'Crea tu cuenta o inicia sesión',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                    height:
                        20), // Añade espacio entre el subtítulo y el campo de texto
                // Campo de texto para el email
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bordado redondeado
                    ),
                    labelText: 'Introduce tu email',
                  ),
                ),
                const SizedBox(
                    height:
                        20), // Añade espacio entre el campo de texto y el botón
                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTwo, // color del botón
                      foregroundColor: Colors.white, // color del texto
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // bordes redondeados
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Continuar'),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
