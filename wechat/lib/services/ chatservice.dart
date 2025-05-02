import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wechat/models/chatmodel.dart';

class Chatservice {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'utilisateur actuel
  String get currentUserId => _auth.currentUser!.uid;

  // Récupère la liste des conversations pour un utilisateur
  Stream<QuerySnapshot> getUserChats() {
    // On cherche tous les documents de chat où l'ID contient l'ID de l'utilisateur courant
    return _firestore
        .collection('chats')
        .where('userIds', arrayContains: currentUserId)
        .snapshots();
  }

  // Création d'un champ userIds pour faciliter les requêtes
  Future<void> _ensureUserIdsField() async {
    // Récupère tous les chats
    QuerySnapshot chatsSnapshot = await _firestore.collection('chats').get();
    
    for (var doc in chatsSnapshot.docs) {
      String chatId = doc.id;
      List<String> userIds = chatId.split('_');
      
      if (userIds.length == 2) {
        // Met à jour le document pour ajouter le champ userIds s'il n'existe pas
        await _firestore.collection('chats').doc(chatId).set({
          'userIds': userIds,
          'lastUpdated': Timestamp.now(),
        }, SetOptions(merge: true));
      }
    }
  }

  // Récupère les informations d'un utilisateur
  Future<DocumentSnapshot> getUserInfo(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  // Récupère le dernier message d'un chat
  Stream<QuerySnapshot> getLastMessage(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // Récupère les messages entre l'utilisateur et un autre utilisateur
  Stream<QuerySnapshot> getMessages(String otherUserID) {
    // Conserve votre logique existante
    final String currentUserId = _auth.currentUser!.uid;
    List<String> userIds = [currentUserId, otherUserID];
    userIds.sort(); // Tri pour s'assurer que l'ID du chat est toujours le même
    String chatId = userIds.join('_');
    
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Alias pour maintenir la compatibilité avec votre code existant
  Stream<QuerySnapshot> getMessage(String userID, String otherUserID) {
    return getMessages(otherUserID);
  }

  // Envoie un message
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    
    // Créer un nouveau message avec votre modèle existant
    Message newMessage = Message(
      senderID: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );
    
    // Créer l'ID du chat
    List<String> userIds = [currentUserId, receiverId];
    userIds.sort();
    String chatId = userIds.join('_');
    
    // Ajouter le message à la sous-collection messages
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
    
    // Mettre à jour ou créer le document de chat principal avec des informations supplémentaires
    await _firestore.collection('chats').doc(chatId).set({
      'userIds': userIds,
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'users': userIds, // Pour la compatibilité avec le code que j'ai fourni
    }, SetOptions(merge: true));
  }

  // Initialiser le service pour assurer que tous les champs nécessaires existent
  Future<void> initialize() async {
    await _ensureUserIdsField();
  }
}