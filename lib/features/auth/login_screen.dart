
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart'; // Importamos el servicio de autenticación

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instancia de nuestro servicio de autenticación
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Estado para mostrar un indicador de carga

  // Método para manejar el inicio de sesión
  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final userCredential = await _authService.signInWithGoogle();

    // Si la pantalla sigue montada, quitamos el indicador de carga
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (userCredential == null) {
      // Opcional: Mostrar un mensaje de error si el inicio de sesión falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión cancelado o fallido.')),
      );
    }
    // No necesitamos navegar manualmente. El redirect de GoRouter lo hará por nosotros.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Conecta',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu mundo, más cerca.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 60),

                // Si está cargando, mostramos un CircularProgressIndicator,
                // si no, mostramos el botón.
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                        label: const Text('Continuar con Google'),
                        onPressed: _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFDB4437),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                           textStyle: theme.textTheme.labelLarge,
                        ),
                      ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
                  label: const Text('Continuar con Facebook'),
                  onPressed: () {
                    // Lógica futura
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF3b5998),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                     textStyle: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                  label: const Text('Continuar con Instagram'),
                  onPressed: () {
                    // Lógica futura
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFC13584),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                     textStyle: theme.textTheme.labelLarge,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
