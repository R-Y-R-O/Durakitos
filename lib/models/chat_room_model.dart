
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants; // IDs de los usuarios en el chat
  final String? lastMessage;
  final Timestamp? lastMessageTimestamp;
  final String? lastMessageSenderId;

  // Opcional: para mostrar nombres y avatares en la lista de chats sin hacer otra consulta
  final Map<String, String?> participantNames;
  final Map<String, String?> participantAvatars;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.lastMessageSenderId,
    this.participantNames = const {},
    this.participantAvatars = const {},
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: data['lastMessageTimestamp'] as Timestamp?,
      lastMessageSenderId: data['lastMessageSenderId'],
      participantNames: Map<String, String?>.from(data['participantNames'] ?? {}),
      participantAvatars: Map<String, String?>.from(data['participantAvatars'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
    };
  }
}
