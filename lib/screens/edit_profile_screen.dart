import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/providers/user_profile_provider.dart';
import 'package:leafy_app_flutter/providers/auth_provider.dart';

// Pantalla para editar el perfil del usuario
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario

  // Controladores para los campos de texto
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales del perfil desde el provider
    final userProfile = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );
    _usernameController = TextEditingController(text: userProfile.username);
    _emailController = TextEditingController(text: userProfile.email);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4E4), // Fondo verde claro
      appBar: AppBar(
        title: Text('Editar Perfil'),
        backgroundColor: const Color(0xFFD6E8C4), // Barra verde suave
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // Validación y guardado del formulario
              if (_formKey.currentState!.validate()) {
                // Actualiza nombre y correo
                await userProfileProvider.updateProfile(
                  username: _usernameController.text,
                  email: _emailController.text,
                  auth: authProvider,
                );

                // Si se ingresó nueva contraseña, la actualiza
                if (_passwordController.text.isNotEmpty) {
                  await userProfileProvider.updatePassword(
                    _passwordController.text,
                    authProvider,
                  );
                }

                // Cierra la pantalla
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Referencia al formulario para validación
          child: Column(
            children: [
              // Campo de nombre
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Campo de correo electrónico
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un correo';
                  }
                  // Validación básica de correo
                  if (!RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                  ).hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Campo de contraseña (opcional)
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Oculta el texto ingresado
                decoration: InputDecoration(
                  labelText: 'Contraseña (opcional)',
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
