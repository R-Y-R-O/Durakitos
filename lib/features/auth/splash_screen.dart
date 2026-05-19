
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // 1. Importar Provider
import 'package:conecta/services/auth_service.dart';
import 'package:conecta/providers/user_provider.dart'; // 2. Importar UserProvider

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Pequeña demora para que la splash screen sea visible
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await _authService.isUserLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // 3. Si está logueado, CARGAR los datos del usuario
      await Provider.of<UserProvider>(context, listen: false).loadUser();

      if (mounted) {
        // Una vez cargados, ir a la home screen
        GoRouter.of(context).go('/home');
      }
    } else {
      // 4. Si no, ir a la pantalla de login
      GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
