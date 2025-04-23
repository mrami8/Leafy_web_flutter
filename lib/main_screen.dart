import 'package:flutter/material.dart';
import 'package:leafy_app_flutter/screens/calendar_screen.dart';
import 'package:leafy_app_flutter/screens/plants_screen.dart';
import 'package:leafy_app_flutter/screens/profile_screen.dart';
import 'package:leafy_app_flutter/screens/search_screen.dart';

// Pantalla principal que contiene la navegación entre pestañas
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Índice actual de la pestaña seleccionada (0 = Buscar)

  // Lista de pantallas asociadas a cada pestaña
  final List<Widget> _screens = [
    SearchScreen(),    // Índice 0: Buscar plantas
    ProfileScreen(),   // Índice 1: Perfil del usuario
    CalendarPage(),    // Índice 2: Calendario de cuidados
    PlantsScreen(),    // Índice 3: Jardín del usuario
  ];

  // Cambia la pestaña activa cuando el usuario pulsa en una del BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD7EAC8), // Fondo verde pastel oscuro
        selectedItemColor: Colors.green, // Ítem activo en blanco
        unselectedItemColor: Colors.grey[800], // Ítems inactivos en gris oscuro
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendario"),
          BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: "Plantas"),
        ],
      ),
    );
  }
}
