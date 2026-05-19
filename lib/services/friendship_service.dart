
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/user_model.dart'; 
import 'package:myapp/models/friend_request_model.dart';

class FriendshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final CollectionReference _requestsRef = _firestore.collection('friend_requests');
  late final CollectionReference<UserModel> _usersRef = _firestore.collection('users').withConverter<UserModel>(
        fromFirestore: (snapshots, _) => UserModel.fromFirestore(snapshots.data()!, snapshots.id),
        toFirestore: (user, _) => user.toFirestore(),
      );

  Future<void> sendFriendRequest({required String toUserId}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw ('No hay usuario autenticado.');
    if (currentUser.uid == toUserId) return;

    final fromUserId = currentUser.uid;
    final docId = fromUserId.compareTo(toUserId) < 0 ? '$fromUserId-$toUserId' : '$toUserId-$fromUserId';
    final requestDoc = _requestsRef.doc(docId);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(requestDoc);
      if (docSnapshot.exists) return;

      transaction.set(requestDoc, {
        'from': fromUserId,
        'to': toUserId,
        'status': FriendRequestStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
  Stream<List<UserModel>> getFriendRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _requestsRef
        .where('to', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];
          
          final fromUserIds = snapshot.docs.map((doc) => doc['from'] as String).toList();
          
          final usersSnapshot = await _usersRef.where(FieldPath.documentId, whereIn: fromUserIds).get();

          return usersSnapshot.docs.map((doc) => doc.data()).toList();
        });
  }


  Future<void> acceptFriendRequest(String fromUserId) async {
    final toUserId = _auth.currentUser!.uid;
    final docId = fromUserId.compareTo(toUserId) < 0 ? '$fromUserId-$toUserId' : '$toUserId-$fromUserId';
    final requestDocRef = _requestsRef.doc(docId);


    await _firestore.runTransaction((transaction) async {
      final requestSnapshot = await transaction.get(requestDocRef);
      if (!requestSnapshot.exists) throw Exception("La solicitud no existe.");

      final fromUserRef = _usersRef.doc(fromUserId).collection('contacts').doc(toUserId);
      final toUserRef = _usersRef.doc(toUserId).collection('contacts').doc(fromUserId);

      transaction.update(requestDocRef, {
        'status': FriendRequestStatus.accepted.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(fromUserRef, {'addedAt': FieldValue.serverTimestamp()});
      transaction.set(toUserRef, {'addedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> declineFriendRequest(String fromUserId) async {
     final toUserId = _auth.currentUser!.uid;
    final docId = fromUserId.compareTo(toUserId) < 0 ? '$fromUserId-$toUserId' : '$toUserId-$fromUserId';
    final requestDocRef = _requestsRef.doc(docId);

    await requestDocRef.update({
      'status': FriendRequestStatus.declined.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<UserModel>> getContacts() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _usersRef.doc(currentUser.uid).collection('contacts').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final contactUids = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await _usersRef.where(FieldPath.documentId, whereIn: contactUids).get();
      return userDocs.docs.map((doc) => doc.data()).toList();
    });
  }
}
