
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/friend_request_model.dart';
import '../../../services/friend_service.dart';
import 'request_card.dart'; // El widget para cada tarjeta de solicitud

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Provider para que el servicio esté disponible en el árbol de widgets.
    // Esto es más eficiente que instanciarlo directamente aquí.
    return StreamProvider<List<FriendRequest>>.value(
      value: FriendService().getPendingRequests(),
      initialData: const [],
      child: Consumer<List<FriendRequest>>(
        builder: (context, requests, child) {
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No tienes solicitudes de amistad pendientes.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                // Cada solicitud se renderiza con su propia tarjeta
                child: RequestCard(request: request),
              );
            },
          );
        },
      ),
    );
  }
}
