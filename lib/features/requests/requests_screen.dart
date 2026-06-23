
import 'package:flutter/material.dart';
import 'package:durakitos/services/friendship_service.dart';
import 'package:durakitos/services/user_service.dart';
import 'package:durakitos/models/user_model.dart';
import 'widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final FriendshipService _friendshipService = FriendshipService();
  final UserService _userService = UserService();

  // Un mapa para guardar en caché los perfiles de usuario que ya hemos cargado
  final Map<String, UserModel> _userCache = {};

  // Función para obtener el perfil de un usuario (desde caché o desde Firestore)
  Future<UserModel?> _getUserProfile(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }
    final userProfile = await _userService.getUserProfile(uid);
    if (userProfile != null) {
      _userCache[uid] = userProfile;
    }
    return userProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Amistad'),
      ),
      body: StreamBuilder<List<FriendRequest>>(
        stream: _friendshipService.getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final requests = snapshot.data;

          if (requests == null || requests.isEmpty) {
            return const Center(
              child: Text(
                'No tienes solicitudes pendientes.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Usamos un ListView para mostrar cada solicitud
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              // Para cada solicitud, necesitamos obtener los detalles del remitente
              return FutureBuilder<UserModel?>(
                future: _getUserProfile(request.from), // Obtenemos el perfil del remitente
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    // Muestra un placeholder mientras se carga el perfil del usuario
                    return const ListTile(title: Text('Cargando...'));
                  }
                  final sender = userSnapshot.data!;
                  // Usamos un widget reutilizable para mostrar la solicitud
                  return RequestCard(
                    request: request,
                    sender: sender,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
