import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/screens/home.dart';
import 'package:wechat/screens/loginscreen.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? getcurrentUser() => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  



  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<void> deconnexion(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
  
    } on FirebaseAuthException catch (e) {
      throw e;
    }
     Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,);
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await   _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = _firebaseAuth.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'uid': uid,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

 
  Future<dynamic> signInWithGoogle(BuildContext context) async {

    try {
      //  final GoogleSignIn googleSignIn = GoogleSignIn();
       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
        final GoogleSignInAuthentication googlAuth =
            await googleUser!.authentication;


        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googlAuth.accessToken,
          idToken: googlAuth.idToken,
        );
        
        UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        User? user = userCredential.user;
        if (user != null) {
     
          String uid = user.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': user.email,
            'uid': uid,
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          });
        }
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Myhomepage(),
        ),
        (route) => false,);
     
      // Navigator.pushAndRemoveUntil(
      //     context!,
      //     MaterialPageRoute(
      //       builder: (context) => const Myhomepage(),
      //     ),
      //     (route) => false,
      //   );
       
        // String uid = _firebaseAuth.currentUser!.uid;
        // await FirebaseFirestore.instance.collection('users').doc(uid).set({
        //   'email': googleSignInAccount?.email,
        //   'uid': uid,
        //   'createdAt': DateTime.now(),
        //   'updatedAt': DateTime.now(),
        // });
       
      
    } catch (e) {

       throw e;
    }
    
   
  }
}


