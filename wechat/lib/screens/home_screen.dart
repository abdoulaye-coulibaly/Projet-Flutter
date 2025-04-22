import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void startChat(BuildContext context) async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Démarrer une discussion"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Email de l'utilisateur"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser!;
              final otherEmail = emailController.text.trim();

              final chatId = [currentUser.email, otherEmail]..sort();
              final chatDoc = chatId.join('_');

              await FirebaseFirestore.instance.collection('chats').doc(chatDoc).set({
                'users': chatId,
              });

              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatDoc)),
              );
            },
            child: const Text("Créer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(child: Text("Aucune discussion."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(chat['users']);
              final other = participants.firstWhere((e) => e != currentUser.email);

              return ListTile(
                title: Text(other),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(chatId: chat.id)),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => startChat(context),
        child: const Icon(Icons.message),
      ),
    );
  }
}
