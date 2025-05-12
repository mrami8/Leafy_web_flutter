import 'package:flutter/material.dart';
import '../General/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileProvider extends ChangeNotifier {
  String _username = ''; // Nombre de usuario
  String _email = ''; // Email del usuario
  String _telefono = ''; // Teléfono del usuario
  String _fotoPerfil = ''; // URL de la foto de perfil
  bool _isLoading = false; // Indicador de carga

  // Getters públicos
  String get username => _username;
  String get email => _email;
  String get telefono => _telefono;
  String get fotoPerfil => _fotoPerfil;
  bool get isLoading => _isLoading;

  // Cargar los datos del perfil desde AuthProvider
  void loadFromAuth(AuthProvider auth) {
    _isLoading = true;
    notifyListeners();

    final profile = auth.userProfile;
    if (profile != null) {
      _username = profile['nombre'] ?? 'Sin nombre';
      _email = profile['email'] ?? 'Sin email';
      _telefono = profile['telefono'] ?? '';
      _fotoPerfil = profile['foto_perfil'] ?? '';
    } else {
      print("No se pudo cargar el perfil del usuario.");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Actualiza nombre, email y teléfono en Supabase y localmente
  Future<void> updateProfile({
    required String username,
    required String email,
    required String telefono,
    required AuthProvider auth,
  }) async {
    final supabase = auth.supabase;

    await supabase.from('usuarios').update({
      'nombre': username,
      'email': email,
      'telefono': telefono,
    }).eq('id', auth.user!.id);

    if (email != _email) {
      await supabase.auth.updateUser(UserAttributes(email: email));
    }

    _username = username;
    _email = email;
    _telefono = telefono;
    notifyListeners();
  }

  // Actualiza la contraseña
  Future<void> updatePassword(String newPassword, AuthProvider auth) async {
    final supabase = auth.supabase;
    if (auth.user != null) {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    }
  }
}
