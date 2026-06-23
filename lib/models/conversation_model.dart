
import 'package:durakitos/models/user_model.dart';

class Conversation {
  final String chatId; // El ID del documento de chat (ej: uid1_uid2)
  final UserModel otherUser; // El perfil del otro usuario en el chat
  final String lastMessage; // El texto del último mensaje
  final DateTime lastMessageTimestamp; // La fecha y hora del último mensaje
  final String lastMessageSenderId; // Quién envió el último mensaje

  Conversation({
    required this.chatId,
    required this.otherUser,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
  });
}
