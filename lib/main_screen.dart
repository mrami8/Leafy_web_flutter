import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/screens/calendar_screen.dart';
import 'package:leafy_app_flutter/screens/plants_screen.dart';
import 'package:leafy_app_flutter/screens/profile_screen.dart';
import 'package:leafy_app_flutter/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SearchScreen(),
    ProfileScreen(),
    CalendarPage(),
    PlantsScreen(),
  ];

  final List<String> _titles = [
    "Buscar",
    "Perfil",
    "Calendario",
    "Plantas",
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Cierra el Drawer después de seleccionar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFFD7EAC8),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFD7EAC8),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFD7EAC8),
              ),
              child: Text('Leafy Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar'),
              onTap: () => _onItemSelected(0),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => _onItemSelected(1),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendario'),
              onTap: () => _onItemSelected(2),
            ),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Plantas'),
              onTap: () => _onItemSelected(3),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
