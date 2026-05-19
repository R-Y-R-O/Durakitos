
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; 
import '../models/user_model.dart';

class UserService {
  final CollectionReference<UserModel> _usersRef = FirebaseFirestore.instance
      .collection('users')
      .withConverter<UserModel>(
        fromFirestore: (snapshots, _) => UserModel.fromFirestore(snapshots),
        toFirestore: (user, _) => user.toJson(),
      );

  Future<void> createUser(auth.User user) async {
    final newUser = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      profileCompleted: false,
    );
    return _usersRef.doc(user.uid).set(newUser);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(UserModel user) async {
    return _usersRef.doc(user.uid).set(user, SetOptions(merge: true));
  }

  Future<bool> userExists(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.exists;
  }

  Future<List<UserModel>> getUsers() async {
    final currentUserUid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) return []; 

    final querySnapshot = await _usersRef
        .where('uid', isNotEqualTo: currentUserUid)
        .get();
        
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // --- NUEVO MÉTODO PARA OBTENER LOS CONTACTOS DE UN USUARIO ---
  Future<List<UserModel>> getContacts() async {
    final currentUserUid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) return [];

    // 1. Obtenemos el perfil del usuario actual para acceder a su lista de contactos.
    final currentUserProfile = await getUserProfile(currentUserUid);
    final contactIds = currentUserProfile?.contacts;

    if (contactIds == null || contactIds.isEmpty) {
      return []; // Si no tiene contactos, devolvemos una lista vacía.
    }

    // 2. Por cada ID en la lista de contactos, obtenemos el perfil completo.
    // Firebase no permite consultas "IN" con más de 30 elementos en la web, así que lo hacemos con Futures individuales.
    final contactFutures = contactIds.map((id) => getUserProfile(id)).toList();

    // 3. Esperamos a que todas las consultas se completen.
    final contacts = await Future.wait(contactFutures);

    // 4. Devolvemos la lista de UserModels, filtrando posibles nulos si un perfil fue borrado.
    return contacts.where((user) => user != null).cast<UserModel>().toList();
  }
}
