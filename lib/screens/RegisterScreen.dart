import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/leafy_layout.dart'; // Layout general reutilizable
import 'package:leafy_app_flutter/providers/General/auth_provider.dart'; // Provider para autenticación

// Pantalla de registro de usuarios
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para los campos de texto
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return LeafyLayout(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo de pantalla
            Image.asset('assets/FondoPantalla.jpg', fit: BoxFit.cover),
            // Capa semitransparente encima del fondo
            Container(color: Colors.black.withOpacity(0.2)),

            // Formulario centrado
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400), // Limita el ancho para estilo web
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Crear cuenta", style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),

                      // Campo: Nombre
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Nombre"),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Correo electrónico
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Correo electrónico"),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Contraseña
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Contraseña"),
                      ),
                      const SizedBox(height: 24),

                      // Botón de registro
                      ElevatedButton(
                        onPressed: () async {
                          // Obtiene valores de los campos
                          final nombre = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          // Validación básica de campos vacíos
                          if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Por favor, completa todos los campos."),
                              ),
                            );
                            return;
                          }

                          // Accede al AuthProvider para registrar el usuario
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

                          final success = await authProvider.register(email, password, nombre);

                          // Muestra diálogo si se registró correctamente
                          if (success) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Registro exitoso"),
                                content: const Text(
                                  "Revisa tu correo electrónico y confirma tu cuenta antes de iniciar sesión.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/');
                                    },
                                    child: const Text("Ir a iniciar sesión"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Error al registrar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No se pudo registrar. Inténtalo de nuevo."),
                              ),
                            );
                          }
                        },
                        child: const Text("Registrarse"),
                      ),

                      const SizedBox(height: 16),

                      // Enlace para ir a la pantalla de inicio de sesión
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿Ya tienes cuenta? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/'); // Navega a login
                            },
                            child: const Text(
                              "Inicia sesión",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
