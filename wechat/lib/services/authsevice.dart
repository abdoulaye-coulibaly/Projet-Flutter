import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      
    } on FirebaseAuthException catch (e) {
      throw e;
    }
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

 
  Future<dynamic> signInWithGoogle() async {

    try {
       final GoogleSignIn googleSignIn = GoogleSignIn();
       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
        final GoogleSignInAuthentication? googlAuth =
            await googleUser?.authentication;


        final credential = GoogleAuthProvider.credential(
          accessToken: googlAuth?.accessToken,
          idToken: googlAuth?.idToken,
        );
        
      return await _firebaseAuth.signInWithCredential(credential);
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
