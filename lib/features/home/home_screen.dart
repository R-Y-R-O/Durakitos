
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/home/widgets/search_tab.dart';
import 'package:myapp/features/home/widgets/requests_tab.dart';
import 'package:myapp/features/chat/conversations_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/models/user_model.dart'; // 1. Importar el UserModel para acceder al enum Role

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conecta'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              // 2. Comparar con el enum, no con un string.
              // Permitimos el acceso al panel a todos los roles de gestión.
              final userRole = userProvider.user?.role;
              if (userRole == Role.creator || userRole == Role.admin || userRole == Role.super_agent) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  tooltip: 'Panel de Gestión',
                  onPressed: () {
                    context.go('/admin');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Provider.of<UserProvider>(context, listen: false).clearUser();
              await _authService.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chats'),
            Tab(icon: Icon(Icons.search), text: 'Buscar'),
            Tab(icon: Icon(Icons.person_add_alt_1_outlined), text: 'Solicitudes'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                context.go('/contacts');
              },
              child: const Icon(Icons.contacts_outlined),
              tooltip: 'Ver Contactos',
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: const [
          ConversationsScreen(),
          SearchTab(),
          RequestsTab(),
        ],
      ),
    );
  }
}
