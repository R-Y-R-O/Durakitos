
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<UserModel>> _subordinatesFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  static const int _registrationCost = 100;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.user?.id;
    if (currentUserId != null) {
      setState(() {
        _subordinatesFuture = _fetchSubordinates(currentUserId);
      });
    } else {
      // Handle case where user is null, maybe set future to an empty list
      setState(() {
         _subordinatesFuture = Future.value([]);
      });
    }
  }

  Future<List<UserModel>> _fetchSubordinates(String currentUserId) async {
    final querySnapshot = await _firestore.collection('users').where('sponsorId', isEqualTo: currentUserId).get();
    if (querySnapshot.docs.isEmpty) return [];
    return querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> _addMember(String displayName, String email, String password) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sponsor = userProvider.user;

    if (sponsor == null) return;

    if (sponsor.diamonds < _registrationCost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tienes suficientes diamantes.')));
      return;
    }

    final sponsorRef = _firestore.collection('users').doc(sponsor.id);

    try {
      await _firestore.runTransaction((transaction) async {
        final sponsorSnapshot = await transaction.get(sponsorRef);
        if (!sponsorSnapshot.exists) throw "Tu usuario no fue encontrado.";
        
        final currentDiamonds = sponsorSnapshot.data()!['diamonds'] ?? 0;
        if (currentDiamonds < _registrationCost) throw "No tienes suficientes diamantes.";

        transaction.update(sponsorRef, {'diamonds': currentDiamonds - _registrationCost});
      });

      try {
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
        final newUser = userCredential.user;
        if (newUser == null) throw "No se pudo crear el usuario en Firebase Auth.";

        final newUserModel = UserModel(
          id: newUser.uid,
          displayName: displayName,
          email: email,
          role: Role.user,
          diamonds: 0,
          sponsorId: sponsor.id,
        );
        await _firestore.collection('users').doc(newUser.uid).set(newUserModel.toFirestore());

        await _firestore.collection('transactions').add({
          'senderId': sponsor.id,
          'senderName': sponsor.displayName,
          'receiverId': newUser.uid,
          'receiverName': displayName,
          'amount': _registrationCost,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'registration_fee',
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Miembro ${displayName} registrado con éxito!')));
        await userProvider.loadUser();
        _fetchData();

      } catch (e) {
        await sponsorRef.update({'diamonds': FieldValue.increment(_registrationCost)});
        String errorMessage = 'Error al crear el usuario. Se han reembolsado los diamantes.';
        if (e is auth.FirebaseAuthException) {
          errorMessage = e.code == 'email-already-in-use' 
              ? 'El email ya está en uso. Se han reembolsado los diamantes.' 
              : 'La contraseña es muy débil. Se han reembolsado los diamantes.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.red))));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error en la transacción: $e')));
    }
  }

  Future<void> _giveDiamonds(UserModel subordinate, int amount) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser == null) return;
    if (currentUser.role != Role.creator && currentUser.diamonds < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No tienes suficientes diamantes.')));
      return;
    }

    final currentUserRef = _firestore.collection('users').doc(currentUser.id);
    final subordinateRef = _firestore.collection('users').doc(subordinate.id);
    final transactionRef = _firestore.collection('transactions').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        if (currentUser.role != Role.creator) {
          final currentUserSnapshot = await transaction.get(currentUserRef);
          final currentDiamonds = currentUserSnapshot.data()!['diamonds'] ?? 0;
          if (currentDiamonds < amount) throw 'Diamantes insuficientes.';
          transaction.update(currentUserRef, {'diamonds': currentDiamonds - amount});
        }
        transaction.update(subordinateRef, {'diamonds': FieldValue.increment(amount)});
        transaction.set(transactionRef, {
          'senderId': currentUser.id,
          'senderName': currentUser.displayName,
          'receiverId': subordinate.id,
          'receiverName': subordinate.displayName,
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'gift',
        });
      });
      await userProvider.loadUser();
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Envío exitoso de $amount diamantes a ${subordinate.displayName}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error en la transacción: $e')));
    }
  }

  Future<void> _changeRole(UserModel subordinate, Role newRole) async {
    try {
      await _firestore.collection('users').doc(subordinate.id).update({'role': newRole.name});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${subordinate.displayName} es ahora ${newRole.name}')));
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cambiar el rol: $e')));
    }
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nuevo Miembro'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Se descontarán $_registrationCost diamantes.'),
            TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre Completo'), validator: (v) => v!.isEmpty ? 'Ingresa un nombre' : null),
            TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Ingresa un email válido' : null),
            TextFormField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña Temporal'), obscureText: true, validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                _addMember(nameController.text, emailController.text, passwordController.text);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showGiveDiamondsDialog(UserModel subordinate) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dar Diamantes a ${subordinate.displayName}'),
        content: Form(
          key: formKey,
          child: TextFormField(controller: amountController, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number, validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Ingresa un número válido' : null),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                _giveDiamonds(subordinate, int.parse(amountController.text));
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserModel subordinate) {
    Role selectedRole = subordinate.role;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Cambiar Rol de ${subordinate.displayName}'),
          content: DropdownButton<Role>(
            value: selectedRole,
            isExpanded: true,
            onChanged: (Role? newValue) => setState(() => selectedRole = newValue!),
            items: Role.values.map((role) => DropdownMenuItem(value: role, child: Text(role.name))).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () {
              Navigator.of(context).pop();
              _changeRole(subordinate, selectedRole);
            }, child: const Text('Confirmar')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Gestión'),
        actions: [IconButton(icon: const Icon(Icons.bar_chart_outlined), tooltip: 'Ver Reportes', onPressed: () => context.go('/admin/reports'))],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddMemberDialog, tooltip: 'Añadir Miembro', child: const Icon(Icons.add)),
      body: Column(
        children: [
          _buildHeader(userProvider.user),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _subordinatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final subordinates = snapshot.data;
                if (subordinates == null || subordinates.isEmpty) {
                  return const Center(child: Text('Aún no tienes miembros en tu red.'));
                }
                return ListView.builder(
                  itemCount: subordinates.length,
                  itemBuilder: (context, index) {
                    final subordinate = subordinates[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(subordinate.displayName?.substring(0, 1).toUpperCase() ?? "U")),
                        title: Text(subordinate.displayName ?? "Usuario"),
                        subtitle: Text('Rol: ${subordinate.role.name} - Diamantes: ${subordinate.diamonds}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.card_giftcard), onPressed: () => _showGiveDiamondsDialog(subordinate), tooltip: 'Dar Diamantes'),
                            IconButton(icon: const Icon(Icons.admin_panel_settings_outlined), onPressed: () => _showChangeRoleDialog(subordinate), tooltip: 'Cambiar Rol'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(user.displayName ?? "Usuario", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Mis Diamantes: ${user.diamonds}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }
}
