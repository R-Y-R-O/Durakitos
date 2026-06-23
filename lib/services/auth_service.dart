import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:durakitos/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<UserModel?> getCurrentUserModel() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        developer.log('No authenticated user found', name: 'auth_service');
        return null;
      }

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (doc.exists) {
        developer.log('User model loaded successfully', name: 'auth_service');
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        developer.log('User document does not exist', name: 'auth_service', level: 900);
        return null;
      }
    } catch (e, stackTrace) {
      developer.log(        'Error loading user model',
        name: 'auth_service',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('Attempting Google Sign In', name: 'auth_service');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        developer.log('User cancelled Google Sign In', name: 'auth_service');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user?.email == null) {
        throw Exception('No se pudo obtener el email de Google');
      }

      await _saveUserToFirestore(userCredential.user);

      developer.log('Google Sign In successful', name: 'auth_service');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase error during Google Sign In: ${e.code}',
        name: 'auth_service',
        level: 900,
        error: e,
      );
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':          errorMessage = 'Esta cuenta existe con diferente método de login';
          break;
        case 'invalid-credential':
          errorMessage = 'Credenciales inválidas';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google Sign In está deshabilitado';
          break;
        default:
          errorMessage = 'Error de Google Sign In: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log(
        'Unexpected error during Google Sign In',
        name: 'auth_service',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      developer.log('User signed out successfully', name: 'auth_service');
    } catch (e) {
      developer.log(
        'Error signing out',
        name: 'auth_service',
        level: 900,
        error: e,
      );
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) {
      throw Exception('Usuario no válido');
    }

    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        // Calcular trialEndDate (7 días desde ahora)        final trialEndDate = DateTime.now().add(const Duration(days: 7));

        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Usuario',
          avatarUrl: user.photoURL ?? '',
          role: Role.user,
          diamonds: 0,
          totalRequestsUsed: 0,
          isLocked: false,
          trialEndDate: trialEndDate,
          createdAt: DateTime.now(),
        );
        await userRef.set(newUser.toFirestore());
        developer.log('New user created in Firestore: ${user.uid}', name: 'auth_service');
      } else {
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        developer.log('User last login updated: ${user.uid}', name: 'auth_service');
      }
    } catch (e) {
      developer.log(
        'Error saving user to Firestore',
        name: 'auth_service',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }
}
