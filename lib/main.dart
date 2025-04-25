import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart'; 
import 'screens/LoginScreen.dart'; 
import 'screens/PlantsScreen/search_screen.dart';
import 'screens/CalendarScreen/calendar_screen.dart';
import 'screens/ProfileScreen/profile_screen.dart';
import 'providers/General/auth_provider.dart';
import 'providers/Plants/plant_search_provider.dart';
import 'providers/Calendar/notification_provider.dart';
import 'providers/Profile/user_profile_provider.dart';
import 'providers/Garden/progress_provider.dart';
import 'screens/GardenScreen/plants_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.init();

  final supabaseClient = Supabase.instance.client;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlantSearchProvider(supabaseClient),
        ),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Leafy App',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/search': (context) => const SearchScreen(),
          '/calendar': (context) => const CalendarPage(),
            '/profile': (context) => const ProfileScreen(),
          '/misplantas': (context) => const PlantsScreen(), // ✅ corregido aquí
        },  

      ),
    ),
  );
}
