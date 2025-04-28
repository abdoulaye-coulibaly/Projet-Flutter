import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profilpage extends StatelessWidget {
  const Profilpage({super.key});

  User? get currentUser => FirebaseAuth.instance.currentUser;
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    if (currentUser != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
    }
    throw Exception("User not logged in");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  "https://i.postimg.cc/mhhVywp9/splash-1.png"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Username",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Email",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logout logic here
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}