//import 'package:assistant_tfg/providers/conversation_provider.dart';
import 'package:assistant_tfg/repository/auth_repository.dart';
import 'package:assistant_tfg/views/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'themes/theme.dart';
import 'providers/chats_provider.dart';

import 'views/actions/actions_screen.dart';
import 'views/home/home_screen.dart';
import 'views/profile/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
        /*ChangeNotifierProvider(
          create: (_) => ConversationProvider(),
        ),*/
        Provider<AuthenticationRepository>(
          create: (_) => AuthenticationRepository(),
        ),
      ],
      child: Builder(builder: (context) {
        final authRepo = Provider.of<AuthenticationRepository>(context);
        return MaterialApp(
          title: 'Flutter ChatBOT',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              scaffoldBackgroundColor: scaffoldBackgroundColor,
              primaryColor: accentTwo,
              appBarTheme: AppBarTheme(
                color: cardColor,
              )),
          home: StreamBuilder<User?>(
            stream: authRepo.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data?.uid == null) {
                  return const LoginScreen();
                } else {
                  return const MainScreen();
                }
              } else {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
            },
          ),
        );
      }),
    );
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;
  final List<Widget> _screens = const [
    ActionsScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: scaffoldBackgroundColor,
        color: cardColor,
        height: 50,
        items: const <Widget>[
          Icon(Icons.assignment_outlined, size: 30, color: Colors.white),
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
