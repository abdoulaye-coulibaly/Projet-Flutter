import 'package:flutter/material.dart';
import 'package:wechat/screens/home.dart';
import 'package:wechat/screens/loginscreen.dart';
import 'package:wechat/services/authsevice.dart';

class Redirectpage extends StatefulWidget {
  const Redirectpage({super.key});

  @override
  State<Redirectpage> createState() => _RedirectpageState();
}

class _RedirectpageState extends State<Redirectpage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: Auth().authStateChanges, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
        } else if(snapshot.hasData) {
        return const Myhomepage();
      }
      else {
        return const LoginScreen();
      }
    });
  }
}