import 'package:flutter/material.dart';

class Chatbubble extends StatelessWidget {

  final String message;
  final bool isCurrentUser;

  const Chatbubble({super.key,
    required this.message,
    required this.isCurrentUser,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Text(message),
    );
  }
}