
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/complete_profile_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/chat/chat_list_screen.dart'; // 1. Importar ChatListScreen
import '../features/chat/chat_screen.dart';       // 2. Importar ChatScreen
import '../services/user_service.dart';

class AppRouter {
  static final _userService = UserService();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      // --- 3. AÑADIMOS LAS RUTAS DE CHAT ---
      GoRoute(
        path: '/chats', // Ruta para la lista de chats
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatRoomId', // Ruta para un chat individual
        builder: (context, state) {
          final chatRoomId = state.pathParameters['chatRoomId']!;
          // Recuperamos el nombre del otro usuario del parámetro 'extra'
          final otherUserName = state.extra as String? ?? 'Chat';
          return ChatScreen(
            chatRoomId: chatRoomId,
            otherUserName: otherUserName,
          );
        },
      ),
    ],
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (isSplash) {
        // En lugar de ir siempre a /home, podríamos redirigir a /chats si es más lógico
        return '/home';
      }

      final userProfile = await _userService.getUserProfile(user.uid);
      if (userProfile != null && !userProfile.profileCompleted) {
        if (state.matchedLocation != '/complete-profile') {
          return '/complete-profile';
        }
      }

      if (loggingIn && userProfile != null && userProfile.profileCompleted) {
        return '/home';
      }

      return null;
    },
  );
}
