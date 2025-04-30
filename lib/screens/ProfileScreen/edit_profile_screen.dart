import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/Profile/user_profile_provider.dart';
import 'package:leafy_app_flutter/providers/General/auth_provider.dart';

/// Pantalla para editar el perfil del usuario
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    // Inicializa los controladores con los datos actuales del perfil
    final userProfile = Provider.of<UserProfileProvider>(context, listen: false);
    _usernameController = TextEditingController(text: userProfile.username);
    _emailController = TextEditingController(text: userProfile.email);
  }

  @override
  void dispose() {
    // Limpieza de los controladores al destruir la pantalla
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    const Text(
                      'Editar Perfil',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Campo de nombre
                    TextFormField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration('Nombre'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Por favor ingresa un nombre' : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo de correo
                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration('Correo electrónico'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un correo';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                            .hasMatch(value)) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón para volver atrás
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Volver"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),

                        // Botón para guardar los cambios
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar cambios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD6E8C4),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Llama al método para actualizar el perfil
                              await userProfileProvider.updateProfile(
                                username: _usernameController.text,
                                email: _emailController.text,
                                auth: authProvider,
                              );
                              Navigator.pop(context); // Vuelve atrás después de guardar
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Función reutilizable para estilos de campos de texto
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
