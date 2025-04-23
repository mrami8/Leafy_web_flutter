import 'package:supabase_flutter/supabase_flutter.dart';

// Clase que contiene la configuración de Supabase y métodos de autenticación
class SupabaseConfig {
  // URL del proyecto Supabase (tu instancia)
  static const String supabaseUrl = 'https://pxrtpyuvhfjfhvlmdbdb.supabase.co';

  // Clave pública de acceso (anon key) para interactuar con la API de Supabase
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4cnRweXV2aGZqZmh2bG1kYmRiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MzYwNDkzNCwiZXhwIjoyMDU5MTgwOTM0fQ.wWBZBMIXntAcx8BY3KKHLN7K-yXv035-s3d1bWZruXU';

  // Método que inicializa la conexión con Supabase usando la URL y la anon key
  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Función para iniciar sesión con email y contraseña
  static Future<AuthResponse> login(String email, String password) async {
    final client = Supabase.instance.client;
    // Llama al método de autenticación de Supabase
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response; // Devuelve el objeto AuthResponse con info de sesión y usuario
  }

  // Función para cerrar sesión actual del usuario
  static Future<void> logout() async {
    final client = Supabase.instance.client;
    await client.auth.signOut(); // Finaliza la sesión
  }

  // Función para registrar un nuevo usuario y guardarlo también en la tabla `usuarios`
  static Future<AuthResponse> signUp(
    String email,
    String password,
    String nombre,
    String fotoPerfil,
  ) async {
    final client = Supabase.instance.client;

    // Registra el usuario en el sistema de autenticación de Supabase
    final response = await client.auth.signUp(email: email, password: password);

    // Si el usuario fue creado correctamente, insertamos sus datos en la tabla `usuarios`
    if (response.user != null) {
      await client.from('usuarios').insert({
        'id': response.user!.id, // ID generado por Supabase Auth
        'nombre': nombre, // Nombre ingresado en el formulario
        'email': email, // Email del usuario
        'foto_perfil': fotoPerfil, // Puede estar vacío por defecto
      });
    }

    return response; // Devuelve el resultado del registro
  }
}
