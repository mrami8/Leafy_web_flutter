import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart'; // Archivo donde se configura Supabase
import 'screens/LoginScreen.dart'; // Pantalla de inicio de sesión
import 'screens/RegisterScreen.dart'; // Pantalla de registro
import 'screens/PlantsScreen/search_screen.dart'; // Pantalla de búsqueda de plantas
import 'screens/CalendarScreen/calendar_screen.dart'; // Pantalla del calendario
import 'screens/ProfileScreen/profile_screen.dart'; // Pantalla del perfil
import 'providers/General/auth_provider.dart'; // Provider de autenticación
import 'providers/Plants/plant_search_provider.dart'; // Provider para buscar plantas
import 'providers/Calendar/notification_provider.dart'; // Provider para notificaciones del calendario
import 'providers/Profile/user_profile_provider.dart'; // Provider del perfil de usuario
import 'providers/Garden/progress_provider.dart'; // Provider de progreso del jardín
import 'screens/GardenScreen/plants_screen.dart'; // Pantalla de "Mis Plantas"

void main() async {
  // Necesario para inicializar Flutter antes de usar plugins asincrónicos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase con las credenciales desde 'supabase_config.dart'
  await SupabaseConfig.init();

  // Obtiene el cliente de Supabase para pasar a los providers
  final supabaseClient = Supabase.instance.client;

  runApp(
    MultiProvider(
      providers: [
        // Provider de autenticación, carga la sesión al iniciar
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),

        // Provider de búsqueda de plantas, necesita el cliente Supabase
        ChangeNotifierProvider(
          create: (_) => PlantSearchProvider(supabaseClient),
        ),

        // Provider de notificaciones para el calendario
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Provider de seguimiento de progreso de plantas
        ChangeNotifierProvider(create: (_) => ProgressProvider()),

        // Provider del perfil del usuario, se conecta con la sesión del auth
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

      // MaterialApp: entrada principal de la app
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Leafy App',

        // Ruta inicial
        initialRoute: '/',

        // Rutas disponibles en la app
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/search': (context) => const SearchScreen(),
          '/calendar': (context) => const CalendarScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/misplantas': (context) => const PlantsScreen(),
        },
      ),
    ),
  );
}
