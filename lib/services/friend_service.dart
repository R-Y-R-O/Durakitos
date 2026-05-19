
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_request_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de solicitudes de amistad
  late final CollectionReference<FriendRequest> _requestsRef;

  FriendService() {
    _requestsRef = _firestore.collection('friend_requests').withConverter<FriendRequest>(
          fromFirestore: (snapshots, _) => FriendRequest.fromFirestore(snapshots),
          toFirestore: (request, _) => request.toJson(),
        );
  }

  // 1. ENVIAR UNA SOLICITUD DE AMISTAD
  Future<void> sendFriendRequest(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw ('No authenticated user');

    final request = FriendRequest(
      id: '', // Firestore lo generará
      senderId: currentUser.uid,
      receiverId: receiverId,
      status: RequestStatus.pending,
      createdAt: Timestamp.now(),
      senderName: currentUser.displayName,
      // Podríamos obtener el avatar del perfil de usuario, por ahora lo dejamos null
      senderAvatar: null, 
    );

    await _requestsRef.add(request);
  }

  // 2. OBTENER SOLICITUDES PENDIENTES PARA EL USUARIO ACTUAL
  Stream<List<FriendRequest>> getPendingRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _requestsRef
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: RequestStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 3. ACEPTAR UNA SOLICITUD DE AMISTAD
  Future<void> acceptFriendRequest(String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw ('No authenticated user');

    final requestDoc = _requestsRef.doc(requestId);
    final request = (await requestDoc.get()).data();

    if (request == null) throw ('Request not found');
    if (request.receiverId != currentUser.uid) throw ('Unauthorized action');

    final senderId = request.senderId;
    final receiverId = request.receiverId;

    // Usamos una transacción para asegurar que todas las operaciones se completen con éxito o ninguna lo haga.
    await _firestore.runTransaction((transaction) async {
      // Actualizamos el estado de la solicitud
      transaction.update(requestDoc, {'status': RequestStatus.accepted.toString().split('.').last});

      // Añadimos al remitente a la lista de contactos del receptor
      final receiverDocRef = _firestore.collection('users').doc(receiverId);
      transaction.update(receiverDocRef, {
        'contacts': FieldValue.arrayUnion([senderId])
      });

      // Añadimos al receptor a la lista de contactos del remitente
      final senderDocRef = _firestore.collection('users').doc(senderId);
      transaction.update(senderDocRef, {
        'contacts': FieldValue.arrayUnion([receiverId])
      });
    });
  }

  // 4. RECHAZAR UNA SOLICITUD DE AMISTAD
  Future<void> declineFriendRequest(String requestId) async {
     final currentUser = _auth.currentUser;
    if (currentUser == null) throw ('No authenticated user');

    final requestDoc = _requestsRef.doc(requestId);
     final request = (await requestDoc.get()).data();

    if (request == null) throw ('Request not found');
    if (request.receiverId != currentUser.uid) throw ('Unauthorized action');


    await requestDoc.update({'status': RequestStatus.declined.toString().split('.').last});
  }
}
