import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wechat/messagestyle/bubblechat.dart';
import 'package:wechat/services/%20chatservice.dart';
import 'package:wechat/services/authsevice.dart';

class Chatroom extends StatelessWidget {
  final String receiverEmail;
  final String receiverId;
  Chatroom({super.key, required this.receiverEmail, required this.receiverId});

  final TextEditingController _messageController = TextEditingController();
  final Chatservice _chatservice = Chatservice();
  final AuthService _authService = AuthService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatservice.sendMessage(receiverId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverEmail, style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),)
      
      , centerTitle: true
          , backgroundColor: const Color.fromARGB(255, 67, 70, 255)),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getcurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatservice.getMessage(receiverId, senderID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }
        // final messages = snapshot.data!.docs;

        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _authService.getcurrentUser()!.uid;
    var messageAlignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: messageAlignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Chatbubble(message: data['message'], isCurrentUser: isCurrentUser),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 67, 70, 255),
            ),
            margin: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
