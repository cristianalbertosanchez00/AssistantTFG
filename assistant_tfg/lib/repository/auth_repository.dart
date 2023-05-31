import 'package:assistant_tfg/views/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';

/// -- README(Docs[6]) -- Bindings
class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthenticationRepository()
      : _firebaseAuth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// variables
/*
  late final User?_firebaseUser;
  final _auth = FirebaseAuth.instance;
  final _phoneVerificationId = ''.obs;

  /// Getters
  User? get firebaseUser => _firebaseUser.value;
  String get getUserID => firebaseUser?.uid ?? "";
  String get getUserEmail => firebaseUser?.email ?? "";

  /// Loads when app Launch from moin.dart

  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStrean(_auth.userChanges());
    FlutterNativeSplash.remove();
    setInitialScreen(_firebaseUser.value);
// ever(_firebaseUser, _setInitialScreen);
  }
*/
  /// Setting initial screen
  setInitialScreen(User? user) async {}

/*-----------------------Email & Password sign-in ----------------------------*/

/// [EmailAuthenticationLOGIN] - LOGIN
Future<UserCredential?> loginWithEmailAndPassword(
    String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The password is incorrect',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    return null;
  }
}


  /// [EmailAuthenticationREGISTER] - REGISTER
  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'email': email,
      'provider': 'mail',

      // Agregar otros datos del usuario que quieras almacenar
    });
    return userCredential;
  }

  /// [EmailExists] - EMAIL EXISTS
  Future<bool> emailExists(String email) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return query.docs.isNotEmpty;
  }

  /// [EmoilVerification] - VERIFICATION
  Future<void> sendEmailVerification() async {}

/*------------------ Federated identity & social sign-in ------------------------*/

  /// [GoogleAuthentication]
  Future<UserCredential> signInWithGoogle() async {
    GoogleSignInAccount? googleUser;

    try {
      // Attempt to sign in without user interaction
      googleUser = await _googleSignIn.signInSilently();
    } catch (e) {
      if (kDebugMode) {
        print('Error in signInSilently: $e');
      }
    }

    if (googleUser == null) {
      try {
        // If silent sign in fails, attempt to sign in with user interaction
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        if (kDebugMode) {
          print('Error in signIn: $e');
        }
        rethrow; // Re-throw the exception to be handled by calling function
      }
    }

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    // Store user information in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'email': userCredential.user?.email,
      'provider': 'google',
      // Add other user information you wish to store
    });

    return userCredential;
  }

  Future<void> signOut(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false);
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

/*
  ///[FacebookAuthentication]
  Future<UserCredential> signInWithFacebook() async {
    ;
  }

  /// [PhoneAuthentication] - LOGIN
  ToginWithPhoneNo(String phoneNumber) async {
    ;
  }

// [PhoneAuthentication] - REGISTER
  Future<void> phoneAuthentication(String phoneNo) async {
    ;
  }

  /// [PhoneAuthentication] - VERIFY PHONE NO BY OTP
  Future<bool> verify0TP(String otp) async {
    ;
  }*/
}
