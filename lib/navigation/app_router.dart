
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/login_screen.dart';
import 'package:myapp/features/home/home_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/features/chat/chat_screen.dart';
import 'package:myapp/features/contacts/contacts_screen.dart';
import 'package:myapp/features/admin/admin_screen.dart';
import 'package:myapp/features/admin/reports_screen.dart'; // 1. Importar la pantalla de reportes

class AppRouter {
  final AuthService _authService = AuthService();

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/chat/:userId',
        name: 'chat',
        builder: (BuildContext context, GoRouterState state) {
          final userId = state.pathParameters['userId']!;
          final userName = state.extra as String? ?? 'Chat';
          return ChatScreen(receiverId: userId, receiverName: userName);
        },
      ),
      GoRoute(
        path: '/contacts',
        name: 'contacts',
        builder: (BuildContext context, GoRouterState state) => const ContactsScreen(),
      ),
      // 2. Anidar la ruta de reportes dentro de admin
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (BuildContext context, GoRouterState state) => const AdminScreen(),
        routes: <GoRoute>[
          GoRoute(
            path: 'reports', // El path es relativo a /admin
            name: 'reports',
            builder: (BuildContext context, GoRouterState state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final bool loggedIn = await _authService.isUserLoggedIn();
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
  );
}
