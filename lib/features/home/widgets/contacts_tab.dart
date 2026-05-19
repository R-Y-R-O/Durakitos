
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'contact_card.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _userService.getContacts();
  }

  // Método para recargar los contactos
  Future<void> _refreshContacts() async {
    setState(() {
      _contactsFuture = _userService.getContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshContacts,
      child: FutureBuilder<List<UserModel>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          // --- ESTADO DE CARGA ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- ESTADO DE ERROR ---
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar tus contactos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // --- ESTADO SIN DATOS ---
          final contacts = snapshot.data;
          if (contacts == null || contacts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aún no tienes contactos.\n¡Envía solicitudes desde la pestaña "Buscar"!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          // --- ESTADO CON DATOS ---
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ContactCard(contact: contact),
              );
            },
          );
        },
      ),
    );
  }
}
