import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leafy_app_flutter/leafy_layout.dart';
import 'package:leafy_app_flutter/providers/General/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return LeafyLayout(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/FondoPantalla.jpg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.2)),

            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
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
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nombre",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Correo electrónico",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Contraseña",
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final nombre = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Por favor, completa todos los campos."),
                              ),
                            );
                            return;
                          }

                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

                          final success = await authProvider.register(email, password, nombre);

                          if (success && authProvider.session != null) {
                            Navigator.pushNamed(context, '/search');
                          } else {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿Ya tienes cuenta? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/');
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
