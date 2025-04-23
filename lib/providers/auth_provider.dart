import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  Session? _session;
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false; // Estado de carga

  Session? get session => _session;
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading; // Getter para el estado de carga

  // Cargar sesión al iniciar la app
  Future<void> loadSession() async {
    _isLoading = true; // Iniciar la carga
    notifyListeners();

    _session = supabase.auth.currentSession;
    _user = supabase.auth.currentUser;

    if (_user != null) {
      await _asegurarUsuarioRegistrado();
      await _loadUserProfile();
    }

    _isLoading = false; // Finalizar la carga
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _session = response.session;
        _user = response.user;
        await _asegurarUsuarioRegistrado();
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (_) {
      return false;
    }
  }

  // Registro con nombre y foto (la contraseña se maneja automáticamente)
  Future<bool> register(
    String email,
    String password,
    String nombre, {
    String foto = "",
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password, // Supabase maneja la contraseña internamente
      );

      if (response.user != null) {
        // Insertamos los datos adicionales en la tabla 'usuarios', sin la contraseña
        await supabase
            .from('usuarios')
            .insert({
              'id': response.user!.id,
              'email': email,
              'nombre': nombre,
              'foto_perfil': foto, // Foto opcional
            })
            .then((value) {});

        _session = response.session;
        _user = response.user;
        await _loadUserProfile();
        notifyListeners();
        return true;
      }

      return false;
    } on AuthException catch (_) {
      return false;
    }
  }

  // Cargar perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      if (_user != null && _user!.email != null) {
        print('Cargando perfil para el usuario con email: ${_user!.email}');
        final result =
            await supabase
                .from('usuarios')
                .select()
                .eq('email', _user!.email!) // Consulta por correo electrónico
                .maybeSingle();

        if (result != null) {
          _userProfile = result;
          print('Perfil cargado: $_userProfile');
        } else {
          print('No se encontró el perfil del usuario en la tabla.');
        }
      } else {
        print('El usuario o su correo es nulo.');
      }
    } catch (e) {
      print('Error cargando perfil: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
    _session = null;
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> _asegurarUsuarioRegistrado() async {
  if (_user == null || _user!.email == null) return;

  try {
    final existing = await supabase
        .from('usuarios')
        .select()
        .eq('email', _user!.email!)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('usuarios').insert({
        'id': _user!.id,          // seguimos usando el ID real
        'email': _user!.email,
        'nombre': 'Usuario nuevo',
        'foto_perfil': '',
      });
      print('✅ Usuario creado automáticamente en tabla usuarios');
    } else {
      print('🟢 Usuario ya existe en tabla usuarios (por email)');
    }
  } catch (e) {
    print('❌ Error asegurando usuario registrado: $e');
  }
}

}