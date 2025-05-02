import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wechat/messagestyle/bubblechat.dart';
import 'package:wechat/services/ chatservice.dart'; // Espace corrigé
import 'package:wechat/services/authsevice.dart';

class Chatroom extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;
  
  const Chatroom({
    Key? key, 
    required this.receiverEmail, 
    required this.receiverId
  }) : super(key: key);
  
  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final TextEditingController _messageController = TextEditingController();
  final Chatservice _chatservice = Chatservice();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  
  // Faire défiler automatiquement vers le dernier message
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  // Envoyer un message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatservice.sendMessage(widget.receiverId, _messageController.text);
      _messageController.clear();
      
      // Attendre un court instant pour que le nouveau message soit ajouté à la liste
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.receiverEmail, 
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(widget.receiverId).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                  bool isOnline = userData['isOnline'] ?? false;
                  return Text(
                    isOnline ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: isOnline ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 67, 70, 255),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              onPressed: () {
                // Afficher plus d'informations sur l'utilisateur
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Informations - ${widget.receiverEmail}'),
                    content: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(widget.receiverId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('Aucune information disponible');
                        }
                        
                        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (userData['profileImage'] != null)
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(userData['profileImage']),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text('Nom: ${userData['username'] ?? 'Non spécifié'}'),
                            Text('Email: ${userData['email'] ?? 'Non spécifié'}'),
                            if (userData['bio'] != null)
                              Text('Bio: ${userData['bio']}'),
                          ],
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }
  
  Widget _buildMessageList() {
    String senderID = _authService.getcurrentUser()!.uid;
    
    return StreamBuilder<QuerySnapshot>(
      stream: _chatservice.getMessages(widget.receiverId),
      builder: (context, snapshot) {
        // Une fois que les données sont chargées, faire défiler vers le bas
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Erreur lors du chargement des messages: ${snapshot.error}"));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Aucun message avec ${widget.receiverEmail}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Envoyez un message pour commencer la conversation',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }
  
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Adapter le nom de la clé - utilisez 'senderID' ou 'senderId' selon votre modèle
    String senderId = data['senderID'] ?? data['senderId'] ?? '';
    bool isCurrentUser = senderId == _authService.getcurrentUser()!.uid;
    
    var messageAlignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    
    return Container(
      alignment: messageAlignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Chatbubble(
              message: data['message'] ?? '',
              isCurrentUser: isCurrentUser,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isCurrentUser ? 0 : 16,
              right: isCurrentUser ? 16 : 0,
              bottom: 8,
            ),
            child: Text(
              _formatTimestamp(data['timestamp']),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();
    
    // Si le message date d'aujourd'hui, afficher juste l'heure
    if (messageTime.day == now.day && 
        messageTime.month == now.month && 
        messageTime.year == now.year) {
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
    
    // Si le message date d'hier
    DateTime yesterday = now.subtract(const Duration(days: 1));
    if (messageTime.day == yesterday.day && 
        messageTime.month == yesterday.month && 
        messageTime.year == yesterday.year) {
      return 'Hier, ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
    
    // Sinon afficher la date complète
    return '${messageTime.day.toString().padLeft(2, '0')}/${messageTime.month.toString().padLeft(2, '0')}/${messageTime.year}, ${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
  }
  
  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Color.fromARGB(255, 67, 70, 255)),
            onPressed: () {
              // Fonctionnalité pour envoyer une image
              // À implémenter si nécessaire
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 240, 240, 240),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 67, 70, 255),
            ),
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