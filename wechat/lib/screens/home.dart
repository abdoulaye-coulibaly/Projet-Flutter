import 'package:flutter/material.dart';
import 'package:wechat/screens/userspage.dart';
import 'package:wechat/services/ chatservice.dart';
import 'package:wechat/services/authsevice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Myhomepage extends StatefulWidget {
  const Myhomepage({super.key});

  @override
  State<Myhomepage> createState() => _MyhomepageState();
}

class _MyhomepageState extends State<Myhomepage> {
  final Chatservice _chatservice = Chatservice();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _chatservice.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 70, 255),
        title: const Text(
          "We.Chat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.deconnexion(context);
            },
          ),
        ],
      ),
      body: _buildChatList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Userspage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 67, 70, 255),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList() {
    final currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final relevantChats = snapshot.data!.docs.where((doc) {
          final chatId = doc.id;
          return chatId.contains(currentUserId);
        }).toList();

        if (relevantChats.isEmpty) {
          return const Center(child: Text('Aucune discussion pour le moment'));
        }

        return ListView.builder(
          itemCount: relevantChats.length,
          itemBuilder: (context, index) {
            final chatDoc = relevantChats[index];
            final chatId = chatDoc.id;
            final userIds = chatId.split('_');

            if (userIds.length != 2) return const SizedBox.shrink();

            final otherUserId = userIds[0] == currentUserId ? userIds[1] : userIds[0];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final userEmail = userData['email'] ?? 'Sans email';
                final userImage = userData['profileImage'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
                    child: userImage.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(userEmail),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                        return const Text('Aucun message');
                      }
                      final messageData = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                      final lastMessage = messageData['message'] ?? '';
                      return Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatroom(
                          receiverId: otherUserId,
                          receiverEmail: userEmail,
                          chatId: chatId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class Chatroom extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;
  final String chatId;

  const Chatroom({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverEmail)),
      body: Center(child: Text('Chat avec $receiverEmail')),
    );
  }
}
