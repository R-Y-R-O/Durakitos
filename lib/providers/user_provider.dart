
import 'package:flutter/material.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Método para cargar los datos del usuario logueado
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.getCurrentUserModel();
    
    _isLoading = false;
    notifyListeners();
  }

  // Método para limpiar los datos al hacer logout
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
