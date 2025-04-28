import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wechat/screens/chatroom.dart';

class Userspage extends StatefulWidget {
  const Userspage({super.key});

  @override
  State<Userspage> createState() => _UserspageState();
}

class _UserspageState extends State<Userspage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New chat",
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: const Color.fromARGB(255, 67, 70, 255),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading users"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }
                

                final filteredUsers = snapshot.data!.docs.where((userData) {
                  final user = userData.data();
                  final email = user['email'].toString().toLowerCase();
                  return searchQuery.isEmpty || email.contains(searchQuery);
                }).toList();
                
                if (filteredUsers.isEmpty) {
                  return const Center(child: Text("No users found"));
                }
                
                return ListView(
                  children: filteredUsers.map<Widget>((userData) {
                    final user = userData.data();
                    if (user['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      title: Text(user['email']),
                  
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person),
                      ),
                      
                     
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chatroom(
                              receiverId: userData['uid'],
                              receiverEmail: userData['email'],
                            ),
                          ),  
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}