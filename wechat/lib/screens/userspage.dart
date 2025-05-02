import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatroom.dart';

class Userspage extends StatelessWidget {
  const Userspage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveaux messages"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erreur'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) => doc.id != currentUser!.uid).toList();

          if (users.isEmpty) {
            return const Center(child: Text("Aucun autre utilisateur"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;
              final email = userData['email'] ?? 'email inconnu';
              final profileImage = userData['profileImage'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                  child: profileImage.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chatroom(
                        receiverId: user.id,
                        receiverEmail: email,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
