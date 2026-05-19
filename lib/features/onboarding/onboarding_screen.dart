
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import 'package:go_router/go_router.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _referredByController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedSex;
  String? _selectedProvince;
  String? _selectedMunicipality;

  bool _isLoading = false;

  // Datos de ejemplo para provincias y municipios
  final Map<String, List<String>> _provinces = {
    'Pinar del Río': ['Pinar del Río', 'Consolación del Sur', 'Viñales'],
    'La Habana': ['Plaza de la Revolución', 'Habana del Este', 'Centro Habana'],
    'Matanzas': ['Matanzas', 'Cárdenas', 'Varadero'],
  };

  List<String> _municipalities = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _referredByController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1920, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw ('No user logged in');

      final userService = UserService();
      final currentUserProfile = await userService.getUserProfile(user.uid);

      if (currentUserProfile == null) throw ('User profile not found');

      final updatedUser = UserModel(
        uid: currentUserProfile.uid,
        email: currentUserProfile.email,
        displayName: currentUserProfile.displayName,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        phone: _phoneController.text,
        province: _selectedProvince,
        municipality: _selectedMunicipality,
        sex: _selectedSex,
        referredBy: _referredByController.text.isNotEmpty ? _referredByController.text : null,
        profileCompleted: true, // ¡Marcamos el perfil como completo!
      );

      await userService.updateUserProfile(updatedUser);

      // Usamos context.go para asegurar la navegación correcta después de una tarea asíncrona
      if (mounted) {
        context.go('/home');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el perfil: $e')),
        );
      }
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Un último paso',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Queremos conocerte un poco mejor.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => value!.isEmpty ? 'Introduce tu nombre' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellidos', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => value!.isEmpty ? 'Introduce tus apellidos' : null,
                ),
                 const SizedBox(height: 20),
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(labelText: 'Fecha de Nacimiento', prefixIcon: Icon(Icons.calendar_today_outlined)),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) => value!.isEmpty ? 'Selecciona tu fecha de nacimiento' : null,
                ),
                const SizedBox(height: 20),

                // --- Selector de Sexo ---
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  decoration: const InputDecoration(labelText: 'Sexo', prefixIcon: Icon(Icons.wc_outlined)),
                  items: ['Masculino', 'Femenino', 'Otro'].map((label) => DropdownMenuItem(child: Text(label), value: label,)).toList(),
                  onChanged: (value) => setState(() => _selectedSex = value),
                  validator: (value) => value == null ? 'Selecciona tu sexo' : null,
                ),
                const SizedBox(height: 20),

                // --- Selector de Provincia ---
                DropdownButtonFormField<String>(
                  value: _selectedProvince,
                  decoration: const InputDecoration(labelText: 'Provincia', prefixIcon: Icon(Icons.location_city_outlined)),
                  items: _provinces.keys.map((province) => DropdownMenuItem(child: Text(province), value: province,)).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvince = value;
                      _selectedMunicipality = null; // Reseteamos el municipio
                      _municipalities = value != null ? _provinces[value]! : [];
                    });
                  },
                  validator: (value) => value == null ? 'Selecciona tu provincia' : null,
                ),
                const SizedBox(height: 20),

                // --- Selector de Municipio ---
                DropdownButtonFormField<String>(
                   value: _selectedMunicipality,
                   decoration: InputDecoration(
                       labelText: 'Municipio',
                       prefixIcon: const Icon(Icons.location_on_outlined),
                       // Se deshabilita si no hay provincia seleccionada
                       enabled: _selectedProvince != null,
                   ),
                   items: _municipalities.map((municipality) => DropdownMenuItem(child: Text(municipality), value: municipality,)).toList(),
                   onChanged: (value) => setState(() => _selectedMunicipality = value),
                   validator: (value) => _selectedProvince != null && value == null ? 'Selecciona tu municipio' : null,
                ),
                 const SizedBox(height: 20),

                 TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                   validator: (value) => value!.isEmpty ? 'Introduce tu teléfono' : null,
                ),
                const SizedBox(height: 20),

                 TextFormField(
                   controller: _referredByController,
                   decoration: const InputDecoration(labelText: 'Código de Referido (Opcional)', prefixIcon: Icon(Icons.group_add_outlined)),
                 ),

                const SizedBox(height: 40),

                // Botón de guardar con estado de carga
                _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Guardar y Continuar'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
