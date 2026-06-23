
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durakitos/models/user_model.dart';
import 'package:durakitos/services/friendship_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  final FriendshipService _friendshipService = FriendshipService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _friendshipService.getFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tienes solicitudes de amistad.'));
        }

        final requests = snapshot.data!;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final user = requests[index];
            return ListTile(
              leading: CircleAvatar(child: Text(user.displayName.substring(0, 1))),
              title: Text(user.displayName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _friendshipService.acceptFriendRequest(user.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _friendshipService.declineFriendRequest(user.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
