import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
 final  String senderID;
 final String senderEmail;
 final String receiverId;
 final String message;
 final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.receiverId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
  });


  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }

  

  
}