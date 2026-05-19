
import 'package:flutter/material.dart';
import '../../../models/friend_request_model.dart';
import '../../../services/friend_service.dart';
import '../../../theme/app_theme.dart';

class RequestCard extends StatefulWidget {
  final FriendRequest request;

  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final FriendService _friendService = FriendService();
  bool _isLoading = false;

  Future<void> _handleRequest(bool accept) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (accept) {
        await _friendService.acceptFriendRequest(widget.request.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ahora eres amigo de ${widget.request.senderName ?? "..."}')),
        );
      } else {
        await _friendService.declineFriendRequest(widget.request.id);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud rechazada.')),
        );
      }
      // Como el stream se actualiza solo, el widget desaparecerá automáticamente
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar la solicitud: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
    // No hacemos setState(isLoading=false) al final porque el widget se eliminará del árbol
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppTheme.surfaceContainerLow, // Un color ligeramente distinto para destacarlas
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  // Usamos el avatar del remitente si está disponible, si no, un placeholder
                  backgroundImage: (widget.request.senderAvatar != null)
                      ? NetworkImage(widget.request.senderAvatar!)
                      : NetworkImage('https://i.pravatar.cc/150?u=${widget.request.senderId}') as ImageProvider,
                  backgroundColor: AppTheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.senderName ?? 'Usuario Desconocido',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Quiere conectar contigo',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- BOTONES DE ACCIÓN ---
            _isLoading
                ? const LinearProgressIndicator()
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleRequest(true),
                           style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.tertiary.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Aceptar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleRequest(false),
                           style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.outline),
                            foregroundColor: AppTheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Ignorar'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
