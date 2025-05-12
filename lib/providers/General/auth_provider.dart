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
  String nombre,
  String telefono, { // Agregamos el parámetro de teléfono
  String foto = "", // Parámetro opcional para la foto de perfil
}) async {
  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await supabase.from('usuarios').insert({
        'id': response.user!.id,
        'email': email,
        'nombre': nombre,
        'telefono': telefono, // Inserta el teléfono
        'foto_perfil': foto,
        'contraseña': password,
      });

      _session = response.session;
      _user = response.user;
      await _loadUserProfile();
      notifyListeners();
      return true;
    }

    return false;
  } on AuthException catch (_) {
    return false; // Error de Supabase (ej: correo duplicado)
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
    final existing = await supabase
        .from('usuarios')
        .select()
        .eq('email', _user!.email!)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('usuarios').insert({
        'id': _user!.id,
        'email': _user!.email,
        'nombre': 'Usuario nuevo',
        'foto_perfil': '',
        'telefono': '', // Registra el teléfono vacío si no existe
      });

      print('✅ Usuario creado automáticamente en tabla usuarios');
    } else {
      print('🟢 Usuario ya existe en tabla usuarios (por email)');
    }
  } catch (e) {
    print('❌ Error asegurando usuario registrado: $e');
  }
}


  Future<bool> loginWithPhone(String phone, String password) async {
  try {
    // Buscar usuario por teléfono
    final result = await supabase
        .from('usuarios')
        .select('email, id, contraseña')
        .eq('telefono', phone) // Buscar por teléfono
        .maybeSingle(); // Solo obtenemos un registro

    if (result != null) {
      final email = result['email'];
      final storedPassword = result['contraseña'];

      print('Usuario encontrado por teléfono: $email');
      print('Contraseña almacenada en base de datos: $storedPassword');
      print('Contraseña ingresada: $password'); // Imprime la contraseña ingresada para comparar

      // Comparar contraseñas
      if (password == storedPassword) {
        // Si las contraseñas coinciden, hacer login con el correo
        print('Contraseña correcta, realizando login...');
        return login(email, password); // Llamada al login con correo y contraseña
      } else {
        print('Contraseña incorrecta');
        return false;
      }
    } else {
      print('No se encontró un usuario con ese teléfono');
      return false;
    }
  } catch (e) {
    print('Error al intentar login con teléfono: $e');
    return false;
  }
}




}
