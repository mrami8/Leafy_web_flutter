import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/user_profile_provider.dart';
import 'package:leafy_app_flutter/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'package:leafy_app_flutter/screens/LoginScreen.dart';

// Pantalla de perfil de usuario
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro

      appBar: PreferredSize(
  preferredSize: Size.fromHeight(60), // Tamaño ajustado
  child: AppBar(
    backgroundColor: const Color(0xFFD6E8C4),
    centerTitle: true,
    elevation: 0,
    title: const Text(
      "LEAFY",
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 20,
        letterSpacing: 1.2,
      ),
    ),
  ),
),


      // Si los datos del perfil están cargando, se muestra un indicador
      body:
          userProfileProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Título LEAFY
                      Text(
                        "LEAFY",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),

                      SizedBox(height: 24),

                      // Avatar del usuario
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            userProfileProvider.fotoPerfil.isNotEmpty
                                ? NetworkImage(userProfileProvider.fotoPerfil)
                                : null,
                        backgroundColor: const Color(0xFFD6E8C4),
                        child:
                            userProfileProvider.fotoPerfil.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[700],
                                )
                                : null,
                      ),

                      SizedBox(height: 16),

                      // Nombre del usuario
                      Text(
                        userProfileProvider.username.isNotEmpty
                            ? userProfileProvider.username
                            : "Sin nombre",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      // Correo electrónico
                      Text(
                        userProfileProvider.email.isNotEmpty
                            ? userProfileProvider.email
                            : "Sin email",
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                      SizedBox(height: 30),

                      // Botón para ir a la pantalla de edición del perfil
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Editar perfil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6E8C4),
                          foregroundColor: Colors.black,
                        ),
                      ),

                      SizedBox(height: 10),

                      // Botón para cerrar sesión y redirigir al login
                      ElevatedButton.icon(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await authProvider.logout();

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                            (route) =>
                                false, // Elimina todo el historial de navegación
                          );
                        },
                        icon: Icon(Icons.logout),
                        label: Text('Cerrar sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
