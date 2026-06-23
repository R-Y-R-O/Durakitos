import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../paywall/paywall_screen.dart';
import '../contacts/contacts_screen.dart';
import '../requests/requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _screens = const [_AgendaTab(), _SearchTab(), _RequestsTab(), _VaultTab(), _ProfileTab()];
  void _checkUserStatus() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    final isLocked = user.isLocked;
    final trialExpired = user.trialEndDate != null && DateTime.now().isAfter(user.trialEndDate!);
    final requestsExceeded = user.totalRequestsUsed >= 100;

    if (isLocked || trialExpired || requestsExceeded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUserStatus());
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Durakitos',
          style: GoogleFonts.inter(
            color: const Color(0xFF6200C5),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          if (user != null) _TrialStatusBadge(user: user),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7D2AE8),
        unselectedItemColor: const Color(0xFF4B4455),
        backgroundColor: Colors.white,
        elevation: 20,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.contacts_outlined), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.group_add_outlined), label: 'Solicitudes'),
          BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), label: 'Bóveda'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _TrialStatusBadge extends StatelessWidget {
  final UserModel user;
  const _TrialStatusBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    final daysLeft = user.trialEndDate != null
        ? user.trialEndDate!.difference(DateTime.now()).inDays
        : 0;
    final requestsLeft = (100 - user.totalRequestsUsed).clamp(0, 100);
    final isWarning = daysLeft <= 2 || requestsLeft <= 20;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWarning
              ? [const Color(0xFFB000A4), const Color(0xFF6200C5)]
              : [const Color(0xFF7D2AE8), const Color(0xFF00696E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '$requestsLeft / ${daysLeft}d',
            style: GoogleFonts.inter(
              fontSize: 11,              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// === AGENDA TAB ===
class _AgendaTab extends StatelessWidget {
  const _AgendaTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Aún no tienes contactos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Envía solicitudes desde Buscar', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// === SEARCH TAB ===
class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final requestsLeft = user != null ? (100 - user.totalRequestsUsed).clamp(0, 100) : 0;

    final mockUsers = [
      {'name': 'Elena Rodríguez', 'role': 'Cantante • Modelo', 'loc': 'Vedado, La Habana', 'vip': true},
      {'name': 'Marco Polo', 'role': 'Creador Digital', 'loc': 'Centro, Matanzas', 'vip': false},
      {'name': 'Sofía Hernández', 'role': 'Fotógrafa', 'loc': 'Santa Clara', 'vip': true},
      {'name': 'Alex Rivera', 'role': 'Moderador', 'loc': 'Santiago de Cuba', 'vip': false},
    ];

    return Column(
      children: [
        // Banner de estado
        Container(
          width: double.infinity,          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: requestsLeft > 20
                  ? [const Color(0xFF7D2AE8), const Color(0xFF00696E)]
                  : [const Color(0xFFB000A4), const Color(0xFF6200C5)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Te quedan $requestsLeft solicitudes gratuitas',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mockUsers.length,
            itemBuilder: (context, i) {
              final u = mockUsers[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF7D2AE8),
                    child: Text((u['name'] as String)[0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Row(
                    children: [
                      Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (u['vip'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFB000A4), borderRadius: BorderRadius.circular(8)),
                          child: const Text('VIP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('${u['role']} • ${u['loc']}'),
                  trailing: ElevatedButton.icon(
                    onPressed: requestsLeft > 0
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Solicitud enviada a ${u['name']}')),
                            )
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PaywallScreen()),
                            ),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Enlazar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: requestsLeft > 0 ? const Color(0xFF00696E) : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// === REQUESTS TAB ===
class _RequestsTab extends StatelessWidget {
  const _RequestsTab();
  @override
  Widget build(BuildContext context) {
    return Center(      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_add, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No hay solicitudes pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// === VAULT TAB ===
class _VaultTab extends StatelessWidget {
  const _VaultTab();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7D2AE8), Color(0xFF00696E)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('BALANCE ACTUAL', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.diamond, color: Colors.white, size: 36),
                    const SizedBox(width: 8),
                    Text('${user?.diamonds ?? 0}', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6200C5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    minimumSize: const Size(double.infinity, 48),
                  ),                  child: const Text('Recargar Diamantes', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text('Paquetes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _Pkg(amount: 100, price: '\$0.99'),
              _Pkg(amount: 500, price: '\$4.49', popular: true),
              _Pkg(amount: 1200, price: '\$9.99'),
              _Pkg(amount: 3000, price: '\$24.99', premium: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pkg extends StatelessWidget {
  final int amount;
  final String price;
  final bool popular;
  final bool premium;
  const _Pkg({required this.amount, required this.price, this.popular = false, this.premium = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: premium ? const Color(0xFF7D2AE8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: popular ? Border.all(color: const Color(0xFF00696E), width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.diamond, size: 40, color: premium ? Colors.white : const Color(0xFF6200C5)),
          const SizedBox(height: 8),
          Text('$amount', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: premium ? Colors.white : const Color(0xFF6200C5))),
          Text('DIAMANTES', style: TextStyle(fontSize: 10, color: premium ? Colors.white70 : Colors.grey)),          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: premium ? Colors.white : const Color(0xFFF1F3FB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF6200C5))),
          ),
        ],
      ),
    );
  }
}

// === PROFILE TAB ===
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7D2AE8), Color(0xFF00696E)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text((user?.displayName ?? 'U')[0], style: const TextStyle(fontSize: 36, color: Color(0xFF6200C5))),
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Usuario', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: Text((user?.role.name ?? 'user').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,                  children: [
                    _Stat(v: '${user?.diamonds ?? 0}', l: 'Diamantes'),
                    _Stat(v: '100', l: 'Contactos'),
                    _Stat(v: '24', l: 'Referidos'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuTile(icon: Icons.person_outline, title: 'Editar Perfil', color: const Color(0xFF6200C5)),
          _MenuTile(icon: Icons.account_balance_wallet_outlined, title: 'Mis Transacciones', color: const Color(0xFF00696E)),
          _MenuTile(icon: Icons.people_outline, title: 'Mi Red', color: const Color(0xFFB000A4)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await await Provider.of<UserProvider>(context, listen: false).clearUser();
              await AuthService().signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String v, l;
  const _Stat({required this.v, required this.l});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ]);
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _MenuTile({required this.icon, required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {},
        ),
      );
}
