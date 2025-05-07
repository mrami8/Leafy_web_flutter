import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider que gestiona la autenticación del usuario, carga del perfil,
/// login, logout y registro en Supabase.
class AuthProvider extends ChangeNotifier {
  // Cliente de Supabase
  final SupabaseClient supabase = Supabase.instance.client;

  // Estado interno
  Session? _session; // Sesión activa
  User? _user; // Usuario actual
  Map<String, dynamic>?
  _userProfile; // Perfil del usuario desde la tabla 'usuarios'
  bool _isLoading = false; // Indicador de carga para la UI

  // Getters públicos para exponer el estado
  Session? get session => _session;
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  /// Cargar sesión y perfil si el usuario ya está autenticado al iniciar la app
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners(); // Notifica a la UI que comienza la carga

    _session = supabase.auth.currentSession;
    _user = supabase.auth.currentUser;

    // Si hay un usuario autenticado, aseguramos que exista en la tabla 'usuarios'
    if (_user != null) {
      await _asegurarUsuarioRegistrado();
      await _loadUserProfile();
    }

    _isLoading = false;
    notifyListeners(); // Notifica que finalizó la carga
  }

  /// Iniciar sesión con email y contraseña
  Future<bool> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _session = response.session;
        _user = response.user;

        // Verifica que el usuario tenga un registro en la tabla 'usuarios'
        await _asegurarUsuarioRegistrado();
        await _loadUserProfile();
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (_) {
      return false; // Error de autenticación
    }
  }

  /// Registro de un nuevo usuario con email, contraseña, nombre y opcionalmente foto
  Future<bool> register(
    String email,
    String password,
    String nombre, {
    String foto = "",
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        // Insertar en la tabla de perfil de usuarios
        await supabase.from('usuarios').insert({
          'id': user.id,
          'email': email,
          'nombre': nombre,
          'foto_perfil': foto,
        });

        print(
          '✅ Usuario registrado correctamente. Esperando confirmación por correo.',
        );
        return true;
      }

      return false;
    } on AuthException catch (e) {
      print('❌ Error de registro: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error inesperado: $e');
      return false;
    }
  }

  /// Cargar perfil desde la tabla 'usuarios' usando el email como identificador
  Future<void> _loadUserProfile() async {
    try {
      if (_user != null && _user!.email != null) {
        print('Cargando perfil para el usuario con email: ${_user!.email}');

        final result =
            await supabase
                .from('usuarios')
                .select()
                .eq('email', _user!.email!)
                .maybeSingle(); // Devuelve uno o null

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

  /// Cerrar sesión
  Future<void> logout() async {
    await supabase.auth.signOut();

    // Limpiar todos los estados
    _session = null;
    _user = null;
    _userProfile = null;

    notifyListeners(); // Actualiza la UI
  }

  /// Asegura que el usuario esté registrado en la tabla 'usuarios'.
  /// Si no existe, lo crea automáticamente.
  Future<void> _asegurarUsuarioRegistrado() async {
    if (_user == null || _user!.email == null) return;

    try {
      // Busca si el usuario ya existe por email
      final existing =
          await supabase
              .from('usuarios')
              .select()
              .eq('email', _user!.email!)
              .maybeSingle();

      if (existing == null) {
        // Si no existe, lo inserta como nuevo
        await supabase.from('usuarios').insert({
          'id': _user!.id,
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
