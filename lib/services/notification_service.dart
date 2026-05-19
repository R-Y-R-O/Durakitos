
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initNotifications() async {
    // Solicitar permisos
    await _requestPermissions();

    // Obtener el token del dispositivo
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    // Listener para cuando el token se refresca
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // Listener para mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Aquí podrías mostrar una notificación local (snackbar, dialog, etc.)
      print('¡Mensaje recibido en primer plano!');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
    });
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones concedido.');
    } else {
      print('Permiso de notificaciones denegado.');
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final tokensRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('tokens')
        .doc(token);

    await tokensRef.set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': 'android', // O el que corresponda
    });
  }
}
