
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/user_model.dart';
import '../../../services/chat_service.dart'; // 1. Importamos ChatService
import '../../../theme/app_theme.dart';

class ContactCard extends StatelessWidget {
  final UserModel contact;

  const ContactCard({super.key, required this.contact});

  // 2. Creamos un método para manejar la navegación al chat
  void _goToChat(BuildContext context) async {
    final chatService = ChatService();
    try {
      final chatRoomId = await chatService.getOrCreateChatRoom(contact.uid);
      if (context.mounted) {
        context.go('/chat/$chatRoomId', extra: contact.displayName);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar el chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${contact.uid}'),
              backgroundColor: AppTheme.surfaceContainerLow,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName ?? 'Contacto',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${contact.municipality ?? ''}, ${contact.province ?? 'Ubicación no disponible'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // --- 3. ACTUALIZAMOS LOS BOTONES ---
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => _goToChat(context), // <- Llama al nuevo método
              tooltip: 'Enviar Mensaje',
              color: theme.colorScheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.person_pin_circle_outlined),
              onPressed: () {
                context.go('/profile/${contact.uid}');
              },
              tooltip: 'Ver Perfil',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
