import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wechat/models/chatmodel.dart';

class Chatservice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }
  
Stream<QuerySnapshot> getMessage(String userID,otherUserID) {
    List<String> userIds = [userID, otherUserID];
    userIds.sort();
    String chatId = userIds.join('_');
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String receiverId, message) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );
    List<String> userIds = [currentUserId, receiverId];
    userIds.sort();
    String chatId = userIds.join('_');
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }
}
