import 'package:flutter/material.dart';import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/admin/admin_screen.dart';
import '../features/admin/reports_screen.dart';
import '../features/onboarding/onboarding_screen.dart';

class AppRouter {
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
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
        routes: [
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (isSplash || loggingIn) {        return '/home';
      }

      return null;
    },
  );
}
