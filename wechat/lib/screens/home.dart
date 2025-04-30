import 'package:flutter/material.dart';
import 'package:wechat/screens/userspage.dart';
import 'package:wechat/services/%20chatservice.dart';
import 'package:wechat/services/authsevice.dart';

class Myhomepage extends StatefulWidget {
  const Myhomepage({super.key});

  @override
  State<Myhomepage> createState() => _MyhomepageState();
}

class _MyhomepageState extends State<Myhomepage> {
  final Chatservice _chatservice = Chatservice();
  final AuthService _authService = AuthService();
  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 67, 70, 255),
      title: const Text(
          "We.Chat",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: (){
              _authService.deconnexion(context);
           
          },
        ),
      ],
    ),
    
    floatingActionButton: FloatingActionButton(
      onPressed: () {
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Userspage(),
          ),
        );
      },
      backgroundColor: Color.fromARGB(255, 67, 70, 255),
      child: const Icon(Icons.chat, color: Colors.white),
    ),
  );
}


}
