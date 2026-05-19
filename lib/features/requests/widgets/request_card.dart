
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/friendship_service.dart';
import '../../../theme/app_theme.dart';

class RequestCard extends StatefulWidget {
  final FriendRequest request;
  final UserModel sender;

  const RequestCard({super.key, required this.request, required this.sender});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final FriendshipService _friendshipService = FriendshipService();
  bool _isProcessing = false; // Para mostrar un indicador de carga
  bool _actionTaken = false; // Para ocultar la tarjeta después de una acción

  Future<void> _acceptRequest() async {
    setState(() { _isProcessing = true; });
    try {
      await _friendshipService.acceptFriendRequest(widget.request.id);
      setState(() { _actionTaken = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ahora eres amigo de ${widget.sender.displayName}'), backgroundColor: AppTheme.tertiary),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  Future<void> _declineRequest() async {
    setState(() { _isProcessing = true; });
    try {
      await _friendshipService.declineFriendRequest(widget.request.id);
      setState(() { _actionTaken = true; });
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ignorar: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si ya se tomó una acción, mostramos un widget vacío para "ocultar" la tarjeta
    if (_actionTaken) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 25, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.sender.uid}')),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.sender.displayName ?? 'Usuario', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Quiere conectar contigo', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mostramos los botones o un indicador de carga
            _isProcessing
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: CircularProgressIndicator(),
              )
            : Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptRequest,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary.withOpacity(0.8), foregroundColor: Colors.white),
                      child: const Text('Aceptar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _declineRequest,
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.outline)),
                      child: const Text('Ignorar'),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
