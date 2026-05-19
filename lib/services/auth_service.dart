
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserModel() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }
    final DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      return null;
    }
  }

  // Iniciar sesión con Google usando signInWithPopup (ideal para web)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Crea un proveedor de Google
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // 2. Inicia sesión con una ventana emergente
      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);

      // 3. Guardar/Actualizar la información del usuario en Firestore
      await _saveUserToFirestore(userCredential.user);

      return userCredential;

    } catch (e) {
      // Manejo de errores (ej. si el usuario cierra la ventana emergente)
      print("Error durante el inicio de sesión con Google: $e");
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Método privado para guardar el usuario en Firestore
  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Usuario',
        profileImageUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
      );
      await userRef.set(newUser.toFirestore());
    }
  }
}
