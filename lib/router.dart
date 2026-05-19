
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart'; // 1. Importamos la futura pantalla
import 'services/auth_service.dart';
import 'services/user_service.dart'; // 2. Importamos el UserService

final AuthService _authService = AuthService();
final UserService _userService = UserService(); // 3. Creamos una instancia

final router = GoRouter(
  refreshListenable: GoRouterRefreshStream(_authService.authStateChanges),
  initialLocation: '/login',
  // 4. Hacemos el redirect asíncrono para poder consultar Firestore
  redirect: (BuildContext context, GoRouterState state) async {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final location = state.matchedLocation;

    if (!loggedIn) {
      return location == '/login' ? null : '/login';
    }

    // --- INICIO DE LA LÓGICA DE ONBOARDING ---
    final user = FirebaseAuth.instance.currentUser!;
    final userProfile = await _userService.getUserProfile(user.uid);

    final isProfileComplete = userProfile?.profileCompleted ?? false;

    // Si el perfil no está completo y el usuario no está intentando completarlo,
    // lo forzamos a ir a la pantalla de onboarding.
    if (!isProfileComplete && location != '/onboarding') {
      return '/onboarding';
    }

    // Si el perfil ya está completo y el usuario intenta acceder a onboarding,
    // lo llevamos a la pantalla de inicio.
    if (isProfileComplete && location == '/onboarding') {
      return '/home';
    }
    // --- FIN DE LA LÓGICA DE ONBOARDING ---

    if (loggedIn && location == '/login') {
      return '/home';
    }

    return null;
  },

  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    // 5. Añadimos la nueva ruta para la pantalla de onboarding
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
