import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../contacts/contacts_screen.dart';
import '../requests/requests_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = const [
    ContactsScreen(),
    _SearchScreen(),
    RequestsScreen(),
    _VaultScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A0B2E).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.contacts_outlined,
                  label: 'Agenda',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavBarItem(
                  icon: Icons.search,
                  label: 'Buscar',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavBarItem(
                  icon: Icons.group_add_outlined,
                  label: 'Solicitudes',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                  badge: 3,
                ),
                _NavBarItem(
                  icon: Icons.diamond_outlined,
                  label: 'Bóveda',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavBarItem(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7D2AE8) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : const Color(0xFF4B4455),
                    size: 24,
                  ),
                  if (badge != null && badge! > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB000A4),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$badge',
                          style: GoogleFonts.inter(                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isSelected ? Colors.white : const Color(0xFF4B4455),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// PANTALLA DE BÚSQUEDA
// ============================================
class _SearchScreen extends StatefulWidget {
  const _SearchScreen();

  @override
  State<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<_SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Buscar Contactos',
          style: GoogleFonts.inter(
            color: const Color(0xFF6200C5),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A0B2E).withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7C7387)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(label: 'Todos', isSelected: true),                const SizedBox(width: 8),
                _FilterChip(label: 'Cantantes'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Modelos'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Creadores'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Fotógrafos'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Resultados
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _UserCard(
                  name: 'Elena Rodriguez',
                  role: 'Cantante • Modelo',
                  location: 'Vedado, La Habana',
                  isVip: true,
                ),
                _UserCard(
                  name: 'Marco Polo',
                  role: 'Creador Digital',
                  location: 'Centro, Matanzas',
                ),
                _UserCard(
                  name: 'Sofia Hernandez',
                  role: 'Fotógrafa • Disertante',
                  location: 'Santa Clara, V. Clara',
                  isVip: true,
                ),
                _UserCard(
                  name: 'Alex Rivera',
                  role: 'Moderador',
                  location: 'Santiago, S. de Cuba',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF7D2AE8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF7D2AE8).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF1A0B2E).withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : const Color(0xFF4B4455),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String role;
  final String location;
  final bool isVip;

  const _UserCard({
    required this.name,
    required this.role,
    required this.location,
    this.isVip = false,  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A0B2E).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(
                  'https://i.pravatar.cc/400?u=${name.hashCode}',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: isVip
                ? Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB000A4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VIP',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF181C21),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF4B4455),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF4B4455),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),                Wrap(
                  spacing: 6,
                  children: role.split(' • ').map((r) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5FF4FC).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        r.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF006E72),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add, size: 18),
                    label: Text(
                      'Enviar Solicitud',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00696E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],      ),
    );
  }
}

// ============================================
// PANTALLA DE BÓVEDA / TIENDA
// ============================================
class _VaultScreen extends StatelessWidget {
  const _VaultScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bóveda de Diamantes',
          style: GoogleFonts.inter(
            color: const Color(0xFF6200C5),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tu Balance',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF4B4455),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond,
                      color: Color(0xFF00696E),
                      size: 18,
                    ),
                    const SizedBox(width: 4),                    Text(
                      '2,450',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF181C21),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A0B2E).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BALANCE ACTUAL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4B4455),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [                      Text(
                        '2,450',
                        style: GoogleFonts.inter(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6200C5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.diamond,
                        color: Color(0xFF6200C5),
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200C5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF6200C5).withOpacity(0.4),
                      ),
                      child: Text(
                        'Recargar Diamantes',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Bonus
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(                gradient: const LinearGradient(
                  colors: [Color(0xFFB000A4), Color(0xFF6200C5)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB000A4).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BONUS DIARIO',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¡Reclama tus diamantes gratis!',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.diamond, color: Colors.white, size: 28),
                        const SizedBox(height: 4),                        Text(
                          '5',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Packages
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Paquetes de Diamantes',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF181C21),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: const [
                _DiamondPackage(
                  amount: 100,
                  price: '\$0.99',
                  icon: Icons.diamond_outlined,
                ),
                _DiamondPackage(
                  amount: 500,
                  price: '\$4.49',
                  icon: Icons.shopping_bag,
                  isPopular: true,
                ),
                _DiamondPackage(
                  amount: 1200,                  price: '\$9.99',
                  icon: Icons.inventory_2,
                ),
                _DiamondPackage(
                  amount: 3000,
                  price: '\$24.99',
                  icon: Icons.account_balance,
                  isPremium: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondPackage extends StatelessWidget {
  final int amount;
  final String price;
  final IconData icon;
  final bool isPopular;
  final bool isPremium;

  const _DiamondPackage({
    required this.amount,
    required this.price,
    required this.icon,
    this.isPopular = false,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7D2AE8), Color(0xFF6200C5)],
              )
            : null,
        color: isPremium ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: const Color(0xFF00696E), width: 2)
            : null,
        boxShadow: [          BoxShadow(
            color: const Color(0xFF1A0B2E).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00696E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'MÁS VENDIDO',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isPremium
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF5FF4FC).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),                  child: Icon(
                    icon,
                    size: 36,
                    color: isPremium ? Colors.white : const Color(0xFF00696E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  amount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isPremium ? Colors.white : const Color(0xFF6200C5),
                  ),
                ),
                Text(
                  'DIAMANTES',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isPremium
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF4B4455),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? Colors.white
                        : const Color(0xFFF1F3FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isPremium
                            ? const Color(0xFF6200C5)
                            : const Color(0xFF6200C5),
                      ),
                    ),
                  ),
                ),
              ],            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PANTALLA DE PERFIL (wrapper)
// ============================================
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.inter(
            color: const Color(0xFF6200C5),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6200C5)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(                  colors: [Color(0xFF7D2AE8), Color(0xFF00696E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundImage: NetworkImage(
                            user?.avatarUrl ??
                                'https://i.pravatar.cc/150?u=${user?.id ?? "default"}',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Usuario',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MIEMBRO ${user?.role.name.toUpperCase() ?? "USER"}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        value: '${user?.diamonds ?? 0}',
                        label: 'Diamantes',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _StatItem(
                        value: '100',
                        label: 'Contactos',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _StatItem(
                        value: '24',
                        label: 'Referidos',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu Items            _MenuItem(
              icon: Icons.person_outline,
              title: 'Editar Perfil',
              color: const Color(0xFF6200C5),
            ),
            _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Mis Transacciones',
              color: const Color(0xFF00696E),
            ),
            _MenuItem(
              icon: Icons.people_outline,
              title: 'Mi Red',
              color: const Color(0xFFB000A4),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              color: const Color(0xFF7D2AE8),
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Ayuda y Soporte',
              color: const Color(0xFF4B4455),
            ),
            const SizedBox(height: 12),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await Provider.of<UserProvider>(context, listen: false)
                      .clearUser();
                  await AuthService().signOut();
                },
                icon: const Icon(Icons.logout, color: Color(0xFFBA1A1A)),
                label: Text(
                  'Cerrar Sesión',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFBA1A1A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A0B2E).withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF181C21),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF7C7387),
        ),
        onTap: () {},
      ),
    );
  }
}
