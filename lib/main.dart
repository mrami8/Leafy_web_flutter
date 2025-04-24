import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supabase_config.dart'; 
import 'LoginScreen.dart'; 
import 'main_screen.dart'; 
import 'providers/auth_provider.dart';
import 'providers/plant_search_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/progress_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter está completamente inicializado

  await SupabaseConfig.init(); // Inicializa Supabase con la configuración personalizada

  final supabaseClient = Supabase.instance.client; // Cliente global de Supabase

  runApp(
    MultiProvider(
      providers: [
        // Proveedor de autenticación (maneja login, registro, logout)
        ChangeNotifierProvider(
          create:
              (_) => AuthProvider()..loadSession(), // Carga la sesión si existe
        ),

        // Proveedor para búsqueda de plantas
        ChangeNotifierProvider(
          create: (_) => PlantSearchProvider(supabaseClient),
        ),

        // Proveedor de notificaciones de calendario
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Proveedor para la subida y gestión de fotos de progreso
        ChangeNotifierProvider(create: (_) => ProgressProvider()),

        // Proveedor de perfil del usuario, cargado a partir de AuthProvider
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final userProfileProvider = UserProfileProvider();
            userProfileProvider.loadFromAuth(authProvider);
            return userProfileProvider;
          },
        ),
      ],

      // Inicio de la aplicación con MaterialApp
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Leafy App',

        // Muestra la pantalla correspondiente según si hay sesión iniciada
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.session != null
                ? MainScreen() // Usuario logueado -> ir a pantalla principal
                : LoginScreen(); // Usuario no logueado -> ir a login
          },
        ),
      ),
    ),
  );
}
