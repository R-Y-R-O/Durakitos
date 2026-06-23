import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio para gestionar contactos en la cuenta de Google del usuario.
/// Cuando se acepta una solicitud de enlace, se crea el contacto mutuamente
/// en las agendas de Google de ambos usuarios.
class GoogleContactsService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/contacts'],
  );

  /// Obtiene el access token actual del usuario.
  Future<String?> _getAccessToken() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) {
        developer.log('No Google account found', name: 'google_contacts');
        return null;
      }
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
      developer.log('Error getting access token: $e', name: 'google_contacts', level: 900);
      return null;
    }
  }

  /// Crea un contacto en la agenda de Google del usuario actual.
  /// Se llama automáticamente al aceptar una solicitud de enlace.
  Future<bool> createContact({
    required String displayName,
    String? phone,
    String? email,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        developer.log('Cannot create contact: no access token', name: 'google_contacts', level: 900);
        return false;
      }
      // Construir el payload para People API
      final personData = {
        'names': [{'givenName': displayName}],
      };

      if (phone != null && phone.isNotEmpty) {
        personData['phoneNumbers'] = [{'value': phone}];
      }

      if (email != null && email.isNotEmpty) {
        personData['emailAddresses'] = [{'value': email}];
      }

      final response = await http.post(
        Uri.parse('https://people.googleapis.com/v1/people:createContact'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(personData),
      );

      if (response.statusCode == 200) {
        developer.log('Contact created successfully: $displayName', name: 'google_contacts');
        return true;
      } else {
        developer.log(
          'Failed to create contact: ${response.statusCode} - ${response.body}',
          name: 'google_contacts',
          level: 900,
        );
        return false;
      }
    } catch (e) {
      developer.log('Error creating contact: $e', name: 'google_contacts', level: 1000, error: e);
      return false;
    }
  }

  /// Busca un contacto en la agenda de Google por nombre o email.
  Future<Map<String, dynamic>?> findContact(String query) async {
    try {
      final token = await _getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people:searchContacts?query=$query&readMask=names,phoneNumbers,emailAddresses'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return results.first['person'];
        }
      }
      return null;
    } catch (e) {
      developer.log('Error searching contact: $e', name: 'google_contacts', level: 900);
      return null;
    }
  }

  /// Elimina un contacto de la agenda de Google.
  /// Se llama cuando se elimina un enlace en la app.
  Future<bool> deleteContact(String resourceName) async {
    try {
      final token = await _getAccessToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('https://people.googleapis.com/v1/$resourceName:deleteContact'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      developer.log('Error deleting contact: $e', name: 'google_contacts', level: 900);
      return false;
    }
  }
}
