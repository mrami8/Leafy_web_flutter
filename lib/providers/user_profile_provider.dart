import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider que gestiona la información del perfil del usuario
class UserProfileProvider extends ChangeNotifier {
  String _username = ''; // Nombre de usuario
  String _email = ''; // Email del usuario
  String _fotoPerfil = ''; // URL de la foto de perfil
  bool _isLoading = false; // Indicador de carga

  // Getters públicos para acceder a los valores privados
  String get username => _username;
  String get email => _email;
  String get fotoPerfil => _fotoPerfil;
  bool get isLoading => _isLoading;

  // Método para cargar los datos del perfil a partir del AuthProvider
  void loadFromAuth(AuthProvider auth) {
    _isLoading = true;
    notifyListeners(); // Notifica a la UI que está cargando

    final profile = auth.userProfile;
    if (profile != null) {
      // Carga los valores desde el perfil
      _username = profile['nombre'] ?? 'Sin nombre';
      _email = profile['email'] ?? 'Sin email';
      _fotoPerfil = profile['foto_perfil'] ?? '';
    } else {
      print("No se pudo cargar el perfil del usuario.");
    }

    _isLoading = false;
    notifyListeners(); // Notifica a la UI que ha terminado la carga
  }

  // Actualiza el nombre y email del usuario en Supabase y localmente
  Future<void> updateProfile({
    required String username,
    required String email,
    required AuthProvider auth,
  }) async {
    final supabase = auth.supabase;

    // Actualiza los datos del perfil en la tabla 'usuarios'
    final result = await supabase
        .from('usuarios')
        .update({'nombre': username, 'email': email})
        .eq('id', auth.user!.id); // Filtra por ID del usuario

    // Si el email fue modificado, también se actualiza en la sesión de Supabase Auth
    if (email != _email) {
      await supabase.auth.updateUser(UserAttributes(email: email));
    }

    // Actualiza localmente los datos y notifica cambios
    _username = username;
    _email = email;
    notifyListeners();
  }

  // Actualiza la contraseña del usuario autenticado
  Future<void> updatePassword(String newPassword, AuthProvider auth) async {
    final supabase = auth.supabase;
    if (auth.user != null) {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    }
  }
}
