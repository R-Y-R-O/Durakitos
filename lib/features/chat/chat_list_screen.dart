
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/chat_room_model.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final chatRooms = snapshot.data;
          if (chatRooms == null || chatRooms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No tienes conversaciones activas.\nInicia una desde el perfil de un contacto.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              return _ChatListTile(chatRoom: room);
            },
          );
        },
      ),
    );
  }
}

// Widget para cada elemento de la lista de chats
class _ChatListTile extends StatelessWidget {
  final ChatRoom chatRoom;
  const _ChatListTile({required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    // Encontrar el ID, nombre y avatar del otro usuario
    final otherUserId = chatRoom.participants.firstWhere((id) => id != currentUser.uid);
    final otherUserName = chatRoom.participantNames[otherUserId] ?? 'Usuario';
    final otherUserAvatar = chatRoom.participantAvatars[otherUserId] ?? 'https://i.pravatar.cc/150?u=$otherUserId';

    final lastMessageTime = chatRoom.lastMessageTimestamp?.toDate();
    final timeAgo = lastMessageTime != null ? timeago.format(lastMessageTime, locale: 'es') : '';

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(otherUserAvatar),
      ),
      title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        chatRoom.lastMessage ?? '...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(timeAgo),
      onTap: () {
        // Navegamos a la pantalla de chat individual
        context.go('/chat/${chatRoom.id}', extra: otherUserName);
      },
    );
  }
}
