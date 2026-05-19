
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:myapp/firebase_options.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/app_theme.dart'; // Importando el nuevo archivo de temas
import 'package:myapp/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aquí, en lugar de solo UserProvider, podrías tener más proveedores
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Podrías añadir más proveedores aquí en el futuro
        // ChangeNotifierProvider(create: (_) => OtroProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // El Consumer escuchará los cambios en ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Conecta',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme, // Usando el tema claro del nuevo archivo
          darkTheme: AppTheme.darkTheme, // Usando el tema oscuro del nuevo archivo
          themeMode: themeProvider.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
