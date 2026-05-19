
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService(); // 1. Instanciamos el ChatService
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile(widget.userId);
  }
  
  // 2. Método para navegar al chat
  void _goToChat(BuildContext context, UserModel user) async {
    try {
      final chatRoomId = await _chatService.getOrCreateChatRoom(user.uid);
      if (context.mounted) {
        context.go('/chat/$chatRoomId', extra: user.displayName);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar el chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: Text('No se pudo cargar el perfil.')));
        }

        final user = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(context, title: 'Acerca de mí', content: user.bio),
                      _buildInfoSection(context, title: 'Profesión', content: user.profession),
                      _buildInfoSection(context, title: 'Sector', content: user.sector),
                      _buildInfoSection(context, title: 'Estudios', content: user.studies),
                      _buildChipList(context, title: 'Habilidades', chips: user.skills),
                      _buildChipList(context, title: 'Intereses', chips: user.interests),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceContainer,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(user.displayName ?? '', style: const TextStyle(color: Colors.white, fontSize: 16.0, shadows: [Shadow(blurRadius: 2)])),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              user.coverImageUrl ?? 'https://picsum.photos/seed/${user.uid}/800/600',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                 height: 50,
                 decoration: const BoxDecoration(
                   color: AppTheme.surface, // Color de fondo para la sección de botones
                 ),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Mensaje'),
                      onPressed: () => _goToChat(context, user), // 3. Conectamos el botón
                    ),
                    ElevatedButton.icon(
                       icon: const Icon(Icons.person_add_alt_1_outlined),
                       label: const Text('Contactar'),
                       onPressed: () { /* Lógica futura */ },
                    )
                  ],
                 ), 
              ),
            ),
            Positioned(
              top: -50, // La mitad del tamaño del avatar para que sobresalga
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage(user.avatarUrl ?? 'https://i.pravatar.cc/150?u=${user.uid}'),
                ),
              ),
            ), 
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required String title, String? content}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildChipList(BuildContext context, {required String title, List<String>? chips}) {
    if (chips == null || chips.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: chips.map((chip) => Chip(label: Text(chip))).toList(),
          ),
        ],
      ),
    );
  }
}
