import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Profile/user_profile_provider.dart';
import 'package:leafy_app_flutter/providers/General/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'package:leafy_app_flutter/screens/LoginScreen/LoginScreen.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout general para mantener la estética web y coherencia visual

// Pantalla principal de perfil del usuario
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceso a los proveedores necesarios
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return LeafyLayout(
      showSearchBar: true,
      // Mostrar loading mientras se carga la información del perfil
      child: userProfileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Cabecera con imagen de fondo + avatar grande + nombre/email
                    Stack(
                      children: [
                        // Imagen de fondo de perfil
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: NetworkImage(
                                "https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1350&q=80",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Capa semitransparente encima del fondo
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        // Avatar grande + nombre + correo
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 24),
                              // Avatar del usuario (con imagen o ícono por defecto)
                              CircleAvatar(
                                radius: 90,
                                backgroundImage:
                                    userProfileProvider.fotoPerfil.isNotEmpty
                                        ? NetworkImage(
                                            userProfileProvider.fotoPerfil)
                                        : null,
                                backgroundColor: const Color(0xFFD6E8C4),
                                child: userProfileProvider.fotoPerfil.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 90, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 40),
                              // Nombre y correo
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userProfileProvider.username.isNotEmpty
                                          ? userProfileProvider.username
                                          : "Sin nombre",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      userProfileProvider.email.isNotEmpty
                                          ? userProfileProvider.email
                                          : "Sin email",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Sección de información personal ficticia (puede ser editable en el futuro)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F7E8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Información personal",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text("📍 Ubicación: Sevilla, España"),
                          Text("🎂 Fecha de nacimiento: 22 de octubre de 1989"),
                          Text("🧬 Intereses: Ecología urbana, botánica exótica, acuaponía doméstica"),
                          Text("📚 Profesión: Arquitecta paisajista"),
                          Text(
                              "💬 Biografía: Entusiasta de los ecosistemas urbanos. "
                              "Creo espacios verdes sostenibles que mezclan diseño moderno y naturaleza viva."),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botón para editar perfil
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditProfileScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6E8C4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Botón para cerrar sesión
                    ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.logout(); // Limpia datos y tokens
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false, // Elimina historial para evitar volver atrás
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
