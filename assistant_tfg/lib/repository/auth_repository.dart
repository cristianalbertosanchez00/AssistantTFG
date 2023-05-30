import 'package:assistant_tfg/views/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// [EmoilAuthentication] - LOGIN
  Future<void> loginWithEnailAndPassword(String email, String password) async {}

  /// [EmoilAuthentication] - REGISTER
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {}

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
    return await _firebaseAuth.signInWithCredential(credential);
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
