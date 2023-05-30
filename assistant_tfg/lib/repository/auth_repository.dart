import 'package:assistant_tfg/views/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return userCredential;
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
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    // Almacena la información del usuario en Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'email': userCredential.user?.email,
      'provider': 'google',
      // Agregar otros datos del usuario que quieras almacenar
    });

    return userCredential;
  }

  Future<void> signOut(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
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
