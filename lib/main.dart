import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart'; 
import 'screens/LoginScreen.dart'; 
import 'screens/search_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/plant_search_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/progress_provider.dart';

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
        },
      ),
    ),
  );
}
