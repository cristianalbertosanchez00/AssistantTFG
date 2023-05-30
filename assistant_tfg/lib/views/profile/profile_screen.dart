import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../repository/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationRepository>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: StreamBuilder(
            stream: authRepo.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                User? user = snapshot.data;
                if (user == null) {
                  return const Text('No se ha iniciado sesión');
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 100),
                      user.photoURL != null
                          ? CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage(user.photoURL!),
                              backgroundColor: Colors.transparent,
                            )
                          : const SizedBox(
                              height: 140,
                              child: Image(
                                image: AssetImage('assets/images/profile.png'),
                              ),
                            ),
                      const SizedBox(height: 20),
                      Text(
                        "${FirebaseAuth.instance.currentUser!.email}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () {
                          authRepo.signOut(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
