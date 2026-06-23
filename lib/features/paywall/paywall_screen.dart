import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isTrialExpired = user?.trialEndDate != null &&
        DateTime.now().isAfter(user!.trialEndDate!);
    final requestsUsed = user?.totalRequestsUsed ?? 0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0B2E), Color(0xFF6200C5), Color(0xFFB000A4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de bloqueo animado
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),                    child: const Icon(
                      Icons.lock_clock,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  Text(
                    isTrialExpired ? 'Período de Prueba Finalizado' : 'Límite Alcanzado',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Mensaje descriptivo
                  Text(
                    isTrialExpired
                        ? 'Tus 7 días de prueba han expirado. Adquiere diamantes para continuar conectando.'
                        : 'Has usado las $requestsUsed/100 solicitudes gratuitas. Recarga diamantes para seguir.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Card de estadísticas
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),                    child: Column(
                      children: [
                        Row(
                          children: [
                            _StatBox(
                              icon: Icons.person_add,
                              value: '$requestsUsed',
                              label: 'Solicitudes',
                              color: const Color(0xFF6200C5),
                            ),
                            const SizedBox(width: 12),
                            _StatBox(
                              icon: Icons.diamond,
                              value: '${user?.diamonds ?? 0}',
                              label: 'Diamantes',
                              color: const Color(0xFF00696E),
                            ),
                            const SizedBox(width: 12),
                            _StatBox(
                              icon: Icons.calendar_today,
                              value: isTrialExpired ? '0' : '${user?.trialEndDate?.difference(DateTime.now()).inDays ?? 0}',
                              label: 'Días',
                              color: const Color(0xFFB000A4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          '¿Cómo obtener diamantes?',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF181C21),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.person,
                          text: 'Contacta a tu Padrino/Moderador',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.card_giftcard,
                          text: 'Reclama tu bonus diario (5 💎)',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.group_add,                          text: 'Invita amigos (20 💎 por referido)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00696E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 10,
                        shadowColor: const Color(0xFF00696E).withOpacity(0.5),
                      ),
                      child: Text(
                        'Entendido',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF4B4455),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF6200C5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6200C5)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF181C21),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
