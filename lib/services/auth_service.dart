import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtiene el modelo del usuario actual desde Firestore
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
      developer.log(
        'Error loading user model',
        name: 'auth_service',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Valida un email con expresión regular
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida la contraseña (mínimo 8 caracteres, al menos una mayúscula, un número)
  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  /// Inicia sesión con email y contraseña
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validaciones
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('El email y la contraseña no pueden estar vacíos');
      }

      if (!_isValidEmail(email)) {
        throw Exception('El formato del email es inválido');
      }

      developer.log('Attempting sign in with email: $email', name: 'auth_service');

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      developer.log('Sign in successful', name: 'auth_service');
      return userCredential;

    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase auth error: ${e.code}',
        name: 'auth_service',
        level: 900,
        error: e,
      );
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No existe usuario con este email';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'user-disabled':
          errorMessage = 'Este usuario ha sido deshabilitado';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos fallidos. Intenta más tarde';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido';
          break;
        default:
          errorMessage = 'Error de autenticación: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log(
        'Unexpected error during sign in',
        name: 'auth_service',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validaciones
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('Todos los campos son requeridos');
      }

      if (!_isValidEmail(email)) {
        throw Exception('El formato del email es inválido');
      }

      if (!_isValidPassword(password)) {
        throw Exception(
          'La contraseña debe tener mínimo 8 caracteres, una mayúscula y un número',
        );
      }

      if (name.trim().length < 2) {
        throw Exception('El nombre debe tener al menos 2 caracteres');
      }

      developer.log('Attempting registration with email: $email', name: 'auth_service');

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Actualizar perfil del usuario
      await userCredential.user?.updateDisplayName(name.trim());

      // Guardar usuario en Firestore
      await _saveUserToFirestore(userCredential.user);

      developer.log('Registration successful', name: 'auth_service');
      return userCredential;

    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase auth error during signup: ${e.code}',
        name: 'auth_service',
        level: 900,
        error: e,
      );
      
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este email ya está registrado';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido';
          break;
        case 'operation-not-allowed':
          errorMessage = 'El registro está deshabilitado';
          break;
        default:
          errorMessage = 'Error de registro: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      developer.log(
        'Unexpected error during signup',
        name: 'auth_service',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }

  /// Inicia sesión con Google (con validación de token)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('Attempting Google Sign In', name: 'auth_service');

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // Solicitar permisos específicos
      googleProvider.addScopes(['email', 'profile']);

      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);

      // Validar que el usuario tenga email
      if (userCredential.user?.email == null) {
        throw Exception('No se pudo obtener el email de Google');
      }

      // Guardar usuario en Firestore
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
        case 'account-exists-with-different-credential':
          errorMessage = 'Esta cuenta existe con diferente método de login';
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

  /// Cierra sesión
  Future<void> signOut() async {
    try {
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

  /// Envía email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('Email inválido');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      developer.log('Password reset email sent to: $email', name: 'auth_service');
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Error sending password reset email: ${e.code}',
        name: 'auth_service',
        level: 900,
        error: e,
      );
      throw Exception('Error: ${e.message}');
    } catch (e) {
      developer.log(
        'Unexpected error sending password reset email',
        name: 'auth_service',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }

  /// Guarda o actualiza el usuario en Firestore de forma segura
  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) {
      throw Exception('Usuario no válido');
    }

    try {
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
        
        await userRef.set(
          newUser.toFirestore(),
          SetOptions(merge: true),
        );
        
        developer.log('New user created in Firestore: ${user.uid}', name: 'auth_service');
      } else {
        // Actualizar solo los campos necesarios
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
