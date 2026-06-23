
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:durakitos/models/user_model.dart';
import 'package:durakitos/services/friendship_service.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final bool isContact; // Nuevo parámetro

  const UserCard({super.key, required this.user, this.isContact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isContact
          ? () {
              // Navegar a la pantalla de chat si es un contacto
              context.goNamed('chat', pathParameters: {'userId': user.id}, extra: user.displayName);
            }
          : null, // No hacer nada al tocar si no es un contacto
      child: Card(
        margin: EdgeInsets.zero, // El padding se gestiona fuera
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${user.id}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? 'Usuario sin nombre', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(user.email ?? 'Sin email', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Mostrar el botón de Añadir solo si NO es un contacto
              if (!isContact) _AddFriendButton(user: user),
            ],
          ),
        ),
      ),
    );
  }
}

// El botón se extrae a un widget con estado para gestionar su lógica interna
class _AddFriendButton extends StatefulWidget {
  final UserModel user;
  const _AddFriendButton({required this.user});

  @override
  State<_AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends State<_AddFriendButton> {
  final FriendshipService _friendshipService = FriendshipService();
  bool _requestSent = false;

  void _sendRequest() async {
    setState(() { _requestSent = true; });
    try {
      await _friendshipService.sendFriendRequest(toUserId: widget.user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada a ${widget.user.displayName}'), backgroundColor: Theme.of(context).colorScheme.tertiary),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la solicitud: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      setState(() { _requestSent = false; }); // Permitir reintentar si falla
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _requestSent ? null : _sendRequest,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        backgroundColor: _requestSent ? Colors.grey : Theme.of(context).colorScheme.secondary,
      ),
      child: _requestSent ? const Icon(Icons.check, color: Colors.white) : const Icon(Icons.person_add, color: Colors.white),
    );
  }
}
