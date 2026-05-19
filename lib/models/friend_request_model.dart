
import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendRequestStatus {
  pending,
  accepted,
  declined,
  cancelled,
}

class FriendRequest {
  final String id;
  final String from;
  final String to;
  final FriendRequestStatus status;
  final DateTime createdAt;

  FriendRequest({required this.id, required this.from, required this.to, required this.status, required this.createdAt});

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      status: FriendRequestStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => FriendRequestStatus.pending),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
