import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    
    final isLoggedIn = await _authService.isUserLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      await Provider.of<UserProvider>(context, listen: false).loadUser();
      if (mounted) {
        GoRouter.of(context).go('/home');
      }    } else {
      if (mounted) {
        GoRouter.of(context).go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6200C5),
              Color(0xFF7D2AE8),
              Color(0xFFB000A4),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.diamond,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Durakitos',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                ),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
