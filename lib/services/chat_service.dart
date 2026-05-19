
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/models/conversation_model.dart';
import 'package:rxdart/rxdart.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> getMessages(String receiverId) {
    List<String> ids = [_currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Generalmente los mensajes más nuevos van abajo
        .snapshots();
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final timestamp = Timestamp.now();

    List<String> ids = [_currentUserId, receiverId];
    ids.sort(); // Es crucial ordenar los IDs para tener un ID de sala consistente
    String chatRoomId = ids.join('_');

    final newMessage = {
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };

    // Añadir el nuevo mensaje
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // Actualizar el documento 'puntero' de la sala de chat
    await _firestore.collection('chats').doc(chatRoomId).set({
      'participants': ids, // ¡CORREGIDO! Se guarda como una lista para poder consultarla.
      'lastMessage': message,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': _currentUserId,
    }, SetOptions(merge: true)); // Usar merge para no sobrescribir si ya existe
  }

  Stream<List<Conversation>> getConversations() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId) // Esta consulta ahora funcionará correctamente
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .switchMap((snapshot) {
      if (snapshot.docs.isEmpty) {
        return Stream.value([]);
      }

      // Mapeamos cada documento de chat a un Stream<Conversation?> (ahora acepta nulos)
      List<Stream<Conversation?>> conversationStreams = snapshot.docs.map((doc) {
        final chatData = doc.data();
        
        // Encontramos el ID del otro usuario en la lista de participantes
        final otherUserId = (chatData['participants'] as List<dynamic>)
            .firstWhere((id) => id != _currentUserId, orElse: () => '');

        if (otherUserId.isEmpty) return Stream.value(null); // Caso de seguridad

        // Escuchamos los datos del otro usuario para tener su información actualizada
        return _firestore.collection('users').doc(otherUserId).snapshots().map((userSnapshot) {
          if (!userSnapshot.exists) return null;

          final otherUser = UserModel.fromFirestore(userSnapshot.data()!, userSnapshot.id);
          
          return Conversation(
            chatId: doc.id,
            otherUser: otherUser,
            lastMessage: chatData['lastMessage'] ?? '',
            lastMessageTimestamp: (chatData['lastMessageTimestamp'] as Timestamp).toDate(),
            lastMessageSenderId: chatData['lastMessageSenderId'] ?? '',
          );
        });
      }).toList();

      // Combinamos todos los streams en uno solo y filtramos los resultados nulos
      return CombineLatestStream.list(conversationStreams).map((conversations) {
        return conversations.where((c) => c != null).cast<Conversation>().toList();
      });
    });
  }
}
