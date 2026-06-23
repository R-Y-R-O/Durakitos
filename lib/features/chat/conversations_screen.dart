
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:durakitos/models/conversation_model.dart';
import 'package:durakitos/services/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Conversation>>(
        stream: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final conversations = snapshot.data;
          if (conversations == null || conversations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No tienes conversaciones activas.\n¡Busca a un amigo y envíale un mensaje!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _ConversationTile(conversation: conversation);
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${conversation.otherUser.id}'),
      ),
      title: Text(
        conversation.otherUser.displayName ?? 'Usuario',
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Text(
        timeago.format(conversation.lastMessageTimestamp, locale: 'es'),
        style: theme.textTheme.bodySmall,
      ),
      onTap: () {
        context.goNamed(
          'chat',
          pathParameters: {'userId': conversation.otherUser.id},
          extra: conversation.otherUser.displayName,
        );
      },
    );
  }
}
