import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_profile_provider.dart';

// Pantalla de login y registro de usuario
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController(); // Solo usado en registro

  bool isRegistering = false; // Alterna entre login y registro

  // Función para manejar el login del usuario
  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfileProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );

    await authProvider.logout(); // Limpia sesión anterior

    bool success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      userProfileProvider.loadFromAuth(
        authProvider,
      ); // Carga el perfil del usuario

      // Redirige al menú principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      // Muestra error si falla el login
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al iniciar sesión')));
    }
  }

  // Función para manejar el registro del usuario
  Future<void> _handleRegister(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nombreController.text.trim(),
    );

    if (success) {
      // Muestra mensaje de éxito y cambia a modo login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso, ahora inicia sesión.')),
      );
      setState(() {
        isRegistering = false;
      });
    } else {
      // Error en el registro
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al registrarse')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Hace que el fondo ocupe toda la pantalla
        children: [
          // Imagen de fondo
          Image.asset('assets/FondoPantalla.jpg', fit: BoxFit.cover),

          // Capa oscura sobre el fondo para mejorar legibilidad
          Container(color: Colors.black.withOpacity(0.5)),

          // Contenido principal centrado y scrollable
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo de la app
                  Image.asset('assets/LogoLeafy.png', height: 120),

                  const SizedBox(height: 20),

                  // Título dinámico según el modo
                  Text(
                    isRegistering ? "Crea tu cuenta" : "Bienvenido de nuevo",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Campo de nombre solo en registro
                  if (isRegistering)
                    _buildTextField("Nombre", _nombreController),

                  // Campo de correo y contraseña
                  _buildTextField("Correo electrónico", _emailController),
                  _buildTextField(
                    "Contraseña",
                    _passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),

                  // Botón principal: login o registro
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (isRegistering) {
                        _handleRegister(context);
                      } else {
                        _handleLogin(context);
                      }
                    },
                    child: Text(
                      isRegistering ? "REGISTRARSE" : "INICIAR SESIÓN",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botón para cambiar entre login y registro
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isRegistering = !isRegistering;
                      });
                    },
                    child: Text(
                      isRegistering
                          ? "¿Ya tienes cuenta? Inicia sesión"
                          : "¿No tienes cuenta? Regístrate",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir campos de texto personalizados
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Oculta el texto si es contraseña
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
